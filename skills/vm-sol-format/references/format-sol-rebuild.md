# sol 文件回写与重建

修改 sol 文件中的数据后，需要正确地将变更写回。三个关键操作：ZIP 回写、ModuleFrame（VM 内部拼写为 MoudleFrame）重建、UiParamData TLV 补丁。

> **CLI 实现**：回写通过 `modify` 命令完成，底层使用 Hzip.dll 的 Compress/UnCompress 接口（`Core/IO/SolZipWriter.cs`）。以下 Python/PS 代码仅供参考格式说明，实际使用以 CLI 为准。

## ZIP 回写

CLI 优先使用 `HzipSdkManager.Instance.Compress(srcDir, 1, password, destSol)`（level=1 = DEFLATE，与官方 SolutionConversion 一致），自动处理加密/反斜杠路径/UTF-8 flag。加密和非加密均优先走 Hzip。

非加密 Hzip 失败时，回退到手动 ZIP 构建（`SolZipWriter.BuildZipManual`）：CRC32 表驱动校验、反斜杠路径、UTF-8 flag bit 0x800、DEFLATE 压缩。

加密 Hzip 失败时，回退到手动 ZipCrypto 构建：先 DEFLATE 压缩 → 12 字节加密头（11 随机 + 1 CRC 高位） → ZipCrypto 加密。method=8、flag=0x0801，与 VM 官方输出格式一致。经 VM 4.4.0 实际验证通过。

### Python 参考（仅作历史记录）

修改后的文件重新打包为 `.sol` 时，必须满足以下条件（否则 VM 打开后模块被重新初始化）：

```python
import zipfile
import os

def repack_sol(src_dir: str, dest_sol: str):
    """将 src_dir 打包为 .sol 文件"""
    with zipfile.ZipFile(dest_sol, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(src_dir):
            for f in files:
                full = os.path.join(root, f)
                # 反斜杠路径，相对路径
                arcname = os.path.relpath(full, src_dir).replace('/', '\\')
                # 预创建 ZipInfo 以设置 UTF-8 flag bit（必须在 write 之前设置）
                info = zipfile.ZipInfo(arcname)
                info.flag_bits |= 0x800
                with open(full, 'rb') as fh:
                    zf.writestr(info, fh.read())
```

### 关键要求

| 要求 | 值 | 原因 |
|------|-----|------|
| 压缩方式 | `ZIP_DEFLATED`（method 8） | 与官方 SolutionConversion 生成的原始 sol 一致 |
| 路径分隔符 | 反斜杠 `\` | VM 在 Windows 上解析，正斜杠 `/` 会导致模块初始化失效 |
| 目录条目 | 不包含 | 只打包文件，不打包目录条目 |
| UTF-8 flag | bit 11 | 确保文件名编码正确 |

> **加密 sol 的读取**：见 `format-sol-zip.md`。CLI 通过 Hzip 引擎统一处理，无需外部工具。

### 加密写入（如需要）

```python
with zipfile.ZipFile(dest, 'w', zipfile.ZIP_DEFLATED) as zf:
    zf.setpassword(pwd.encode('utf-8'))
    # ... add files
```

### CLI 实现

CLI 使用 VM 自带的 Hzip 引擎，一行完成：

```csharp
HzipSdkManager.Instance.Compress(srcDir, 1, password ?? "", destSol);
// level=1 = DEFLATE, 空密码 = 不加密, 自动处理反斜杠路径和 UTF-8 flag
```

### C# 参考（仅作历史记录，展示底层格式要求）

---

## ModuleFrame 重建

当模块的 `dataLen` 发生变化时（如修改了算法参数长度、替换了脚本内容、增删了 binary 参数），必须**完整重建** ModuleFrame 文件，因为后续所有模块的偏移都会改变。

**重建策略**：
- **setParam**：使用 byte-level patch，直接在 RawFrameData 的 260+1024 字节槽内原地修改参数值，dataLen 不变，模块不在 ModifiedModules 中——直接复用原 RawFrameData 字节
- **setBinaryParam / setParamSub / addParamSub / removeParamSub / addModule / deleteModule**：dataLen 变化时重建该模块的 rawData，其余模块复用原 RawFrameData 字节
- **孤模块保留**：VmServer.xml 无对应关系的模块（GlobalVarBinding、ModuleParamBinding、RunningPolicy、procedure-*-data）不再丢弃，RawFrameData 原样保留供重建

### 重建算法

```
输入：解析后的模块列表 modules[]
输出：新的 ModuleFrame byte[]（即 ModuleFrame 文件内容）
```

```python
import struct

def write_be32(buf: bytearray, offset: int, value: int):
    """大端序写入 32 位整数"""
    buf[offset:offset+4] = struct.pack('>I', value)

def rebuild_moudleframe(modules: list) -> bytes:
    """重建 ModuleFrame 文件"""
    # 计算总大小
    total = 8  # version(4) + count(4)
    for mod in modules:
        total += 512 + 4 + len(mod['raw_data'])  # name slot + data_len + rawData

    buf = bytearray(total)
    offset = 0

    # 写头部
    write_be32(buf, offset, 7)        # version
    offset += 4
    write_be32(buf, offset, len(modules))  # count
    offset += 4

    # 写每个模块
    for mod in modules:
        # 512-byte name slot (UTF-8, null 填充)
        name_bytes = mod['name'].encode('utf-8')
        for i in range(512):
            if i < len(name_bytes):
                buf[offset + i] = name_bytes[i]
            else:
                buf[offset + i] = 0
        offset += 512

        # data_len (4 bytes BE)
        write_be32(buf, offset, len(mod['raw_data']))
        offset += 4

        # raw_data
        buf[offset:offset+len(mod['raw_data'])] = mod['raw_data']
        offset += len(mod['raw_data'])

    return bytes(buf)
```

### Python 解析与重建参考（仅作历史记录）

以下 Python 代码展示 ModuleFrame 的格式结构。CLI 实际使用 `Core/Writers/ModuleFrameWriter.cs`。

```python
def parse_moudleframe(data: bytes) -> list:
    """解析 ModuleFrame，返回模块列表"""
    modules = []
    offset = 0
    version = struct.unpack('>I', data[offset:offset+4])[0]
    offset += 4
    count = struct.unpack('>I', data[offset:offset+4])[0]
    offset += 4

    for _ in range(count):
        # 512-byte name slot (UTF-8)
        name = data[offset:offset+512].decode('utf-8').rstrip('\x00')
        offset += 512
        data_len = struct.unpack('>I', data[offset:offset+4])[0]
        offset += 4
        raw_data = data[offset:offset+data_len]
        offset += data_len
        modules.append({
            'name': name,
            'data_len': data_len,
            'raw_data': bytearray(raw_data)  # bytearray 方便修改
        })
    return modules
```

### 关键注意事项

- **RawData 必须是 `bytearray` 或 `bytes`**，不能是 list of int（`[0x01, 0x02, ...]`）
- **name slot 固定 512 字节**（新版 V4.4.0+），不足部分 null 填充
- **dataLen 变化时所有后续模块偏移自动重新计算**——这就是为什么必须重建
- 如果只有 **1 个模块**的 dataLen 不变，只修改了 algori 参数值（固定 1024 字节槽位内原地替换），则**不需要重建**——直接原地写入即可

### C# 实现

```csharp
public class ModuleFrameRecord
{
    /// <summary>512-byte name slot，如 "3-IMVSBlobFindModu.mdata"</summary>
    public string NameSlot { get; set; }

    /// <summary>模块 rawData（algori + binary 区域），可变长度</summary>
    public byte[] RawData { get; set; }
}

public static class ModuleFrameBuilder
{
    private const int NameSlotSize = 512; // V4.4.0+, 旧版 V4.3.0 为 256

    /// <summary>
    /// 重建 ModuleFrame 文件。按模块列表顺序写入，自动计算偏移。
    /// </summary>
    public static byte[] Rebuild(List<ModuleFrameRecord> modules)
    {
        int total = 8; // version(4) + count(4)
        foreach (var m in modules)
            total += NameSlotSize + 4 + m.RawData.Length;

        var buf = new byte[total];
        int off = 0;

        WriteInt32BE(buf, off, 7);          // version = 7 (V4.4.0+)
        off += 4;
        WriteInt32BE(buf, off, modules.Count); // count
        off += 4;

        foreach (var m in modules)
        {
            // 512-byte name slot (UTF-8, null 填充)
            var nameBytes = Encoding.UTF8.GetBytes(m.NameSlot ?? "");
            int copyLen = Math.Min(nameBytes.Length, NameSlotSize);
            Array.Copy(nameBytes, 0, buf, off, copyLen);
            off += NameSlotSize;

            // data_len (4 bytes BE)
            WriteInt32BE(buf, off, m.RawData.Length);
            off += 4;

            // rawData
            Array.Copy(m.RawData, 0, buf, off, m.RawData.Length);
            off += m.RawData.Length;
        }

        return buf;
    }

    /// <summary>大端序写入 32 位整数</summary>
    public static void WriteInt32BE(byte[] buf, int offset, int value)
    {
        buf[offset]     = (byte)(value >> 24);
        buf[offset + 1] = (byte)(value >> 16);
        buf[offset + 2] = (byte)(value >> 8);
        buf[offset + 3] = (byte)value;
    }
}
```

### 原地补丁（dataLen 不变时，仅供参考）

CLI 始终执行完整重建（`ModuleFrameWriter.Rebuild`），不区分原地/重建。以下代码仅作格式参考。

```csharp
/// <summary>
/// 在固定 1024 字节 algori 槽内原地修改参数值。
/// dataLen 不变，不需要重建 ModuleFrame。
/// </summary>
public static void PatchAlgoriParamInPlace(byte[] rawData, string paramName, string newValue)
{
    int off = 4; // 跳过 paramCount (4 bytes BE)
    while (off < rawData.Length - 260 - 1024)
    {
        // 260-byte param name
        var pName = Encoding.UTF8.GetString(rawData, off, 260).TrimEnd('\0');
        off += 260;
        if (pName == paramName)
        {
            // 原地写入新值（1024 字节槽内）
            var valBytes = Encoding.UTF8.GetBytes(newValue);
            int copyLen = Math.Min(valBytes.Length, 1024);
            Array.Clear(rawData, off, 1024);
            Array.Copy(valBytes, 0, rawData, off, copyLen);
            return;
        }
        off += 1024;
    }
}
```

---

## UiParamData TLV 补丁

UiParamData 文件格式为 TLV（Tag-Length-Value），修改字段时必须保持 TLV 结构完整。

### 字段原地修改（val_len 不变）

直接覆盖 value 字节，val_len 和文件大小不变。例如将 `IsReady` 从 False 改为 True：

```python
# IsReady: bool, val_len=1
# False = b'\x00', True = b'\x01'
data[value_offset] = 0x01  # 原地替换，无需其他调整
```

### 字段修改（val_len 变化）

当 value 长度变化时（如把 `DynamicObject` 从 bool false 改为 string `"%Data Record%"`），需要：

1. 修改 val_len（4 字节 BE）
2. 替换 value 内容
3. **截断或扩展文件**（后续所有字段偏移改变）

```python
# 示例：DynamicObject 从 bool(false) → string("%Data Record%")
# 原：val_len=1, value=b'\x00'
# 新：val_len=15, value=b'%Data Record%'

old_val_len = struct.unpack('>I', data[val_len_offset:val_len_offset+4])[0]
new_val = b'%Data Record%'
new_val_len = len(new_val)

# 计算文件大小变化
delta = new_val_len - old_val_len

# 重建文件
new_data = bytearray(len(data) + delta)
# 复制头部（offset 0 到 value 起始位置）
new_data[:value_offset] = data[:value_offset]
# 写入新 val_len
struct.pack_into('>I', new_data, val_len_offset, new_val_len)
# 写入新 value
new_data[value_offset:value_offset+new_val_len] = new_val
# 复制剩余数据（调整偏移）
new_data[value_offset+new_val_len:] = data[value_offset+old_val_len:]
```

### AsShellModule 完整补丁

将 ShellModule 的 UiParamData 转换为 AsShellModule 时，需要：

1. **`DynamicObject` 字段**：bool(false) → string `"%Data Record%"`
2. **追加 5 个 TLV 字段**到文件末尾：

```python
as_fields = [
    (b'[ParamRoot]_%Data Record%Type',           b''),
    (b'[ParamRoot]_%Data Record%IsDisplay',       b'\x01'),
    (b'[ParamRoot]_%Data Record%DynamicObject_%Data Record%_[Child]', b''),
    (b'[ParamRoot]_%Data Record%DynamicObject_%Data Record%_[Child].Content.Value', b''),
    (b'[ParamRoot]_%Data Record%DynamicObject_%Data Record%_[Child].Content.Mapping', b''),
]

for key, value in as_fields:
    # 追加 TLV
    new_data.extend(struct.pack('>I', len(key)))
    new_data.extend(key)
    new_data.extend(struct.pack('>I', len(value)))
    new_data.extend(value)

# fieldCount += 5
new_field_count = struct.unpack('>I', data[8:12])[0] + 5
struct.pack_into('>I', new_data, 8, new_field_count)
```

3. **`InputValueTypes`/`OutputValueTypes` 移至文件末尾**（如有）

### C# 实现

```csharp
/// <summary>
/// UiParamData TLV 解析结果。
/// </summary>
public class UiParamTlv
{
    public int Version { get; set; }
    public int FieldCount { get; set; }
    public List<UiParamField> Fields { get; set; } = new List<UiParamField>();
}

public class UiParamField
{
    public byte[] Key { get; set; }
    public byte[] Value { get; set; }
}

/// <summary>
/// 解析 UiParamData TLV 文件。
/// 格式：magic(4) + version(4) + fieldCount(4) + [keyLen(4)+key+valLen(4)+val]...
/// </summary>
public static UiParamTlv ParseUiParamData(byte[] data)
{
    var result = new UiParamTlv();
    int off = 0;

    // magic: 0x66553322
    var magic = BitConverter.ToInt32(data, 0);
    if (magic != 0x66553322) throw new InvalidDataException($"Bad magic: 0x{magic:X8}");
    off += 4;

    result.Version = ReadInt32BE(data, off); off += 4;
    result.FieldCount = ReadInt32BE(data, off); off += 4;

    for (int i = 0; i < result.FieldCount && off < data.Length; i++)
    {
        int keyLen = ReadInt32BE(data, off); off += 4;
        var key = new byte[keyLen];
        Array.Copy(data, off, key, 0, keyLen); off += keyLen;

        int valLen = ReadInt32BE(data, off); off += 4;
        var val = new byte[valLen];
        Array.Copy(data, off, val, 0, valLen); off += valLen;

        result.Fields.Add(new UiParamField { Key = key, Value = val });
    }

    return result;
}

/// <summary>
/// 将 TLV 结构写回字节数组。
/// </summary>
public static byte[] WriteUiParamData(UiParamTlv tlv)
{
    int total = 12; // magic + version + fieldCount
    foreach (var f in tlv.Fields)
        total += 4 + f.Key.Length + 4 + f.Value.Length;

    var buf = new byte[total];
    int off = 0;

    // magic
    BitConverter.GetBytes(0x66553322).CopyTo(buf, off); off += 4;
    WriteInt32BE(buf, off, tlv.Version); off += 4;
    WriteInt32BE(buf, off, tlv.Fields.Count); off += 4;

    foreach (var f in tlv.Fields)
    {
        WriteInt32BE(buf, off, f.Key.Length); off += 4;
        f.Key.CopyTo(buf, off); off += f.Key.Length;
        WriteInt32BE(buf, off, f.Value.Length); off += 4;
        f.Value.CopyTo(buf, off); off += f.Value.Length;
    }

    return buf;
}

/// <summary>
/// 原地修改 TLV 字段的值（val_len 不变时）。
/// 如将 IsReady 从 false(0x00) 改为 true(0x01)。
/// </summary>
public static void PatchTlvFieldInPlace(byte[] data, string fieldName, byte[] newValue)
{
    var nameBytes = Encoding.UTF8.GetBytes(fieldName);
    int off = 12; // skip header

    while (off < data.Length - 8)
    {
        int keyLen = ReadInt32BE(data, off);
        if (keyLen == nameBytes.Length)
        {
            bool match = true;
            for (int i = 0; i < keyLen; i++)
                if (data[off + 4 + i] != nameBytes[i]) { match = false; break; }

            if (match)
            {
                off += 4 + keyLen; // skip key
                int valLen = ReadInt32BE(data, off);
                if (valLen == newValue.Length)
                {
                    Array.Copy(newValue, 0, data, off + 4, newValue.Length);
                    return;
                }
            }
        }
        // skip key + val
        off += 4 + keyLen;
        int vLen = ReadInt32BE(data, off); off += 4;
        off += vLen;
    }
}

private static int ReadInt32BE(byte[] data, int offset)
{
    return (data[offset] << 24) | (data[offset + 1] << 16)
         | (data[offset + 2] << 8) | data[offset + 3];
}
```

---

## addModule 模板方式

新增模块支持两种方式：

### 模板方式（推荐）
从参考 sol 中复制已有模块的 RawFrameData 字节作为新模块的 rawData，**不需要知道参数列表**。支持任意模块类型。

```json
{ "action": "addModule", "target": "流程名", "paramName": "IMVSBinaryModu",
  "value": "二值化1", "templateFile": "模板.sol", "templateModule": "流程.模板模块" }
```

实现：`SolutionModifier.LoadTemplateRawData` 解析模板 sol → 找到模板模块 → 返回 `RawFrameData` 字节。

### 内置默认值（仅 BlobFind）
不提供 templateFile 时，使用硬编码的 114 参数字典（`BlobFindDefaults`）。

### 关键规则
- 模块 ID：10000 以内 gap-fill，匹配 VM 行为
- VmServer.xml：使用字符串插入（`File.ReadAllText` + `string.Insert`），**不使用 XDocument**（XDocument.Save 改变 XML 声明会导致 VM 拒绝）
- UiParamData：自动创建最小 TLV（GUID + IsReady + Position）

## 语言选择

| 语言 | 推荐场景 | 注意事项 |
|------|---------|---------|
| **C#** | CLI 工具开发、.NET 集成 | 需手动 WriteBE32（无内置 BE 写入）；Hzip.dll 原生处理加密 ZIP |
| **Python 3** | 独立脚本、快速原型 | 仅标准库；`zipfile` 原生支持 ZipCrypto；跨平台 |
| **PowerShell** | Windows 环境快速补丁 | `$bytes[a..b]` 返回 `Object[]` 非 `byte[]`，易踩坑；代码冗长 |

三种语言的核心操作均已在上方给出代码示例。
