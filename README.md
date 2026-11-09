# gbfs.mbt

MoonBit 编写的 GBFS（General Bikeshare Feed Specification）离线静态校验工具。首版范围固定为 **GBFS v2.3**，读取运营方本地 JSON 文件，使用 MobilityData 固定提交中的 13 份官方 JSON Schema 进行单文件结构校验，并以确定顺序输出诊断。

> 开发状态：正在完成首版。当前已接入全部 13 个 v2.3 Schema、JSON 资源限制、诊断模型及本地目录/显式文件 CLI。跨文件引用与数量关系检查、官方 validator 差分、随机变更测试和发布前互通尚未完成；当前测试通过不代表整个首版验收完成。

## 支持矩阵

| GBFS 端点 | Schema 校验 | 跨文件关系 |
| --- | --- | --- |
| `gbfs.json` | v2.3 官方 Schema | 开发中 |
| `gbfs_versions.json` | v2.3 官方 Schema | 开发中 |
| `system_information.json` | v2.3 官方 Schema | 开发中 |
| `station_information.json` | v2.3 官方 Schema | 开发中 |
| `station_status.json` | v2.3 官方 Schema | 开发中 |
| `free_bike_status.json` | v2.3 官方 Schema | 开发中 |
| `vehicle_types.json` | v2.3 官方 Schema | 开发中 |
| `system_hours.json` | v2.3 官方 Schema | 开发中 |
| `system_alerts.json` | v2.3 官方 Schema | 开发中 |
| `system_calendar.json` | v2.3 官方 Schema | 开发中 |
| `system_regions.json` | v2.3 官方 Schema | 开发中 |
| `system_pricing_plans.json` | v2.3 官方 Schema | 开发中 |
| `geofencing_zones.json` | v2.3 官方 Schema | 开发中 |

不支持 GBFS v1、v2.0–v2.2、v3.0、v3.1 或未来版本。v2.3 使用 `free_bike_status.json`；`vehicle_status.json` 不属于本版本范围。旧原型资料仍在仓库历史目录中，但不属于当前活动实现、支持矩阵或测试结论。

## 本地运行

主目标是 Node.js 24 的 MoonBit JS 后端。当前开发环境使用 `moon 0.1.20261028`、`moonc v0.10.18+6c83a7f62` 和 Node.js `v24.19.0`。

```sh
moon check --target js --deny-warn
moon test --target js --deny-warn
moon build --target js --deny-warn
```

对一个本地目录或显式文件列表执行 v2.3 Schema 校验：

```sh
moon run cmd/main --target js -- check ./feed-snapshot
moon run cmd/main --target js -- check ./feed-snapshot --json
moon run cmd/main --target js -- check ./feed-snapshot/gbfs.json ./feed-snapshot/system_information.json ./feed-snapshot/station_status.json
```

`check` 不联网。目录模式仅读取该目录顶层的 `.json` 文件；显式文件模式按文件名识别端点。单文件超过 8 MiB、整批超过 256 个文件或 64 MiB、JSON 深度超过 64 层或包含重复对象键时会拒绝输入。单文件最多输出 1,000 条、整个快照最多输出 5,000 条诊断；触发上限时会明确报告结果不完整并以错误退出。

退出码 `0` 表示当前已实现的校验没有错误；`1` 表示数据诊断中存在错误；`2` 表示命令参数或文件输入问题。当前报告明确显示跨文件关系规则仍在开发中。

## JSON 报告

`--json` 返回固定 GBFS 版本、错误/警告/信息计数以及诊断数组。诊断包含文件、RFC 6901 JSON Pointer、稳定码、实际值、期望规则、修复建议和来源；JSON 解析错误的指针为空字符串，表示根位置。

```json
{
  "version": "2.3",
  "errors": 1,
  "warnings": 0,
  "infos": 0,
  "diagnostics": [
    {
      "file": "station_information.json",
      "pointer": "/data/stations/0/lat",
      "severity": "error",
      "code": "schema.maximum",
      "message": "字段值高于允许范围",
      "actual": "91",
      "expected": "满足 Schema 的 maximum 约束",
      "suggestion": "按官方 v2.3 Schema 修正该字段",
      "source": "固定提交中的 MobilityData v2.3 Schema",
      "schema_pointer": "/..."
    }
  ]
}
```

以上为结构示意，不是一次完整运行的逐字输出。

## MoonBit API

```moonbit
let issues = @gbfs.validate_file(
  "vehicle_types",
  "{\"last_updated\":1450155600,\"ttl\":0,\"version\":\"2.3\",\"data\":{\"vehicle_types\":[]}}",
)
if @gbfs.has_errors(issues) {
  // 处理诊断
}
```

`parse_json_untrusted` 返回带有 `UntrustedDocument` 类型标记的数据；JSON 解析成功不等于 GBFS Schema 校验通过。`validate_file` 固定校验 v2.3，调用方必须明确提供端点名；不会根据输入版本切换规则。

## 诊断规则与阶段进展

当前单文件结构规则来自仓库固定提交的官方 v2.3 JSON Schema，覆盖必填字段、类型、常量、枚举、格式、模式、边界、数组和条件结构。测试已对全部 13 份 Schema 各运行一个合成最小正例，并覆盖版本错误、越界坐标和车辆形式非法枚举。逐规则测试矩阵和与官方 validator 的差分报告尚未完成。

计划完成的跨文件规则包括发现清单与本地文件对齐、站点/状态互相引用、车辆站点/车型/价格计划引用、ID 唯一性及有明确规范依据的数量关系。强制规则与建议规则将分开报告；无法从 v2.3 原文或官方工具确认的检查不会升级为错误。

## 应用场景

1. 出行数据平台在接入运营方 feed 前执行离线质量检查。
2. 城市开放数据管理者检查运营方公开的文件是否满足 GBFS v2.3 结构。
3. 研究人员或开发者在数据清洗前发现结构无效的站点、车辆或价格数据。

## 边界与限制

- 当前只实现固定 v2.3 Schema 和本地输入，不下载远程 feed。
- 跨文件业务关系规则尚未完成；目前 Schema 通过不能视为整套快照语义正确。
- 不实现地图、路线、调度、支付、用户账号、租车、爬虫或数据库。
- 不把 Schema 校验成功解释为运营方身份可信、服务在线或数据新鲜。
- GBFS 本身不提供令牌撤销或防重放能力；本工具不处理认证。
- 主目标为 Node.js 24；其他 MoonBit 后端未验证。
- 项目尚未经过独立安全审计，不承诺生产级安全。

## 规范与许可

规范选择、查重、提交 SHA、Schema 来源和许可证判断见 [版本决策](docs/decisions.md)、[查重记录](docs/dedup.md)、[规范映射](docs/spec-map.md) 与 [第三方材料](NOTICE.md)。项目代码采用 Apache-2.0。原始 Schema 保存在 `schemas/v2.3/`，嵌入源可通过 `node tools/embed-schemas.cjs --check` 核对。许可证不明的官方真实 feed 不随仓库分发；当前测试样例为自行构造数据。

## 验证状态

开发记录与阶段计划见 [docs/plan.md](docs/plan.md) 和根目录的 `progress.md`。截至 2026-11-09，`moon test --target js --deny-warn` 实际运行结果为 23/23 通过；此结果只描述当前已编写测试，不代表官方 validator 差分、跨文件规则、随机变更测试或其他后端已经通过。阶段验证输出保存在 `docs/evidence/2026-11-09/phase2-validation.txt`。
