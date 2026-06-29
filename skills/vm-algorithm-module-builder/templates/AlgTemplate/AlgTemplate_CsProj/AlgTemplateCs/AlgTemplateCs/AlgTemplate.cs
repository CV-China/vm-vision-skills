using VM.Core;

/// <summary>
/// 命名空间规则名称：模块名+Cs，生成的类库与命名空间同名
/// </summary>
namespace AlgTemplateCs
{
    /// <summary>
    /// 界面工具类名称：模块名+Tool
    /// </summary>
    public class AlgTemplateTool : VmModule
    {
        public AlgTemplateTool()
        {
            
        }
        /// <summary>
        /// 构造中要传入模块名称
        /// </summary>
        /// <param name="param"></param>
        public AlgTemplateTool(object param) : base(param, "AlgTemplate")
        {
            
        }
    }
}
