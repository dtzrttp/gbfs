# 真实 feed 离线验证

2026-11-09（北京时间）从 MobilityData 固定目录选取两个公开的 v2.3 系统。先取得各自的 `gbfs.json`，再按其中一个语言分组下载其同源 HTTPS 端点，保存原始字节。随后用已经构建的本地 CLI 校验保存的快照。 [官方系统目录](https://github.com/MobilityData/gbfs/blob/06dddf8d087df8f9c419953c2dc7ce73100e44d8/systems.csv)

| 系统 | 语言 | 文件数 | `system_information` 许可信息 | 退出码 | 错误 | 警告 |
| --- | --- | ---: | --- | ---: | ---: | ---: |
| city bike Linz（nextbike） | de | 10 | `CC0-1.0` | 0 | 0 | 19 |
| Dott Abu Dhabi | en | 9 | 未提供 `license_id` 或 `license_url` | 1 | 1,433 | 1,433 |

- Linz 的 19 条 `consistency.station.capacity_exceeded` 来自可用车辆数高于公布容量的站点。该项是本工具的质量提示。 [Linz 发现端点](https://gbfs.nextbike.net/maps/gbfs/v2/nextbike_al/gbfs.json)
- Dott 的 1,433 条 `consistency.region.unknown` 来自站点引用了区域 ID，而同一语言快照没有提供对应的区域定义。另有 1,433 条 `consistency.bike_count.sum_mismatch`，对应按车型统计的总和与公布总量不同。 [Dott Abu Dhabi 发现端点](https://gbfs.api.ridedott.com/public/v2/abu-dhabi/gbfs.json)

两份快照都通过了本工具的单文件检查并进入跨文件检查。表格描述当日保存的快照，实时端点后续可能变化。下载文件和详细诊断均保留在本地忽略目录 `_build/real-feeds/`。仓库分发的是合成测试数据和本页的汇总结果。

```powershell
node _build/js/debug/build/cmd/main/main.js check _build/real-feeds/nextbike --json
node _build/js/debug/build/cmd/main/main.js check _build/real-feeds/dott --json
```

端点清单、文件 SHA-256 和按诊断码统计的结果见 [运行证据](evidence/2026-11-09/real-feed-summary.json)。
