# GBFS 选题查重与启动环境

审计时间：2026-11-09 11:39–12:05（Asia/Shanghai）。Moon 搜索完整记录文件保存于 11:39；本文件区分“搜索成功但零结果”和“搜索失败”；本轮规定的 8 条 Moon 搜索均成功，退出码为 0。

## 结论

在本轮检索的 Mooncakes 模块索引及 GitHub 公开仓库、MBT 源码范围内，没有发现 MoonBit GBFS feed 解析或校验实现，也没有发现同主题骨架项目。查重不构成阻塞，可以继续开发。

GitHub 上有官方 GBFS 校验器、Schema 仓库及其他语言的 GBFS 库；这些是标准参照或不同语言实现，不属于“MoonBit GBFS 实现重复”。搜索到的 PDDL 包确实是 MoonBit 项目，但其中 GBFS 是 Greedy Best-First Search 的缩写，不是共享单车数据。

## 工作区与身份

- 项目目录为 gbfs.mbt，内部有独立 Git 仓库和分支 codex/gbfs；父工作区的其他目录不属于该仓库历史。
- 当前仓库无 Git 远程；本地已有 2 个提交，作者均为 dtzrttp <313799694+dtzrttp@users.noreply.github.com>。
- 全局与仓库级 Git 提交名、邮箱一致，均为上述 dtzrttp 身份。
- 经 gh api user --jq .login 核实，GitHub CLI 活动账号为 dtzrttp。后续仓库写入使用 CLI 活动账号；另一个 GitHub 插件只读连接报告账号 08170406，仅用于一次辅助公开搜索，不用于提交、创建或修改仓库。
- MoonBit 已安装：moon 0.1.20261028 (e1e1f15 2026-10-28)；编译器为 moonc v0.10.18+6c83a7f62，Node.js 为 v24.19.0。版本输出保存在 evidence/2026-11-09/validation.txt。

## Mooncakes / Moon CLI

以下命令均在本机实际执行。完整标准输出、标准错误与退出码保存在 [Moon 搜索完整记录](evidence/2026-11-09/recheck/moon-search-full.txt)。

| 命令 | 结果摘要与判断 |
| --- | --- |
| moon search gbfs | 成功，1 项：sa2360/pddl@0.2.0。实际检查了 README、search.mbt、search_wbtest.mbt；项目是 PDDL 2.1 规划器，GBFS 仅指贪心最佳优先搜索。详见[检查记录](evidence/2026-11-09/recheck/pddl-inspection.txt)。 |
| moon search "general bikeshare feed specification" | 成功，零结果。 |
| moon search bikeshare | 成功，零结果。 |
| moon search "bike share" | 成功，1 项 bobzhang/games，与 GBFS feed 无关。 |
| moon search micromobility | 成功，零结果。 |
| moon search "station_information" | 成功，2 项：IEC 104 协议栈与游戏包，均非 GBFS。 |
| moon search "vehicle_status" | 成功，3 项：游戏示例、占位包及 Rapier 物理库，均非 GBFS。 |
| moon search mobilitydata | 成功，零结果。 |

同日此前从 Mooncakes 模块索引下载并扫描了 3,642 条模块记录，GBFS、共享单车和 MobilityData 相关描述无命中，原始索引见 [mooncakes-index.json](evidence/2026-11-09/upstream/mooncakes-index.json)。

## GitHub 仓库与源码

查询使用已核实的 GitHub CLI 活动账号 dtzrttp；未使用 language:MoonBit 作为唯一过滤条件。完整 JSON 输出与退出码见 [GitHub 搜索完整记录](evidence/2026-11-09/recheck/github-search-full.txt)。

仓库查询覆盖名称、描述、README：

- gh search repos gbfs in:name --json fullName,description,url,updatedAt --limit 100
- gh search repos gbfs in:description --json fullName,description,url,updatedAt --limit 100
- gh search repos "General Bikeshare Feed Specification" in:readme --json fullName,description,url,updatedAt --limit 100
- gh search repos bikeshare in:name,description,readme --json fullName,description,url,updatedAt --limit 100
- gh search repos mobilitydata in:name,description,readme --json fullName,description,url,updatedAt --limit 100

源码查询显式要求 MBT 扩展名：

- gh search code gbfs extension:mbt --json repository,path,url --limit 100
- gh search code MobilityData extension:mbt --json repository,path,url --limit 100
- gh search code station_information extension:mbt --json repository,path,url --limit 100
- gh search code vehicle_status extension:mbt --json repository,path,url --limit 100
- gh search code micromobility extension:mbt --json repository,path,url --limit 100

所有命令均成功。GBFS 相关的 MoonBit 源码结果是误匹配：例如 multichannel_vectors.mbt、embedded_fonts.mbt、Windows API 生成文件和 PDDL/二进制分析文件；没有文件实现共享单车 Feed 解析或校验。MobilityData、vehicle_status、micromobility 的 MBT 查询返回空数组。仓库名/描述/README 检索命中的同领域参照包括：

- [MobilityData/gbfs-validator](https://github.com/MobilityData/gbfs-validator)：官方 JavaScript 校验器。
- [MobilityData/gbfs-json-schema](https://github.com/MobilityData/gbfs-json-schema)：官方 Schema。
- [MobilityData/gbfs-validator-java](https://github.com/MobilityData/gbfs-validator-java)：Java 校验器。
- [simonpcouch/gbfs](https://github.com/simonpcouch/gbfs)：R 语言数据包。
- [hiskoh/GBFS-NOW](https://github.com/hiskoh/GBFS-NOW)：QGIS 插件。

上述项目覆盖其他语言、官方基准或可视化用途；没有发现其中存在 MoonBit GBFS 校验实现。

## 结果边界

这是一份截至记录时间的公开索引查重，不能证明不存在私有仓库或未索引分支。gbfs in:name 按 CLI 上限最多返回 100 项；同主题检查由描述/README 搜索和 MBT 源码搜索补足。搜索命令零结果均保留其 exit=0，未把失败伪装成零结果。
