# gbfs

gbfs 用 MoonBit 校验共享单车和微出行系统的 **GBFS v2.3** 本地快照。它读取目录或明确列出的 JSON 文件，检查单文件结构、发现清单与实体引用，并输出可定位的文本或 JSON 诊断。

## 支持范围

| 端点 | 检查内容 |
| --- | --- |
| `gbfs.json`、`gbfs_versions.json` | 发现清单、语言对应、文件对应、版本目录顺序 |
| `system_information.json` | 系统、语言、时区、联系方式等字段 |
| `station_information.json`、`station_status.json` | 站点结构、双向引用、区域和车型引用、可用量、容量 |
| `free_bike_status.json`、`vehicle_types.json` | 车辆与车型结构、坐标、条件续航、站点和价格引用 |
| `system_pricing_plans.json`、`system_regions.json` | 价格和区域字段、ID、被引用的实体 |
| `system_hours.json`、`system_calendar.json`、`system_alerts.json` | 营业时间、日历、告警、站点和区域引用 |
| `geofencing_zones.json` | GeoJSON 结构和规则字段 |

首版使用 13 份固定提交的 v2.3 官方 Schema。逐条规则、错误码、来源和测试见 [规范映射](docs/spec-map.md)。

## 安装与运行

按照官方安装说明准备 MoonBit 工具链和 Node.js 24。开发验证使用 `moon 0.1.20261028`、`moonc v0.10.18+6c83a7f62` 和 Node.js `v24.19.0`。 [MoonBit 安装说明](https://docs.moonbitlang.com/en/latest/tutorial/tour.html#installation)

```sh
git clone https://github.com/dtzrttp/gbfs.git
cd gbfs
moon update
moon build --target js --deny-warn
```

构建完成后可以离线运行。以下命令使用仓库自带的合成快照。

```sh
# 校验有桩系统的完整目录
node _build/js/debug/build/cmd/main/main.js check tests/fixtures/v2.3/snapshot --docked

# 在 CI 或接入程序中读取 JSON 报告
node _build/js/debug/build/cmd/main/main.js check tests/fixtures/v2.3/snapshot --json

# 单独诊断一个端点文件
node _build/js/debug/build/cmd/main/main.js file tests/fixtures/v2.3/snapshot/station_status.json --json
```

也可以将同一语言快照中的文件路径逐一传给 `check`。文件名按规范端点命名，目录模式读取顶层 JSON。指定 `--docked` 要求站点信息和站点状态，指定 `--free-floating` 要求车辆状态文件，两项可组合。对刚取得的快照可加 `--freshness`，用本机时间检查近实时延迟。归档快照默认只做与当前时间无关的检查。

`parse` 只检查 JSON 语法和输入边界，`file` 运行单文件规则，`check` 在输入文件通过单文件规则后运行跨文件规则。退出码 0 表示无错误，1 表示有数据错误，2 表示参数或本地文件输入错误。警告单独计数。

## JSON 报告示例

以下是缺少站点定义时的一条示例诊断。路径使用 RFC 6901 JSON Pointer。

```json
{
  "file": "station_status.json",
  "pointer": "/data/stations/0/station_id",
  "severity": "error",
  "code": "consistency.station_status.unknown_station",
  "message": "站点状态引用了未知站点",
  "actual": "s2",
  "expected": "station_id 必须出现在 station_information.json 的 stations 中",
  "suggestion": "修正 station_id，或补充对应站点信息记录",
  "source": "https://github.com/MobilityData/gbfs/blob/4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8/gbfs.md",
  "schema_pointer": null
}
```

完整报告包含 `version`、`errors`、`warnings`、`infos` 和 `diagnostics`。库接口 `validate_file` 接收不带扩展名的端点名和 JSON 文本。`validate_snapshot` 接收端点名到文本的 Map，`validate_snapshot_with_options` 可指定运营模式和 POSIX 秒参考时间。语法解析的 `UntrustedDocument` 需另行校验。

## 应用场景

1. **平台接入。** 出行数据平台以 `check --json` 生成机器可读报告，在接入运营方 feed 前阻止结构或引用错误。
2. **开放数据检查。** 城市开放数据管理者以 `check --docked` 或 `check --free-floating` 核对必需端点，用文本报告把问题定位到具体文件和字段。
3. **研究与清洗。** 在数据清洗前以 `file` 检查单个价格文件，再以 `check` 查找不存在的站点、车型和价格计划引用。

## 验证结果

- MoonBit JS 后端 35 项测试通过。CLI 集成检查覆盖目录、显式路径、JSON 输出、无效 UTF-8 和退出码。
- 独立 Ajv 引擎对照 96 个单文件用例，94 个一致，2 个正文与 Schema 的差异均已解释。 [差分结果](docs/schema-comparison.md)
- 固定种子的 30 个变更样例全部通过。测试覆盖字段删除、类型替换和站点 ID 变更，并比较两种输入顺序的报告。
- 两份真实运营方快照已离线运行。Linz 为 0 错误、19 警告，Dott Abu Dhabi 为 1,433 错误、1,433 警告。 [真实快照结果](docs/real-feed-validation.md)
- 在 Mooncakes 和 GitHub 的复查中未发现同题的 MoonBit GBFS 项目。 [查询与完整输出](docs/dedup.md)

```sh
moon fmt --check
moon check --target js --deny-warn
moon test --target js --deny-warn
moon build --target js --deny-warn
node tools/embed-schemas.cjs --check
node tools/verify-cli.cjs
node tools/verify-mutations.cjs
```

独立差分的依赖安装和执行命令见 [差分说明](docs/schema-comparison.md)。单文件上限 8 MiB，整个快照上限 64 MiB 和 256 个输入文件。解析拒绝重复对象键和超过 64 层的嵌套。报告截断时发出错误。

本地发布前验证的实际命令与退出码见 [运行记录](docs/evidence/2026-11-09/release-validation.txt)。

## 限制与后续工作

当前后端为 MoonBit JavaScript 和 Node.js 24，版本范围为 GBFS v2.3。跨文件检查以同一时间窗口、同一语言的一组本地文件为输入。货币检查采用 Schema 的格式约束。几何检查采用 Schema 的 GeoJSON 结构约束。单个快照无法验证车辆 ID 在行程结束后是否轮换、外链是否可达或发布频率是否稳定。后续可扩展地理语义和版本支持。

项目代码使用 Apache-2.0。官方 Schema 的来源和署名、参考工具与依赖许可证见 [第三方材料](NOTICE.md) 和 [版本决策](docs/decisions.md)。
