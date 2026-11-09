# GBFS 数据校验工具启动计划

2026-11-09（北京时间）。项目暂名 `gbfs.mbt`，使用独立目录，提交身份为 `dtzrttp`。

- 查重覆盖 Mooncakes 模块及子包摘要、GitHub 仓库名称和描述、MoonBit 源码关键词。
- 固定一个已发布 GBFS 版本及其 Schema，逐项核对端点与跨文件校验规则。
- 将单文件校验、数据关联检查和本地 CLI 分开。诊断包含文件名、JSON Pointer、稳定规则代码及严重性。
- 以官方样例、格式反例、跨文件反例和 CLI 退出码验证首版。

## 首版范围

GBFS 3.0，支持 `gbfs`、`system_information`、`station_information`、`station_status`、`vehicle_types`、`vehicle_status`。选择 3.0 是因为有正式发布的配套 Schema。固定规范提交 `457cb71121348ad6c07384b7743ea7df994a4ebb`，固定 Schema 提交 `01d4cb480410ca234b1d76799daf474b8f839e85`。 [规范](https://github.com/MobilityData/gbfs/blob/457cb71121348ad6c07384b7743ea7df994a4ebb/gbfs.md) · [Schema](https://github.com/MobilityData/gbfs-json-schema/tree/01d4cb480410ca234b1d76799daf474b8f839e85/v3.0)

选用既有的 Draft 7 校验依赖处理原始 Schema，在 MoonBit 中实现 GBFS 专有规则。CLI 从本地目录读取规范名文件，URL 只做数据校验。离线校验避免依赖运营商网络状态。首个验证目标为 JS 后端与 Node.js。

1. 用原样 Schema 验证必填项、类型、格式、范围、枚举与条件，报告失败路径。
2. 对站点和车辆唯一 ID 建索引，检查发现文件与实际文件、站点信息与状态、车辆类型与状态字段之间的关系。把规范的 MUST 与 SHOULD 分别映射为错误和警告。
3. 交付离线 CLI 和文本、JSON 两种报告。区分校验失败和 CLI/I/O 错误，提供官方样例、可运行的有效与无效快照。
4. 运行格式检查、类型检查、单测、构建与 CLI 端到端验证。以实际验证范围记录后端及剩余限制。

## 实施记录

- 公开查重通过，详见 [查重记录](dedup.md)。
- 初试 `bobzhang/jsonschema@0.1.2` 在本机工具链报 18 个 trait 编译错误。选用 `moonbitstack/moonschema@0.2.4` 的 Draft 7 校验和格式断言，文件 I/O 使用 `moonbitlang/x@0.5.7`。本地安装遇到 MoonBit 用户缓存写入限制，经授权后完成。
- 规范示例和 Schema 存在一处可复现差异。保留发现文件示例原样，由 CLI 回归验证其预期拒绝。 [规则映射](spec-map.md)
- 独立评审复现了 URI 放宽、实体车桩条件必填与 CLI 参数分类问题。发现文件用 `moonbitstack/moonurl@0.2.3` 补充 HTTP(S) URL 约束，站点规则核对实体车桩、车型限制和代泊站豁免，CLI 区分未知端点参数并报告实际文件路径。
- 首版验证目标为 Windows 上的 JS 后端与 Node.js 24。仓库含 Ubuntu CI 配置，实际运行结果以 GitHub 工作流记录为准。
