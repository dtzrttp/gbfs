# 开发记录

## 2026-11-09

### 启动与阶段 1 调研

- 检查独立仓库、分支、无远程、已有两个提交，作者均为 dtzrttp。
- 核实全局和仓库级 Git 身份，以及 GitHub CLI 活动账号 dtzrttp。
- 核实 MoonBit、moonc 和 Node 版本；基线 JS 检查/格式/测试/构建结果见 evidence/2026-11-09/validation.txt。
- 实际执行 8 条指定 Moon 搜索，完整输出与退出码写入 docs/evidence/2026-11-09/recheck/moon-search-full.txt。
- 实际执行 5 条 GitHub 仓库查询及 5 条 .mbt 源码查询，完整 JSON/退出码写入 docs/evidence/2026-11-09/recheck/github-search-full.txt。
- 检查 PDDL 歧义命中 README、search.mbt、search_wbtest.mbt；确认其实现贪心最佳优先规划，不是 GBFS feed 工具。
- 比较 v2.3 和最新正式 v3.1，选择 v2.3；取得 13 份原始 v2.3 Schema、blob SHA、字段摘要及官方系统目录版本统计。
- 实际读取 v2.3、Schema、validator 的许可证线索；不分发许可证不明的 feed 夹具。
- 写入 docs/dedup.md、docs/decisions.md、docs/spec-map.md、docs/plan.md。阶段 1 文档待审查后提交。

### 下一步

- 做一次文档/来源/链接与 Git diff 检查并提交阶段 1。
- 然后开始 v2.3 模型、解析器、资源限制、报告结构和文件列表 CLI；此后按阶段运行用户要求的验证。
