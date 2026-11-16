# Sexena Arena Tales 汉化历程

本资料夹保存繁体中文汉化项目资料，不包含游戏本体、ASAR 封包、存档或隔离启动副本。资料由游戏安装目录中的 `translation_zhTW` 整理复制；原工作目录仍保留，避免影响现有补丁。

## 历程概览

现存资料的修改时间主要集中在 2026 年 10 月 12–13 日。下列顺序依据项目文件与记录重建，不能据此推断每一步的精确完成日期。

1. 从原始 `app.original.asar` 导出 Ink 剧情与 HTML 界面文字，建立带 ID、原文、译文和位置的 DUMP。
2. 将人工翻译按批次保存在 `batches/`，再转换为 `strings.json` 和 `strings_*.json`，供构建脚本使用。
3. 以场景工作清单处理开场、战斗、商店、支线和结局等文本，并补译部分 HTML 界面、存读档文字及 19 项成就。
4. 审核剩余字串，区分可见文字与资源键、Ink 指令、颜色值等控制内容；记录在 `pending_string_audit.md` 和 `dump/remaining_review.tsv`。
5. 重新打包繁中补丁，加入 Noto Sans TC 字体；进行封包、JavaScript、Ink 执行和隔离启动检查，并保存开场截图 `qa_opening.png`。

## 目前记录的状态

按现有审核记录，有效且不重复的字串 4,342 条，已译 3,900 条，剩余 442 条已逐项分类。此数字是当时固定版本的审核结果。部分其他剧情、战斗及商店文字仍可能有英文；支线、结局和画廊未完成逐画面验收。完整范围与限制见 `translation_zhTW/README.md` 及 `translation_zhTW/pending_string_audit.md`。

## 资料位置

| 路径 | 内容 |
| --- | --- |
| `translation_zhTW/batches/` | 人工翻译批次 |
| `translation_zhTW/strings*.json` | 构建所用的译文对照 |
| `translation_zhTW/dump/` | 原文导出及剩余字串审查表 |
| `translation_zhTW/scene_*_worklist.md` | 各场景工作清单 |
| `translation_zhTW/*.py`、`*.ps1` | 导出、导入、审查、构建与测试脚本 |
| `translation_zhTW/qa_opening.png` | 开场画面检查截图 |

原脚本以位于游戏根目录下的 `translation_zhTW` 为路径前提。若要重新构建，须先按原项目 README 将工作资料放回游戏根目录，或调整脚本中的游戏路径。这里是独立归档，不应直接在此运行构建脚本。
