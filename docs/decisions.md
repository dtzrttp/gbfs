# 版本与实施决策

决策日期：2026-11-09（Asia/Shanghai）。

## 第一版支持 GBFS v2.3

第一版固定支持 GBFS v2.3。规范依据为 MobilityData 仓库 annotated tag v2.3 指向的 commit SHA 4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8；规范文件 gbfs.md 的 blob SHA 为 9d5a63e45a241b2427a273523d3a1a908eeb0529。tag object SHA 2c323f7c3529980ebdc7b5ae2140754b7ceb93b0 仅用于解析 tag，不能当作 commit SHA。标签解析及无 LICENSE 的直接证据见 evidence/2026-11-09/recheck/v2.3-tag-resolution.txt。规范链接：[固定 v2.3 文本](https://github.com/MobilityData/gbfs/blob/4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8/gbfs.md)。截至本次审计，发布页将 v3.1 标记为 Latest（[v3.1 发布](https://github.com/MobilityData/gbfs/releases/tag/v3.1)），而 README 的版本表仍将 v3.0 标作 Current；这是官方发布与版本表更新不同步。本项目将正式 release tag 作为“最新正式发布版本”的依据。v2.3 则在当前[官方版本表](https://github.com/MobilityData/gbfs/blob/328bacf31d2ea177d9a0dfe55467f55540ac8fab/README.md)中仍为 Supported。

当日最新正式 release 已是 GBFS v3.1，tag 指向 06dddf8d087df8f9c419953c2dc7ce73100e44d8，发布时间为 2026-11-04。该版本是正式版本，不是 RC；本项目不把它错误称为未发布版。但它发布仅 5 天，官方 JSON Schema 仓库提交 01d4cb480410ca234b1d76799daf474b8f839e85 只包含 v3.1-RC3 目录，没有 v3.1 最终目录；官方 Schema 测试夹具也只有 v3.1-RC3，没有 v3.1。官方 JavaScript validator 当前规则文档写明验证上限为 v3.1-RC3，仓库最近推送时间为 2026-05-26。因此 v3.1 的最终规范虽已发布，但最终 Schema、夹具及官方 validator 的同步证据尚不完整。

v2.3 的对照优势：

1. v2.3 是受支持的稳定版本，已有多年使用时间。
2. 官方 Schema 在固定提交中完整提供 13 个 v2.3 文件 Schema。
3. 官方 Schema 仓库包含 v2.3 测试夹具目录；官方 validator 支持 v2.3。
4. MobilityData v3.1 release 快照中的系统目录有 1,277 条记录。对字段 Supported Versions 作逐行子串计数，698 条列有 2.3，577 条列有 3.0，0 条列有 3.1。该数值是目录声明，条目可能同时列出多个版本；它不是逐一请求实时端点后的可用性统计。统计命令和结果见 evidence/2026-11-09/recheck/version-catalog.txt。
5. v2.3 已提供本项目要做的发现文件、系统、站点、车辆、价格和地理围栏常用数据。它使用 free_bike_status.json；vehicle_status.json、manifest.json 与 vehicle_availability.json 属于后续版本，不列入本版范围。

选择 v2.3 的理由是其最终 Schema、validator 与公开夹具已可交叉验证，且官方系统目录的版本声明数量高于刚发布的 v3.1。首版目标是可信的静态校验与清晰诊断，完成性优先于追随最近发布标签。此决策不表示 v2.3 是所有新项目的推荐版本；只定义本项目第一版范围。

## 固定官方资料与许可证

| 资料 | 固定来源 | 实际许可证 / 处理方式 |
| --- | --- | --- |
| GBFS v2.3 规范 | [MobilityData/gbfs commit 4f0cc702](https://github.com/MobilityData/gbfs/blob/4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8/gbfs.md) | 该 commit 根目录没有 LICENSE 文件；README 标记规范版权归 NABSA。不能把后来 v3.1 tag 的 CC BY 3.0 LICENSE 追溯套用到 v2.3。本项目只链接并用自己的话描述规则，不复制规范段落或示例。 |
| v2.3 JSON Schema | [官方 v2.3 Schema 目录](https://github.com/MobilityData/gbfs-json-schema/tree/01d4cb480410ca234b1d76799daf474b8f839e85/v2.3)；固定提交 01d4cb480410ca234b1d76799daf474b8f839e85 | 该提交仓库 [LICENSE](https://github.com/MobilityData/gbfs-json-schema/blob/01d4cb480410ca234b1d76799daf474b8f839e85/LICENSE) 为 Apache-2.0；仓库 About 元数据另写明 Schema 内容 CC BY 4.0。分发原样 Schema 时保留 MobilityData 署名、提交 SHA、上游 LICENSE，并在 NOTICE 中标出 Schema 数据的 CC BY 4.0 声明。 |
| 官方 validator | [MobilityData/gbfs-validator](https://github.com/MobilityData/gbfs-validator)，提交 b734086ccdf93b5acd72bb349c6fda0c9f64fd39 | [LICENSE.md](https://github.com/MobilityData/gbfs-validator/blob/b734086ccdf93b5acd72bb349c6fda0c9f64fd39/LICENSE.md) 为 Apache-2.0。[README](https://github.com/MobilityData/gbfs-validator/blob/b734086ccdf93b5acd72bb349c6fda0c9f64fd39/gbfs-validator/README.md) 与 [RULES](https://github.com/MobilityData/gbfs-validator/blob/b734086ccdf93b5acd72bb349c6fda0c9f64fd39/RULES.md) 作版本/规则参照，不复制实现代码。 |
| Schema 测试夹具 | [testFixtures/v2.3](https://github.com/MobilityData/gbfs-json-schema/tree/01d4cb480410ca234b1d76799daf474b8f839e85/testFixtures/v2.3) | 没有核实到夹具目录独立的再分发许可；第一版不复制真实 feed 或该目录的 JSON。使用项目自行构造的最小合成数据；将来若采用公开真实 feed，先逐条确认运营方数据许可证并保留来源。 |
| MoonBit 依赖 | 本仓库已用版本：moonbitstack/moonschema 0.2.4、moonbitstack/moonurl 0.2.3、moonbitlang/x 0.5.7 | 三者 moon.mod 均声明 Apache-2.0，与本项目 Apache-2.0 兼容。JSON Schema Draft 7、URL 解析、文件 I/O/CLI 在 JS 目标上已随现有实现编译、测试；v2.3 专项兼容性仍须通过阶段测试确认。 |

证据文件：v2.3 的 13 份 Schema 原始字节、blob SHA 和抽取摘要位于 evidence/2026-11-09/recheck/schema-v2.3；规范、Schema、validator 的许可证原文位于 evidence/2026-11-09/upstream。

## 后端与产品边界

- 首要验证后端选 JS + Node.js 24，具体本机版本为 v24.19.0。现有实现已经实际执行格式检查、检查、测试、构建和 CLI 验收；这些只证明现有 GBFS 3.0 代码在此目标工作，不替代 v2.3 迁移后的重新验收。
- Native、Wasm/WASI 及浏览器目标不纳入首版已验证承诺；CI 可在主目标稳定后增加编译矩阵，但不能以编译通过推断 I/O 或路径行为正确。
- 第一版只解析本地目录或用户明确列出的本地 JSON 文件；不联网抓取、不绘制地图、不做调度、支付、用户系统或历史版本兼容。
- Schema 约束按官方规则诊断；跨文件错误、官方 MUST 与 SHOULD、以及本项目启发式警告分开标记。时间新鲜度等没有规范硬性依据的规则只能是明确写明策略的 warning/info。
