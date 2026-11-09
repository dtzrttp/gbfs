# 规范规则映射

首版使用 GBFS 3.0。协议依据固定提交 `457cb71121348ad6c07384b7743ea7df994a4ebb`，六份配套 Schema 固定于 `01d4cb480410ca234b1d76799daf474b8f839e85`。 [规范](https://github.com/MobilityData/gbfs/blob/457cb71121348ad6c07384b7743ea7df994a4ebb/gbfs.md) · [Schema](https://github.com/MobilityData/gbfs-json-schema/tree/01d4cb480410ca234b1d76799daf474b8f839e85/v3.0)

| 规范位置 | 实现 | 验证 |
| --- | --- | --- |
| JSON Files 与各端点 | `schema_validation.mbt` 以 Draft 7 验证原始 Schema，启用格式断言。 | 重复键、版本、非法日期、纬度、发现文件条件约束、缺少必填项。 |
| Files、Field Types 与 `gbfs.json` | `schema_validation.mbt` 校验发现 URL 的协议和主机，`snapshot.mbt` 检查本地必需端点、发现列表、站点文件配对。 | 非 HTTP(S)、缺主机、完整快照、缺失已声明文件。 |
| Field Types 与两种站点端点 | `snapshot.mbt` 为可打印 ASCII ID 建索引，检查唯一性和两个方向的站点覆盖。 | 重复车型 ID，站点信息和状态相互缺失。 |
| `station_information`、`station_status`、`vehicle_status` | 检查站点与车型引用，以及部分可从同批数据确定的条件字段。 | 车型不存在、实体车桩与车型限制下的必填项、代泊站无限容量、有动力车辆缺少当前续航。 |
| `station_status` | 分类车辆和分类泊位的数量合计与各自总数不一致时产生 SHOULD 警告。 | 车辆分类合计反例、警告不改变 CLI 成功退出码。 |
| 工具输入边界 | CLI 分离输入错误和校验失败，单文件校验与快照校验使用同一 Schema。 | JSON 报告、文本报告、CLI 三种退出码及原始示例。 |

规范中的发现文件示例缺少 `station_status`，而同版本 Schema 同时要求至少一个状态端点，以及出现 `station_information` 时配对 `station_status`。原样示例作为可复现的拒绝用例，预期产生 `schema.anyOf` 与 `schema.contains`。
