local M = {}

local popup = require("neogit.lib.popup")
local git = require("neogit.lib.git")

---@param key string
---@return string
local function get_config_source_indicator(key)
  -- Get values from each level to show which level is active
  local global = git.config.get_global(key)
  local local_val = git.config.get_local(key)

  if local_val:is_set() then
    return " [L]"
  elseif global:is_set() then
    return " [G]"
  else
    return ""
  end
end

function M.create(env)
  -- Get current git config values for display
  local g_pull_rebase = git.config.get_global("pull.rebase")
  local g_autostash = git.config.get_global("rebase.autostash")
  local g_pull_autostash = git.config.get_global("pull.autostash")

  local p = popup
    .builder()
    :name("NeogitConfigPopup")
    :config_heading("Stash & Autostash Configuration")
    :config("a", "rebase.autostash" .. get_config_source_indicator("rebase.autostash"), {
      options = {
        { display = "true", value = "true" },
        { display = "false", value = "false" },
        {
          display = g_autostash:is_set() and ("global:" .. g_autostash.value) or "unset",
          value = "",
          condition = function() return g_autostash:is_set() end
        },
      },
    })
    :config("s", "pull.autostash" .. get_config_source_indicator("pull.autostash"), {
      options = {
        { display = "true", value = "true" },
        { display = "false", value = "false" },
        {
          display = g_pull_autostash:is_set() and ("global:" .. g_pull_autostash.value) or "unset",
          value = "",
          condition = function() return g_pull_autostash:is_set() end
        },
      },
    })
    :config_heading("")
    :config_heading("Pull & Merge Configuration")
    :config("r", "pull.rebase" .. get_config_source_indicator("pull.rebase"), {
      options = {
        { display = "true", value = "true" },
        { display = "false", value = "false" },
        {
          display = g_pull_rebase:is_set() and ("global:" .. g_pull_rebase.value) or "unset",
          value = "",
          condition = function() return g_pull_rebase:is_set() end
        },
      },
    })
    :config("f", "merge.ff" .. get_config_source_indicator("merge.ff"), {
      options = {
        { display = "true", value = "true" },
        { display = "false", value = "false" },
        { display = "only", value = "only" },
        { display = "unset", value = "" },
      },
    })
    :config_heading("")
    :config_heading("Push Configuration")
    :config("d", "push.default" .. get_config_source_indicator("push.default"), {
      options = {
        { display = "simple", value = "simple" },
        { display = "matching", value = "matching" },
        { display = "current", value = "current" },
        { display = "upstream", value = "upstream" },
        { display = "nothing", value = "nothing" },
        { display = "unset", value = "" },
      },
    })
    :config_heading("")
    :config_heading("Core User Settings")
    :config("n", "user.name" .. get_config_source_indicator("user.name"), {
      options = {
        { display = git.config.get("user.name").value or "unset", value = "" },
      },
    })
    :config("e", "user.email" .. get_config_source_indicator("user.email"), {
      options = {
        { display = git.config.get("user.email").value or "unset", value = "" },
      },
    })
    :config_heading("")
    :config_heading("Legend: [G]lobal [L]ocal")
    :group_heading("Actions")
    :action("q", "Quit", function() end)
    :env(env or {})
    :build()

  p:show()
  return p
end

return M