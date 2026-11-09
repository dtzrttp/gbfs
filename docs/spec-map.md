# GBFS v2.3 规范映射

本文件把所选版本的规范/Schema 约束映射到首版实现责任与测试。规范 tag v2.3 指向 commit SHA 4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8，gbfs.md blob SHA 为 9d5a63e45a241b2427a273523d3a1a908eeb0529；固定官方 JSON Schema 提交 SHA 为 01d4cb480410ca234b1d76799daf474b8f839e85。阶段 1 先建立映射和范围，表中代码/测试位置是首版目标，v2.3 迁移完成后将补上实际行号、用例 ID 与差异结论。

## 所有文件共用的外层结构

| 规则 | v2.3 来源 | 诊断与目标位置 | 测试目标 |
| --- | --- | --- | --- |
| JSON 顶层为对象；last_updated、ttl、version、data 必填 | 每个 v2.3 JSON Schema 的根 required 列表 | schema_validation.mbt；稳定码 GBFS-SCHEMA-REQUIRED / GBFS-SCHEMA-TYPE | tests/schema/common_wbtest.mbt：缺字段、错误类型正反例 |
| last_updated 是 Unix 秒整数，Schema 下限为 1450155600；ttl 是非负整数 | 每个 Schema 根属性 | Schema 错误；跨文件新鲜度只能作为单独 warning，不能替代规范错误 | common_wbtest：字符串时间、负 TTL、有效时间戳 |
| version 必须等于字符串 2.3 | 每个 Schema 的 version.const | 错误；固定版本，不从输入自动切换规范 | common_wbtest：2.2、3.0 和未知版本拒绝 |
| JSON 不可解析、重复键、超限输入必须给出定位诊断 | 项目输入安全边界，不宣称是 GBFS 规范字段 | parser.mbt：源文件、JSON Pointer（若可恢复）、稳定错误码 | tests/parser_wbtest.mbt：损坏 JSON、重复键、嵌套与字节上限 |

## 官方 v2.3 文件和字段映射

下表列出官方提交中全部 13 个 Schema 文件。Schema 校验器以未修改的上游文件验证必填字段、类型、枚举、格式、数值范围、模式、数组长度及条件约束；源文件原样副本和每文件 blob SHA 保存在 evidence/2026-11-09/recheck/schema-v2.3。详细抽取结果见该目录 field-rules.txt 与 summary.json。

| 文件 | Schema 中 data 的主要必需字段与已核实约束 | 实现责任 | 测试目标 |
| --- | --- | --- | --- |
| gbfs.json | 每种 language key 下有 feeds；feed name 为 v2.3 的 13 个端点之一、url 为 URI；必须包含 system_information，且 station_status / free_bike_status 至少一个；若列 station_information 则同时列 station_status | model/parser 读取发现清单；schema_validation.mbt 校验结构；consistency.mbt 对照目录/显式文件集 | tests/fixtures/discovery：缺 system_information、缺状态文件、列出的文件缺失、多出未声明文件、URI 无效 |
| gbfs_versions.json | versions；每项 version 与 url 必填 | Schema 校验版本枚举及 URI | tests/schema/gbfs_versions_wbtest.mbt |
| system_information.json | system_id、language、name、timezone；language 模式为两/三位小写语言码，可带两位大写地区码；URI、date、email 格式及 timezone 枚举由 Schema 限定 | Schema；跨文件检查文件语言与发现项时仅比较规范可确认的值 | tests/schema/system_information_wbtest.mbt |
| station_information.json | stations；station_id、name、lat、lon 必填；坐标分别限制在 [-90, 90] 与 [-180, 180]；capacity 非负；可选 region_id、vehicle_capacity、vehicle_type_capacity、停车/服务属性和租赁 URI | Schema；consistency.mbt 建立 station_id / region_id 索引 | tests/schema/station_information_wbtest.mbt 与 tests/consistency_wbtest.mbt |
| station_status.json | stations；station_id、num_bikes_available、is_installed、is_renting、is_returning、last_reported 必填；可用数量非负；分类车辆/车桩数量非负 | Schema；站点 ID 与 station_information 对照；容量关系必须依原文的 MUST/SHOULD 分类，不根据字段名推导硬错误 | tests/schema/station_status_wbtest.mbt、跨文件引用/容量正反例 |
| free_bike_status.json | bikes；bike_id、is_reserved、is_disabled 必填；若不是停靠站引用，Schema 要求 lat 与 lon 成对或 station_id；坐标范围、current_range_meters 非负、current_fuel_percent 0..1 | Schema；bike_id 去重；station_id/home_station_id、vehicle_type_id、pricing_plan_id 对照对应端点 | tests/schema/free_bike_status_wbtest.mbt、引用 ID 正反例 |
| vehicle_types.json | vehicle_types；vehicle_type_id、form_factor、propulsion_type 必填；form_factor/propulsion_type/return_constraint 和配件使用官方枚举；各容量、续航、功率等数值限制由 Schema 指定 | Schema；vehicle_type_id 索引，与车辆/站点分类引用核对 | tests/schema/vehicle_types_wbtest.mbt、未知车型反例 |
| system_pricing_plans.json | plans；plan_id、name、currency、price、is_taxable、description 必填；price 非负；分段 per_km_pricing/per_min_pricing 字段和非负范围由 Schema 定义；currency 还需按规范核对 ISO 4217 语义 | Schema 先验证形状；validate.mbt 做规范要求的货币格式；一致性检查 free_bike_status 中的 pricing_plan_id | tests/schema/system_pricing_plans_wbtest.mbt、货币及价格计划引用正反例 |
| system_regions.json | regions；region_id、name 必填 | Schema；region_id 去重，station_information.region_id 有值时核对 | tests/schema/system_regions_wbtest.mbt 与跨文件引用反例 |
| geofencing_zones.json | geofencing_zones GeoJSON 对象；FeatureCollection、Feature、geometry 与 properties/rules 的字段和枚举由 Schema 校验；Polygon 坐标层级/最小点数按 Schema | Schema；坐标数值与 GeoJSON 结构；不添加地图或空间覆盖判断 | tests/schema/geofencing_zones_wbtest.mbt：错误几何、缺字段、非法规则枚举 |
| system_alerts.json | alerts；alert_id、type、summary 必填；type 官方枚举；时间范围、URL、station_ids、region_ids 按 Schema | Schema；可选站点/区域引用检查 | tests/schema/system_alerts_wbtest.mbt 与引用反例 |
| system_calendar.json | calendars；start_month、start_day、end_month、end_day 必填；月份 1..12、日期 1..31；年份格式依 Schema | Schema；日历日期实际是否存在的附加检查须由规范确认后再加 | tests/schema/system_calendar_wbtest.mbt：范围、闰日与无效日期 |
| system_hours.json | rental_hours；user_types、days、start_time、end_time 必填；列表长度与枚举、HH:MM:SS 模式按 Schema | Schema；时间段交叉规则需找到明确官方来源，否则只可做提示 | tests/schema/system_hours_wbtest.mbt |

注意：v2.3 没有 vehicle_status.json 或 manifest.json；对应设备文件为 free_bike_status.json。不得把 v3.0/v3.1 的字段套进 v2.3。

## 跨文件规则映射

| 规则 | 来源与严重级别原则 | 目标位置 | 测试目标 |
| --- | --- | --- | --- |
| 发现文件声明的 feed 与本地端点文件应一致 | gbfs.json feeds 列表与离线输入清单；本地缺少已声明文件为 error，未声明的 JSON 文件按 CLI 策略作为 error 或明确忽略，不静默混入 | consistency.mbt | 一致、缺文件、多文件、文件名/发现项错误 |
| station_status.station_id 必须能在 station_information 中找到 | v2.3 两端点的 station_id 数据关联 | consistency.mbt | 已知 ID 接受、未知 ID 拒绝 |
| station_information.region_id、free_bike_status 的 station/home_station ID 有值时必须引用存在实体 | 只有规范确认其关联语义后作为 error；可选字段缺省不能报错 | consistency.mbt | 已知、未知、空值、未提供目标文件 |
| free_bike_status.vehicle_type_id 与 station_status 分类字段的车型 ID 必须来自 vehicle_types；pricing_plan_id 有值时引用 system_pricing_plans.plan_id | 规范字段引用关系；无目标文件时按 feed 声明条件诊断，不猜测 | consistency.mbt | 已知、未知、大小写差异和缺省目标端点 |
| 各实体 ID 在其定义集合中唯一 | v2.3 ID 字段含义与官方 validator 规则；稳定错误码 | consistency.mbt | 重复 station_id、bike_id、region_id、vehicle_type_id、plan_id |
| 可用数量与站点容量不相容 | 只有原规范/官方 validator 明确要求时用 error；官方建议用 warning；项目自定义合理性判断带规则来源和策略名 | consistency.mbt | 容量边界、车数/车桩合计、分类合计与未知容量 |
| 时间戳、TTL 与当前时间或其他端点的偏差 | Schema 先检查 Unix 时间戳与非负 TTL。时钟偏差/陈旧性并非未经核实就升级为规范错误；若实现，显式配置参考时间和阈值，作为 heuristic warning | validate.mbt | 固定 now、正负边界、无配置时不发策略警告 |
| 错误报告 | 项目输出约定 | diagnostic.mbt/report.mbt：稳定错误码、error/warning/info、file、JSON Pointer、actual、expected、suggestion、规则来源；按 file/pointer/code 确定性排序 | tests/report_wbtest.mbt：JSON 字段、排序和转义 |

## 不支持项

| 范围 | 处理 |
| --- | --- |
| GBFS v1.x、v2.0–v2.2、v3.0、v3.1 及未来版本 | 首版只接受 v2.3；未知版本给出明确错误。 |
| v3.0 的 vehicle_status、manifest；v3.1 的 vehicle_availability | 不属于 v2.3 Schema；不兼容性在 README 支持矩阵解释。 |
| PASERK/JWT/支付/租车/调度/地图/持续运行爬虫/数据库 | 不实现。 |
| 运营方私有约定或自创字段规则 | 除非有规范来源并写入映射，否则忽略或按额外属性策略报告，不能冒称官方要求。 |

阶段 2 将把表中目标文件/测试路径调整为真实代码结构；阶段 3–5 给每条落地规则补充稳定码、实际路径、用例 ID、预期与实际结果。
