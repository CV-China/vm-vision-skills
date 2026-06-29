# VmServer.xml 节点参考

VmServer.xml 是方案拓扑描述文件，包含模块列表、连线关系、参数订阅、流程配置等全部结构信息。

## 节点清单

| 节点 | 内容 |
|------|------|
| `ModulesInfo/ModuleBase` | 所有模块列表（含 Type、DisplayName、Guid） |
| `ModuleCommonConnect` | 模块执行顺序连接（FrontModules/FollowingModules） |
| `ModuleSubscribe` | 输入端口参数订阅关系 |
| `ProceduresInfo/ProcedureBase` | 流程列表 |
| `ProceduresInfo/ProcedureInsideModules` | 流程内模块归属 |
| `GroupSonInfo` | Group 内模块归属（Son 可以是另一个 Group，即嵌套 Group） |
| `DynamicParamInfo` | Group 输出参数到内部模块 algori 参数的映射（DynamicIO 机制） |
| `ContainerRelateModules` | LocalVariableModule / ProcedureComm 与其容器的关联 |
| `GlobalScriptInfo` | GlobalScript 文件名映射 |

## ModuleBase

```xml
<Module Index="2" Name="ShellModule" Type="0" IsSlave="0"
        DisplayName="脚本1" EnableModule="1" EnableCallBack="1"
        Guid="4A5F695B..." />
```

| 属性 | 说明 |
|------|------|
| Index | moduleId，全局唯一 |
| Name | 模块类型名（内部标识） |
| Type | 模块类型枚举（见 modules.md） |
| DisplayName | 用户可见名称 |
| IsSlave | 是否从模块 |
| EnableModule | 是否启用 |
| EnableCallBack | 是否启用回调 |
| Guid | 逻辑层 GUID（VmServer GUID） |

## ModuleCommonConnect

```xml
<Module Index="2">
    <FrontModules>
        <Front Index="4" />
    </FrontModules>
    <FollowingModules>
        <Following Index="0" />
    </FollowingModules>
</Module>
```

连线定义执行顺序，不是数据流向。数据流向由 ModuleSubscribe 定义。

## ModuleSubscribe

```xml
<Subscribe Relation="2 . %in0% . 4 . CaliperEdgePairWidth . 0 . 0 . All . 1" />
```

8 字段格式详解见 connections.md。

## ProcedureBase

```xml
<Procedure Index="10000" DisplayName="相机标定"
           ShieldGlobalCtrl="0" ContinueExecuteTimGap="100"
           StopWhenNG="0" RunTimeout="0" />
```

## ProcedureInsideModules

```xml
<Procedure Index="10000">
    <Inside Index="0" />
    <Inside Index="2" />
</Procedure>
```

## ContainerRelateModules

```xml
<Module Index="24013" Type="25" Name="LocalVariableModule"
        ContainerId="10013" ContainerType="1" />
<Module Index="26013" Type="26" Name="ProcedureComm" DisplayName="流程通信"
        ContainerId="10013" ContainerType="1" />
```

## DynamicParamInfo

```xml
<DynamicParamInfo>
    <Object Index="21004">
        <DynamicParam ParamName="%根部圆弧ROI1%">
            <Module Index="103" ParamName="RoiType" />
        </DynamicParam>
    </Object>
</DynamicParamInfo>
```

## GroupSonInfo

```xml
<Group Index="21000">
    <Son Index="40" />
    <Son Index="42" />
</Group>
```

Son 可以是普通模块或另一个 Group（嵌套 Group）。

## GlobalScriptInfo

VM 内部 XML 节点名为 `GlobalSriptInfo`（缺少 c），此处使用正确拼写。

```xml
<GlobalScriptInfo>
    <Script Name="GlobalScript_0" />
</GlobalScriptInfo>
```
