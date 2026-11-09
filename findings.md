# 调研发现

## 查重与环境

- 当前日期 2026-11-09；moon 0.1.20261028，moonc v0.10.18+6c83a7f62，Node v24.19.0。
- GitHub CLI 活动账号、全局/本地 Git 作者身份均为 dtzrttp；email 为 313799694+dtzrttp@users.noreply.github.com。
- 目标子目录有独立 Git 仓库，远程为空，已有 2 个实质原型提交。
- Moon 查询八条均 exit 0；PDDL 是唯一直接 gbfs 命中，实际源码中的含义是 Greedy Best-First Search。
- GitHub .mbt 查询没有 GBFS 数据解析/校验实现；官方校验器、Schema、Java/R 生态包属于非 MoonBit 实现。

## 规范版本

- v2.3 tag object：2c323f7c3529980ebdc7b5ae2140754b7ceb93b0；其目标 commit：4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8，规范文件 blob：9d5a63e45a241b2427a273523d3a1a908eeb0529。固定 Schema 仓库 commit：01d4cb480410ca234b1d76799daf474b8f839e85。
- v2.3 Schema 有 13 个端点文件、testFixtures/v2.3 目录，官方 validator 包含 v2.3。
- v3.1 正式发布 tag commit：06dddf8d087df8f9c419953c2dc7ce73100e44d8，日期 2026-11-04。固定 Schema master 只有 v3.1-RC3，没有最终 v3.1 目录；validator 规则文档上限是 RC3。
- 官方 systems.csv v3.1 tag 快照有 1,277 行；Supported Versions 字段列有 2.3 的 698 行、3.0 的 577 行、3.1 的 0 行。为声明数，部分 Feed 同时列多个版本。
- 选 v2.3 的理由为完整 Schema/夹具/validator 与目录版本声明证据成熟，不因为 v3.1 不是正式版本。

## v2.3 重要规则事实

- 每个 JSON 文件都必须有 last_updated、ttl、version、data；last_updated 是 Unix 秒整数（Schema 最小值 1450155600），ttl 是非负整数，version 固定为 2.3。
- 文件数共 13：gbfs、gbfs_versions、system_information、station_information、station_status、free_bike_status、vehicle_types、system_hours、system_alerts、system_calendar、system_regions、system_pricing_plans、geofencing_zones。
- gbfs.json 按 language key 列 feeds；每项 name/url 必需，要求 system_information，并要求 station_status 或 free_bike_status；若有 station_information，则 station_status 也必需。
- 地理坐标边界为纬度 [-90,90]、经度 [-180,180]；station capacity、数量和价格范围必须按各端点 Schema/规范分别判断。
- free_bike_status 支持车位/车辆类型/价格方案关系；station_information 支持区域；station_status 支持车型分类。映射见 docs/spec-map.md。

## 许可证

- v2.3 规范 tag 不含 LICENSE，README 记版权归 NABSA；不再分发规范文字或示例。
- 固定 Schema 提交的仓库 LICENSE 为 Apache-2.0，同时 About 声明 Schema 为 CC BY 4.0；分发 Schema 时保留来源与两种声明。
- validator LICENSE.md 为 Apache-2.0；只参照规则，不复制实现。
- 官方 fixture 没有独立许可证据；使用合成 fixtures。
- MoonBit 依赖 moonschema 0.2.4、moonurl 0.2.3、x 0.5.7 均声明 Apache-2.0。

## 阶段 2 需验证

- moonschema 对官方 v2.3 patternProperties / contains / if-then、URI/email/date-time、GeoJSON 深层数组的实际行为。
- 完整 schema extraction 与稳定规则码/严重级别映射。
- 文件集合的本地映射，尤其按语言目录组织的发现 URL 与本地文件名匹配。
- UTC 秒时间、新鲜度以及容量总和规则的规范强制性；不明确时采用 warning/info。
