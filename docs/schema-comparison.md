# GBFS v2.3 Schema 差分

参考端使用 Ajv 8.17.1 和 ajv-formats 2.1.1，以 Draft 7 解释 13 份未修改的官方 Schema。运行设置 `allErrors: true`、`strict: false`，与 MobilityData validator 固定提交的 Ajv 设置一致。对照只涵盖单文件 Schema 和本项目的正文修正。官方网页和跨文件 validator 未参与此轮对照。 [固定 Schema](https://github.com/MobilityData/gbfs-json-schema/tree/01d4cb480410ca234b1d76799daf474b8f839e85/v2.3) · [参考设置](https://github.com/MobilityData/gbfs-validator/blob/b734086ccdf93b5acd72bb349c6fda0c9f64fd39/gbfs-validator/validate.js)

| 用例类型 | 用例数 | 结果 |
| --- | ---: | --- |
| 13 个端点的正例 | 13 | 两端接受 |
| 13 个端点分别删去四个根必填字段 | 52 | 两端拒绝 |
| 字段约束与条件结构变更 | 29 | 两端拒绝 |
| 跨午夜营业时间 | 1 | 官方 Schema 拒绝，本工具按正文接受 |
| 倒序版本列表 | 1 | 官方 Schema 接受，本工具按正文拒绝 |
| 合计 | 96 | 94 个一致，2 个已解释差异，0 个意外差异 |

`hours.spec_extended_time` 将 `system_hours.json` 的 `end_time` 改为 `47:59:59`。官方 Schema 的正则接受 00 至 23 小时，规范正文的 Time 类型接受至 `47:59:59`。本工具对合法的 24 至 47 小时仅豁免该字段的模式错误。非法时间如 `48:00:00` 仍被两端拒绝。对照脚本分别固定两端预期，保留 Ajv 的原始拒绝结果。 [规范 Time 类型](https://github.com/MobilityData/gbfs/blob/4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8/gbfs.md#field-types)

`versions.not_increasing` 先列出 `3.0`，再列出 `2.3`。官方 Schema 的描述文字写明应递增，但 Schema 没有检查顺序的约束。本工具按规范正文在第二项报告 `version.not_increasing`。 [规范 gbfs_versions.json](https://github.com/MobilityData/gbfs/blob/4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8/gbfs.md#gbfs_versionsjson)

用例保存在 `tests/fixtures/v2.3/schema-cases.json`。每条结果的用例 ID、两端判断、规则与指针见 [实际输出](evidence/2026-11-09/schema-comparison.json)。结果限于这组用例。

```sh
npm ci --prefix tools/schema-reference --ignore-scripts --no-audit --no-fund
moon build --target js --deny-warn
node tools/schema-reference/compare.cjs
```

安装依赖后，对照命令读取仓库内的 Schema 和夹具，离线完成。
