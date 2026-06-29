# 字符编码处理

> C++ 源文件编码规则与中文字面量处理策略见 **SKILL.md §J**。
> 本文件仅补充 VM SDK 与 Windows API 之间的**运行时路径编码转换**——即 SetParam 收到 UTF-8 路径后，
> 如何转换为本地 ANSI 路径给 `fopen` / `cv::imread` 等 Windows API 使用。

## 1. SetParam 传入中文的 UTF-8 → ANSI 转换

VM 平台调用 `SetParam` 时，含中文的字符串（如 OpenFile 路径、String 参数）以 **UTF-8** 编码传入。直接用 `fopen` / `cv::imread` 等 Windows ANSI API 会失败。

### 必须转换：用作文件路径时
```cpp
int CAlgorithmModule::SetParam(IN const char* szParamName, IN const char* pData, IN int nDataLen)
{
    if (0 == strcmp("modelPath", szParamName))
    {
        // 原始保留 UTF-8（用于回传给 GetParam）
        m_strModelPathUtf8 = std::string(pData);

        // 转 ANSI，用于本地文件 API
        m_strModelPathAnsi = UTF8toANSI(pData);
    }
    // ...
}

// 实际打开文件时
FILE* fp = nullptr;
fopen_s(&fp, m_strModelPathAnsi.c_str(), "rb");
```

`UTF8toANSI` / `ANSItoUTF8` 在 `common/src/VmModule_IO.cpp` 中提供，模板项目链接此 cpp 后即可使用。

### 不需要转换：仅作字符串保存（不用于文件路径）
```cpp
// String 控件——只是显示/记录用，不当路径
m_strDisplayName = std::string(pData);  // 保持 UTF-8 原样
```

## 2. GetParam 输出中文

`GetParam` 写回 pBuff 时，保持与 SetParam 一致（**UTF-8**）：
```cpp
if (0 == strcmp("modelPath", szParamName))
{
    sprintf_s(pBuff, nBuffSize, "%s", m_strModelPathUtf8.c_str());
}
```

不要用 ANSI 串回写——VM 平台会按 UTF-8 解析。

## 3. OpenCV cv::imread 中文路径方案

`cv::imread` 在 Windows 上**不支持** UTF-8 路径。两种方案：

### 方案 A：先转 ANSI（适用于纯中文路径）
```cpp
std::string ansiPath = UTF8toANSI(pUtf8Path);
cv::Mat img = cv::imread(ansiPath);
```

### 方案 B：用 std::ifstream 读字节后 imdecode（推荐，支持任意字符）
```cpp
std::string ansiPath = UTF8toANSI(pUtf8Path);
std::ifstream fs(ansiPath, std::ios::binary);
std::vector<char> buf((std::istreambuf_iterator<char>(fs)),
                       std::istreambuf_iterator<char>());
cv::Mat img = cv::imdecode(cv::Mat(buf), cv::IMREAD_UNCHANGED);
```

## 4. XML 写入中文

`<DisplayName>` / `<Description>` 等节点含中文：
```xml
<Integer Name="thresholdValue" NameSpace="Standard">
    <Description>阈值</Description>      <!-- 直接写中文，文件 UTF-8 即可 -->
    <DisplayName>阈值</DisplayName>
    ...
</Integer>
```

XML 文件**必须 UTF-8**，否则 VM 解析时会显示乱码。

## 5. 自检

生成完成后用 grep 检查日志接口合规：

```bash
# 检查日志接口是否合规（编码规则见 SKILL.md §J）
grep -nE 'MessageBox|std::cout|std::cerr|std::clog|printf|OutputDebugString' AlgorithmModule.cpp
```

不应出现命中（DLL 入口函数 CreateModule/DestroyModule 内的 OutputDebugStringA 除外，详见 SKILL.md §I）。
