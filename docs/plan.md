# GBFS v2.3 静态校验器开发计划

更新日期：2026-11-09（Asia/Shanghai）。本计划依据项目完整需求和阶段 1 的新证据。仓库中已有的两个提交实现的是 GBFS 3.0 六端点原型；本轮选定 v2.3 后，将以本文件为准迁移并补齐覆盖，不把旧原型范围当成最终功能。

## 范围

项目暂名 gbfs.mbt，包名 dtzrttp/gbfs。交付本地离线工具：读取一个目录或显式列出的本地 JSON 文件，按 GBFS v2.3 官方 Schema 校验单文件结构，并对站点、车辆类型、价格计划、区域、发现清单等关系做跨文件检查；输出有稳定顺序、稳定错误码、严重级别、文件名、JSON Pointer、实际值、期望规则和修复建议的文本或 JSON 报告。

本版支持官方 v2.3 的 13 个文件：gbfs、gbfs_versions、system_information、station_information、station_status、free_bike_status、vehicle_types、system_hours、system_alerts、system_calendar、system_regions、system_pricing_plans、geofencing_zones。v2.3 使用 free_bike_status；不接受 vehicle_status、manifest 或 vehicle_availability。未知版本清楚报错，不自动按令牌/输入内容切换规则。

不实现联网抓取、地图、路线、调度、支付、租车、账户、长期爬虫或数据库。不把 JWT 或 GBFS 之外的规则混进首版。

## 依赖与后端

| 用途 | 当前候选及许可证 | 现有验证 | 迁移验收 |
| --- | --- | --- | --- |
| JSON Schema Draft 7 | moonbitstack/moonschema 0.2.4，Apache-2.0 | 当前 v3.0 Schema 已在 JS 目标跑过；库提供 Draft 7 和格式断言 | 对 v2.3 的条件字段、patternProperties、contains、if/then、GeoJSON 数组、date/email/URI 等实际 Schema 做差分测试；缺支持时先记录再决定替代 |
| URL/URI 格式 | moonbitstack/moonurl 0.2.3，Apache-2.0 | 已被上层 Schema/当前实现使用，JS 目标编译测试通过 | 只校验规范中声明的 URI 格式；除非规范要求，不追加网络连通性请求 |
| 文件 I/O 与命令行适配 | moonbitlang/x 0.5.7，Apache-2.0 | 当前 Node JS CLI 已实际运行 | 扩展显式文件列表输入并测试路径、UTF-8、I/O 错误 |
| JSON 解析 | MoonBit 标准 JSON API | 当前实现可解析并诊断 v3.0 文件 | 核对重复键、深度、字节数与错误位置；不把 JSON 解码成功当成 Schema 校验成功 |

主目标暂选 MoonBit JS + Node.js 24。实际本机版本为 moon 0.1.20261028、moonc v0.10.18+6c83a7f62、Node.js v24.19.0。此前运行过的命令为 moon fmt --check、moon check --target js --deny-warn、moon test --target js --deny-warn、moon build --target js --deny-warn；工具链和参数已核实。旧实现的 9 个测试通过不代表 v2.3 已通过；迁移后必须重跑并保存新结果。Native、Wasm/WASI、浏览器目标保持未验证，不能从 CI 编译推断其文件访问行为。

## 模块与 API 草案

- model：GBFS v2.3 的版本常量、输入文件、端点名和公共报告模型；不让任意版本字符串控制 Schema。
- parser：本地路径读取、UTF-8/JSON 解码、重复键与资源边界；不负责跨文件规则。
- validate：固定 v2.3 Schema、单文件硬规则、带来源的启发式提示。
- consistency：发现文件与实际文件、站点/车辆/车型/价格/区域引用、数量关系。
- report：诊断模型、稳定排序、文本和 JSON 序列化。
- cli：目录和显式文件列表输入、参数解析、退出码；不联网。

公开库入口草案为 validate_directory 与 validate_files；两者都显式接收本地输入，返回诊断报告或输入错误。具体 MoonBit 类型签名在阶段 2 根据实际工具链的 JSON、FS、CLI API 核实后冻结。不得把未验证数据类型与校验成功模型混用。

每条规则有永久、不复用的错误码；严重级别为 error/warning/info。规范 MUST 违反产生 error，SHOULD 产生 warning；推断规则另标注为 heuristic。报告对每个诊断提供文件、JSON Pointer、actual、expected、建议和直接规范/Schema来源，并按文件、路径、码排序，不依赖哈希表迭代。

## 阶段与验收

### 阶段 1：查重、范围、规范映射和选择

- 8 条 Moon 查询、Mooncakes 模块索引与 GitHub 仓库/README/MBT 源码查询均已执行；没发现同题 MoonBit 实现。
- 核对 v2.3 与当前正式版本 v3.1 的 release、Schema、夹具、validator、目录版本记录及许可证。
- 交付 docs/dedup.md、docs/decisions.md、docs/spec-map.md、docs/plan.md；真实提交后阶段 1 完成。

### 阶段 2：模型、解析、报告与 CLI

- 原样导入固定提交的 13 份官方 v2.3 Schema；保留 SHA、许可证、署名，生成过程可复查。
- 定义模型/诊断类型；目录或显式文件列表均能离线读取。
- 限制文件字节数、JSON 深度、文件数和诊断数量；拒绝无效 UTF-8/JSON，保留可恢复的位置。
- 完成稳定文本/JSON 输出和参数错误、输入错误、数据错误的退出码区分。
- 验收：最小有效/无效目录；每类解析错误均可定位；无联网路径。

### 阶段 3：Schema 与单文件规则

- 对 13 个文件的官方 Schema 逐项映射 required/type/format/enum/pattern/range/condition。
- 为每条硬规则准备正例和反例；source license 不清楚的 feed 不提交，使用自行构造 fixtures。
- 明确 ISO 4217 货币代码的来源与版本；语言标签、时间格式及 GeoJSON 按 v2.3 原文界定。
- 验收：所有已声明单文件规则有稳定码、来源、路径、实际/期望和修复建议；官方 Schema 不修改。

### 阶段 4：跨文件一致性

- 与 gbfs.json 的发现项和本地文件集合对齐。
- 建立 station_id、bike_id、vehicle_type_id、region_id、plan_id 索引，做引用与唯一性检查。
- 容量/分类数量等关系逐项按官方 MUST/SHOULD 设严重级别；不能从“看起来合理”升级成 error。
- TTL、last_updated 与其他端点的时间检查区分规范硬规则与显式策略提示。
- 验收：所有关联有成对正反例，报告排序稳定；无目标文件时按发现清单条件给出准确结果。

### 阶段 5：差分、样例、属性测试、文档和 CI

- 对一组不修改的 JSON 输入运行本项目与官方 v2.3 Schema validator，对差异逐项记原因。
- 至少覆盖官方适用夹具；不复制夹具的许可不明 feed，优先采用合成输入。
- 采用有记录的随机字段删除/类型替换/ID 打乱健壮性测试；称为随机变更测试，不夸称完整 fuzzing。
- README 中文说明支持矩阵、安装、CLI/API、JSON 示例、规则、查重、差分结果、限制和 3 个应用场景。
- 用当前 MoonBit 实际命令配置 CI：格式、检查、测试、构建；CI 与本地目标一致。
- 选择真正可用的公开 GBFS feed 时，先核实该 feed 和数据许可证；无清楚授权则不入库。
- 发布前复核至少 10 个有真实内容的功能/测试/文档提交；按逻辑交付，不拆空提交、不机械凑数。

## 公开仓库与提交

目标 GitHub 账号为 dtzrttp。当前独立本地仓库远程为空；本地已有 2 个原型提交，作者均为指定账号。公共远程在首版验收完成后通过活动账号创建和推送；此前不使用其他 GitHub 身份提交，也不向黑客松报名系统写入内容。

## 当前阻塞与风险

- 真正阻塞项：无。账号清楚、MoonBit 已安装、公开查重无同题、v2.3 Schema 与可用依赖存在。
- 许可证注意：GBFS v2.3 固定 tag 本身无 LICENSE 文件；仅依据事实和字段名实现、不复制规范文字或示例。Schema 同时存在仓库 Apache-2.0 LICENSE 与 CC BY 4.0 内容声明，分发 Schema 时分别保留说明和署名。官方测试夹具不单独再分发。
- 版本注意：当前仓库的既有代码是 v3.0 原型；切换到 v2.3 会更换发现文件结构、时间戳表示、free_bike_status 与端点集，不能通过改 README 冒充完成迁移。
- 规则注意：容量相等、时间新鲜度等业务直觉需先查原文和官方 validator；没有 MUST 的只可作为 warning/info。
- 身份注意：GitHub 插件连接显示 08170406，但 gh CLI 活动账号及 Git 提交身份均为 dtzrttp。远程写操作只通过已核实的 CLI 活动账号进行。

## 2026-11-09 开发状态

- 阶段 1 已完成并提交：`31f8b32`。
- 阶段 2 基础已实现：`model.mbt` 固定 v2.3 版本与 13 个端点；`parser.mbt` 以 `UntrustedDocument` 标记尚未校验的 JSON，并限制 UTF-8 输入字节、嵌套深度与重复键；`diagnostic.mbt` / `report.mbt` 提供 error/warning/info、实际值、期望、建议、来源和稳定排序；CLI 可读目录或显式文件列表。
- 阶段 3 已接入 `schemas/v2.3/` 下全部官方 Schema；来源提交 SHA 与各文件 Git blob SHA 均可复核。`schema_validation.mbt` 目前由固定 Schema 生成验证，`v2_3_model_wbtest.mbt` 覆盖 13 个合成最小正例、版本、坐标与枚举负例。所有单项规则还未逐一成对测试，也尚无官方 validator 差分。
- 当前 `validate_snapshot` 只校验文件 Schema 和入口文件存在性，**尚未执行跨文件引用/数量关系检查**；CLI 文案如实标记这一限制。
- 2026-11-09 阶段验证：`moon fmt --check`、`moon check --target js --deny-warn`、`moon build --target js --deny-warn`、Schema 嵌入一致性检查、CLI 集成验证均退出码 0；`moon test --target js --deny-warn` 为 23/23。目录模式 JSON 报告返回 0 错误。完整输出见 `docs/evidence/2026-11-09/phase2-validation.txt`。
- 旧 v3.0 原型素材保留在历史目录中，不属于当前活动支持路径。一个混合递归删除命令被自动审核拒绝后，未重试该批量操作；活动实现改为 v2.3 文件，不依赖清理旧目录才能继续。
