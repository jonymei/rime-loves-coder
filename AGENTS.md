# AGENTS.md

## Repository Snapshot
- **Project**: Rime / 雾凇拼音（iDvel/rime-ice）用户目录配置。
- **Primary artifacts**: `.schema.yaml`、`.dict.yaml` 和 Lua 插件（`lua/*.lua`）。
- **Key behaviours**:
  - `default.yaml` defines global defaults, hotkeys, punctuation rules.
  - `default.custom.yaml` applies local overrides (e.g., bracket hotkeys for 以词定字).
  - `double_pinyin_flypy.schema.yaml` configures the 小鹤双拼方案.
  - Lua scripts implement extended features such as `select_character.lua` (以词定字) and `pin_cand_filter.lua` (候选置顶).

## Get Oriented
1. **Schemas (`*.schema.yaml`)**  
   Define processors, translators, filters, recognizer patterns, and per‑schema overrides. Schemas in `build/` are generated copies – edit the root files instead.
2. **Lua extensions (`lua/*.lua`)**  
   Each script is referenced by name inside schema `engine.processors` / `filters` or translators. Match the `lua_processor@*name` or `lua_filter@*name` syntax when wiring features.
3. **Custom dictionaries & phrases**  
   - `rime_ice.dict.yaml` main lexicon.  
   - `custom_phrase.txt` (全拼) and `custom_phrase_double.txt` (双拼) for user phrases.
4. **Platform configs** (`squirrel*.yaml`, `weasel.yaml`) adjust client behaviour (macOS / Windows).

## Common Tasks
- **部署/更新词库**  
  - `make all` → 安装精选扩展词库配方 `others/recipes/all_dicts`.  
  - `make full` → 完整更新（基础配置 + 词库，较危险，推荐先备份）。  
  - 其他配方：`make cn`, `make en`, `make opencc`, `make flypy`.
- **自定义快捷键**  
  - 修改 `default.custom.yaml` 的 `key_binder` 块（或单独 schema 的 custom YAML）并确保相关 Lua 已在 `engine.processors` 注册。
- **新增/调整 Lua 功能**  
  - 保存脚本到 `lua/`，在目标 schema 的 `engine` 中引用，例如 `lua_processor@*new_feature`。  
  - 如果需要配置，添加同名顶级块（如 `new_feature:`）并读取配置值于脚本 `env.engine.schema.config`.
- **定制词典**  
  - 更新 `.dict.yaml` 后需运行同步（在输入法内部署）以编译 `.prism.bin`。

## Testing & Verification
- **快速验证**  
  1. 重新部署输入法（Squirrel: `Ctrl` + `Option` + `Shift` + `R`; Weasel: 右键菜单 → 部署）。  
  2. 在候选栏试打相关触发词，确认拼写展开、Lua 功能、标点映射。
- **回退策略**  
  - 先备份修改前的 YAML/Lua。  
  - 对 `make full` 等覆盖性操作，建议 git commit 或复制整个目录。

## Coding Conventions
- **字符集**: 保持 UTF-8 无 BOM；注释以中文为主，避免引入表情/非必要 Unicode。  
- **缩进**: YAML 使用两个空格；Lua 使用两个空格对齐。  
- **注释**: 仅在复杂逻辑（Lua）或特别配置块上添加简洁说明。

## Agent Guidelines
- 修改 schema 时：同步更新相关 custom 文件（`*.custom.yaml`）避免模块被覆盖。  
- 任何自动化命令（`make full` 等）前，确认用户允许，因为它们可能覆盖现有自定义。  
- 若需新增文件，默认放置在对应语言目录（Lua→`lua/`; schema→根目录）。  
- 没有默认测试套件；验证依赖人工部署。在无法部署时，提供详细手动验证步骤。  
- 若侦测到共享库版本差异（`config_version` 变动），留意合并冲突并提醒用户检查本地定制是否被覆盖。

