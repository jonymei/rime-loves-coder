-- zh_hint.lua
-- 在英文候选词右侧显示中文释义（仅显示在 comment 中，不影响上屏内容）。
-- 词典文件：<用户目录>/en_zh.txt，每行「英文<TAB>中文」，UTF-8。
-- 注册顺序：需排在 corrector.lua 之后，与 en_hint.lua 相邻。
-- 配置（在 schema 中）：
--   zh_hint:
--     enabled: true      # 总开关
--     prefix: '→ '       # 翻译前缀标识
--     separator: ' '     # 与已有 comment 之间的分隔符
--     max_length: 0      # 释义最大字节数，0 或省略表示不限制

local M = {}

function M.init(env)
  local config = env.engine.schema.config
  env.name_space = env.name_space:gsub("^*", "")
  local ns = env.name_space

  local enabled = config:get_bool(ns .. "/enabled")
  M.enabled = enabled == nil and true or enabled
  M.sep = config:get_string(ns .. "/separator") or " "
  M.prefix = config:get_string(ns .. "/prefix") or "→ "  -- 翻译前缀标识

  local max = config:get_int(ns .. "/max_length")
  if max and max > 0 then
    M.max = max
  end

  M.dict = {}
  if not M.enabled then
    return
  end

  local path = rime_api.get_user_data_dir() .. "/en_zh.txt"
  local file = io.open(path, "r")
  if not file then
    print("[zh_hint] 未找到词典文件 " .. path .. "，已关闭中文释义")
    M.enabled = false
    return
  end

  local count = 0
  for line in file:lines() do
    local en, zh = line:match("^(.-)\t(.+)$")
    if en and zh then
      M.dict[en] = zh
      count = count + 1
    end
  end
  file:close()
  print("[zh_hint] 已加载 " .. count .. " 条英中词条")
end

function M.func(input, env)
  if not M.enabled then
    for cand in input:iter() do
      yield(cand)
    end
    return
  end

  for cand in input:iter() do
    local genuine = cand:get_genuine()
    local zh = M.dict[genuine.text:lower()]
    if zh then
      if M.max and #zh > M.max then
        zh = zh:sub(1, M.max) .. "…"
      end
      -- 保留原有 comment（如英文自动大写相关），追加带前缀的中文
      local hint = M.prefix .. zh
      if genuine.comment and genuine.comment ~= "" then
        genuine.comment = genuine.comment .. M.sep .. hint
      else
        genuine.comment = hint
      end
    end
    yield(cand)
  end
end

return M