# sol 文件格式

`.sol` 文件是标准 ZIP 压缩包，扩展名改为 `.sol`。

## 解压后的目录结构

```
SampleSol.sol
    └── 解压（标准 ZIP）
            └── SolutionFile/
                ├── VmServer.xml
                ├── GlobalScript_0
                ├── ModuleFrame（VM 内部拼写为 MoudleFrame）
                ├── ModuleAttachments/   # 图像附件
                └── UiParamData/
                    └── _<moduleId>+<typeId>+<moduleName>
```

## 加密检测

CLI 通过 Hzip.dll 自动检测加密。用户若未提供密码，直接询问，不要尝试从 DLL 提取或暴力破解。

## 解压方法

### CLI 内置引擎（推荐，零外部依赖）

```bash
# 非加密
VMSolutionParser.Cli.exe parse -f file.sol

# 加密
VMSolutionParser.Cli.exe parse -f file.sol -p password
```

CLI 通过 VM 自带的 Hzip.dll 原生处理加密/非加密 ZIP，无需 Python、7-Zip 等外部工具。

## 压缩特征

- 原始 sol 文件使用 DEFLATE 压缩（compress_type=8），与官方 SolutionConversion 输出一致
- 加密时每个文件体积增加约 12 字节（ZipCrypto 加密头）
