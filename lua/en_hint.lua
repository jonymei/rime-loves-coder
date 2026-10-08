-- en_hint.lua
-- 在候选词右侧显示英文释义（仅显示在 comment 中，不影响上屏内容）。
-- 词典文件：<用户目录>/zh_en.txt，每行「中文<TAB>英文」，UTF-8。
-- 注册顺序：必须排在 corrector.lua 之后，否则会覆盖错音错字的 comment。
-- 配置（在 schema 中）：
--   en_hint:
--     enabled: true      # 总开关
--     prefix: '→ '       # 翻译前缀标识
--     separator: ' '     # 与已有 comment（错音错字提示）之间的分隔符
--     max_length: 0      # 释义最大字节数，0 或省略表示不限制

local M = {}

function M.init(env)
  local config = env.engine.schema.config
  env.name_space = env.name_space:gsub("^*", "")
  local ns = env.name_space

  local enabled = config:get_bool(ns .. "/enabled")
  M.enabled = enabled == nil and true or enabled
  M.sep = config:get_string(ns .. "/separator") or " " -- 默认空格
  M.prefix = config:get_string(ns .. "/prefix") or "→ "  -- 翻译前缀标识

  local max = config:get_int(ns .. "/max_length")
  if max and max > 0 then
    M.max = max
  end

  M.dict = {}
  if not M.enabled then
    return
  end

  local path = rime_api.get_user_data_dir() .. "/zh_en.txt"
  local file = io.open(path, "r")
  if not file then
    print("[en_hint] 未找到词典文件 " .. path .. "，已关闭英文释义")
    M.enabled = false
    return
  end

  local count = 0
  for line in file:lines() do
    local zh, en = line:match("^(.-)\t(.+)$")
    if zh and en then
      M.dict[zh] = en
      count = count + 1
    end
  end
  file:close()
  print("[en_hint] 已加载 " .. count .. " 条中英词条")
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
    local en = M.dict[genuine.text]
    if en then
      if M.max and #en > M.max then
        en = en:sub(1, M.max) .. "…"
      end
      -- 保留 corrector.lua 等写入的原有 comment，追加带前缀的英文
      local hint = M.prefix .. en
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