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
- 写入 docs/dedup.md、docs/decisions.md、docs/spec-map.md、docs/plan.md。阶段 1 已由 `31f8b32` 提交。

### 阶段 2 与单文件 Schema 开发

- 新增固定 v2.3 端点清单、`UntrustedDocument`、UTF-8 字节数/64 层嵌套/重复键边界、error/warning/info 诊断字段与稳定排序。
- CLI 支持目录和显式文件列表；`parse` 命令明确只解析 JSON，`check` 对固定 v2.3 Schema 做离线校验。
- 从官方固定提交复制 13 份 Schema 至 `schemas/v2.3/`，逐文件 Git blob SHA 对比为 13/13；嵌入源由 `node tools/embed-schemas.cjs --check` 复核。
- 新增合成最小结构测试覆盖 13 个 Schema，另测 v2.3 时间戳/版本、坐标边界、车辆形式枚举和 v3.0 端点拒绝。
- 2026-11-09 实际运行 `moon test --target js --deny-warn`：23/23 通过；`moon fmt --check`、`moon check --target js --deny-warn`、`moon build --target js --deny-warn`、Schema 嵌入检查、CLI 集成验证均退出码 0。目录模式 JSON 示例返回 0 错误。完整输出见 `docs/evidence/2026-11-09/phase2-validation.txt`。跨文件检查和官方工具差分尚未完成。
- 在一次混合递归删除命令上，自动审核因目标同时包含代码/测试文件而拒绝；没有再次运行该命令，旧 v3.0 原型素材保留但从当前活动路径退出。

### 阶段 3 至 5

- 单文件规则接入 13 份原样 Schema，补充跨午夜营业时间和版本目录递增规则。Ajv 差分 96 个，94 个一致，2 个预期差异，0 个意外差异。
- 跨文件校验支持发现清单、双向站点对应、区域/车型/价格/车辆引用、条件字段、容量和时间。两项运营模式可显式选择。
- 固定种子变更 30/30，真实快照运行 2 份，详见 docs/real-feed-validation.md。
- 本机 MoonBit JS 测试 35/35，CLI 集成和构建通过。旧 v3.0 原型留档，当前入口固定 v2.3。
