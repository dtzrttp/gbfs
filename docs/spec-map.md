# GBFS v2.3 规范映射

规则以 [GBFS v2.3 规范固定提交](https://github.com/MobilityData/gbfs/blob/4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8/gbfs.md) 和 [官方 Schema 固定提交](https://github.com/MobilityData/gbfs-json-schema/tree/01d4cb480410ca234b1d76799daf474b8f839e85/v2.3) 为准。原样 Schema 保存在 `schemas/v2.3/`。`schema_validation.mbt` 报告 `schema.<关键词>` 和原始 Schema Pointer。`tests/fixtures/v2.3/schema-cases.json` 与 [实际差分记录](evidence/2026-11-09/schema-comparison.json) 列出各端点测试 ID、期望、实际和规则位置。

## 单文件

| 文件 | 字段与规则 | 实现与测试 |
| --- | --- | --- |
| 全部 | 根对象要求 `last_updated`、`ttl`、`version`、`data`。Unix 秒整数、非负 TTL、版本常量 `2.3` | `schema_validation.mbt`，差分用例 `required.<端点>.<字段>`，`v2_3_model_wbtest.mbt` 的错误版本用例 |
| gbfs | 语言分组、发布端点名、URI、必需发布项 | Schema，`valid.gbfs` 和 `discovery.*` |
| gbfs_versions | 版本值和 URI，按版本号递增 | Schema，`version.not_increasing`，`versions.*` 和版本目录单元测试 |
| system_information | 系统 ID、名称、语言、时区及可选联系和许可字段 | Schema，`system.*` |
| station_information | 站点 ID、名称、经纬度，容量非负，停车和租赁选项 | Schema，`station.*` |
| station_status | 状态布尔值、上报时间、可用及禁用车辆和车桩计数、分类计数 | Schema，`status.*` |
| free_bike_status | 车辆 ID、保留及禁用状态、站点或坐标条件、续航和剩余能源 | Schema，`bike.*` |
| vehicle_types | 车型 ID、车型和推进方式枚举、机动类型最大续航条件、附加属性 | Schema，`vehicle.*` |
| system_hours | 用户类型、营业日、开始和结束时刻 | Schema 与规范 Time 类型。接受 24–47 小时，`hours.*` |
| system_calendar | 起止月、日和可选年份的取值 | Schema，`calendar.*` |
| system_regions | 区域 ID 和名称 | Schema，`regions.*` |
| system_pricing_plans | 价格 ID、名称、货币格式、价格、税项、分段费用 | Schema，`pricing.*` |
| system_alerts | 告警 ID、类型枚举、摘要、时间区间和作用对象 | Schema，`alerts.*` |
| geofencing_zones | FeatureCollection、要素、几何和地理围栏规则 | Schema，`geo.*` |

## 快照关系与诊断

| 规则码 | 严重级别 | 依据与处理 | 实现与证据 |
| --- | --- | --- | --- |
| `feed.missing`、`feed.unsupported` | error | 规范 Files 表和本项目固定版本。发现文件及系统信息必需。运营模式参数启用相应的条件端点 | `snapshot_v23.mbt`，`cmd/main/main_wbtest.mbt` |
| `consistency.discovery.*` | error | 发现文件按 `system_information.language` 选择语言。离线输入约定要求端点名与所选语言清单对应且无歧义 | `consistency.mbt`，`consistency_wbtest.mbt` 的发现文件用例 |
| `consistency.id.contains_space`、`consistency.id.duplicate` | error | Field Types 的 ID 规则。定义集合内 ID 唯一，已检查的定义和引用 ID 不含空格 | `consistency.mbt`，重复 ID 与空格用例 |
| `consistency.feed.missing_station_*`、`consistency.station_status.unknown_station`、`consistency.station_information.missing_status` | error | 两个站点端点互相对应，有桩端点成对 | `consistency.mbt`，站点正反例与 10 个 ID 变更样例 |
| `consistency.station.unknown`、`consistency.region.unknown`、`consistency.vehicle_type.unknown`、`consistency.pricing_plan.unknown` | error | 站点、区域、车型、价格和告警字段定义中的引用关系。检查单值、数组与站点容量映射键 | `consistency.mbt`，完整引用快照及未知引用用例 |
| `consistency.vehicle_type.required`、`consistency.vehicle_types_available.required`、`consistency.motor_range.required`、`consistency.docks_available.required` | error | 车型文件已定义、对应车型有动力或站点有明确有限容量时，检查相关条件字段 | `consistency.mbt`，车型、续航和容量用例 |
| `consistency.bike_count.sum_mismatch`、`consistency.dock_count.sum_mismatch` | warning | 规范 station_status 章节建议按车型统计之和与总量一致 | `consistency.mbt`，车型数量用例及真实快照 |
| `consistency.station.capacity_exceeded` | warning | 容量与可用车辆数量的合理性提示。仅用于提供容量且非代客停放的站点 | `consistency.mbt`，容量用例及 Linz 快照 |
| `timing.stale`、`timing.long_cache`、`timing.future_update`、`timing.report_after_update` | warning | 规范 Data Latency 建议近实时数据在 5 分钟内。长 TTL、未来发布时间和上报顺序是本项目提示 | `timing.mbt`，时间边界用例 |
| `json.invalid`、`json.too_large`、`input.total_too_large`、`report.truncated` | error | 项目输入和报告资源约定 | `parser.mbt`、`snapshot_v23.mbt`、`report.mbt`，解析、总量与截断单元测试 |

跨文件检查在提供的端点通过单文件检查后执行，以避免无效字段引发误报。诊断由 `report.mbt` 按文件、Pointer、规则码等键排序。无桩必需条件可显式指定。输入可有多语言发现项，一次校验一个本地语言组。

## 当前边界

单快照无法验证历史 ID 持久性或车辆 ID 轮换、设备可访问性、外链或刷新频率。有限容量或特殊车桩类型未在数据中明确时，工具无法判定相应的条件必填规则。GeoJSON 检查覆盖 Schema 结构，几何拓扑、相交、覆盖和地理语义仍待扩展。货币检查采用 Schema 的格式规则。程序还未覆盖全部正文条件，例如深链接应用商店信息与端点之间的条件关系。版本范围为 v2.3。
