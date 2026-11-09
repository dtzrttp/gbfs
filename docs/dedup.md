# GBFS 选题查重

2026-11-09（北京时间）。在已查询的 Mooncakes 和 GitHub 公开范围内，未发现 MoonBit GBFS 解析与校验实现。

| 查询 | 结果 |
| --- | --- |
| `moon search gbfs`、`moon search "gbfs validator"` | 各 1 项，均为 PDDL 规划引擎，缩写指 Greedy Best-First Search。 [PDDL 项目](https://github.com/sa2360/pddl) |
| `moon search bikeshare`、`moon search "general bikeshare feed specification"` | 均成功，零结果。 |
| `moon search "bike share"`、`moon search vehicle_status` | 分别返回 1、3 个模糊匹配，涉及游戏、示例及物理引擎。 |
| Mooncakes 模块元数据 | 模块索引 HTTP 200。扫描 3,642 条记录，GBFS 和共享单车相关英文词无命中。 [索引结果](evidence/2026-11-09/upstream/mooncakes-index.json) |
| GitHub 公开仓库搜索 | 5 次均成功，含名称、描述、README 与语言筛选。仅命中 PDDL。 |
| GitHub 公开代码搜索 | `extension:mbt` 下的 `gbfs`、`bikeshare`、`station_information`、`vehicle_status` 均成功且返回 0。 |

[Moon CLI 完整输出和退出码](evidence/2026-11-09/moon/commands.json) · [GitHub API 完整输出与查询参数](evidence/2026-11-09/github/commands.json)

本机 `moon 0.1.20261028`。GitHub CLI 活动账号及 Git 全局提交名均核实为 `dtzrttp`。官方的 MobilityData GBFS 校验器和 Schema 库属于上游参照，MoonBit 选题以本地离线校验、稳定诊断和跨文件规则为交付边界。 [上游校验器](https://github.com/MobilityData/gbfs-validator)
