# gbfs.mbt

用 MoonBit 校验本地 GBFS 3.0 快照。工具依据 MobilityData 的原始 JSON Schema 检查单文件格式，再检查发现列表、站点与车辆类型之间的关系。报告含文件名、JSON Pointer、稳定规则码和严重性，适合人工排查或接入数据流水线。

## 快速运行

当前验证环境为 Windows、`moon 0.1.20261028` 和 Node.js 24。CLI 使用 JS 后端，首次构建需要从 Mooncakes 解析依赖。

```sh
moon check --target js
moon run cmd/main --target js -- check examples/valid
moon run cmd/main --target js -- check examples/valid --json
moon run cmd/main --target js -- file station_status examples/valid/station_status.json
```

快照目录使用下表的端点名加 `.json` 作为文件名。CLI 不联网，不会按照 `gbfs.json` 中的 URL 下载数据。调用方应先把同一系统的同批文件保存到一个目录。

| 命令 | 行为 |
| --- | --- |
| `check <目录> [--json]` | 校验一个目录内的受支持文件并检查跨文件关系。 |
| `file <端点名> <文件> [--json]` | 对指定端点执行 JSON 与 Schema 校验，端点名不带扩展名。 |
| `--help` | 显示用法。 |

退出码 `0` 表示无错误，可能有警告。退出码 `1` 表示数据校验失败，仍会输出完整报告。退出码 `2` 表示参数、文件读取或 UTF-8 编码有问题，详情写到标准错误。JSON 报告以空字符串表示根指针，`schema_pointer` 为可选 Schema 指针。

自动化中可以用构建产物直接读取退出码。

```sh
moon build --target js
node _build/js/debug/build/cmd/main/main.js check examples/valid --json
```

## 首版覆盖

| 端点 | 单文件 | 快照内额外检查 |
| --- | --- | --- |
| `gbfs` | 版本、发现项、HTTP(S) URL 与条件必填 | 重复端点、已声明但缺失、存在但未声明的受支持文件、站点文件成对。 |
| `system_information` | 必填元数据、语言字段、时区、日期、许可字段等 | 快照必需。 |
| `station_information` | 坐标、名称、容量、各类泊位等 | 站点 ID、状态配对、车型容量引用。 |
| `station_status` | 可用车辆数、车桩数、状态、时间等 | 站点 ID、车型引用与条件字段。车辆与车桩分类数量不等于总数时报告警告。 |
| `vehicle_types` | 车型、动力类型、续航条件等 | 车型 ID。 |
| `vehicle_status` | 坐标或站点、租赁状态、车辆属性等 | 车辆 ID、当前站点和归还站点引用、车型引用与有动力车辆续航。 |

根包可供同版本 MoonBit 模块调用。核心入口为 `validate_file(feed, source)` 和 `validate_snapshot(feeds)`，后者接受端点名到 JSON 字符串的映射。两者返回 `Array[Diagnostic]`。用 `has_errors` 判断结果，用 `Diagnostic::to_json` 序列化单条诊断。内嵌 Schema 不要求调用方设置数据目录。

此版本覆盖 GBFS 3.0 的六个端点。发现列表可以列出其他 GBFS 3.0 标准端点，CLI 的校验范围仍以表格为准。跨文件判断只使用通过 Schema 的文件，避免把格式错误误报成悬空引用。静态快照无法判定在线可达性、车辆 ID 轮换、实际数据时效或运营状态。JSON 数值按双精度解析，超精度小数的类型判断可能受舍入影响，分类合计的精确比较限于安全整数范围。JSON 文本嵌套限 64 层，CLI 读入文件后拒绝大于 8 MiB 的内容。站点容量等业务字段按已提供的数据核对。

## 验证

```sh
moon fmt --check
moon check --target js --deny-warn
moon test --target js --deny-warn
moon build --target js --deny-warn
node tools/embed-schemas.cjs --check
node tools/verify-cli.cjs
```

CLI 回归测试保留规范的 8 个原始示例。7 个符合固定 Schema。发现文件示例列出 `station_information`，却缺少 `station_status`，因此按 Schema 预期拒绝。跨文件测试使用另行构造的同批快照。 [规则映射与上游来源](docs/spec-map.md) · [查重记录](docs/dedup.md)

本项目代码采用 Apache-2.0。上游 Schema 和规范示例分别保留来源及许可说明。 [第三方材料](NOTICE.md)
