local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values

local files = function(opts)
  opts = opts or {}
  local files_list = vim.fn.systemlist("ls -a '" .. vim.fn.bufname() .. "'")
  local entries = vim.tbl_map(function(x)
      local abs_path = vim.fn.fnamemodify(vim.fn.bufname(), ":p:h") .. "/" .. x
    return { x, abs_path }
  end, files_list)
  pickers.new(opts, {
                prompt_title = "Files",
                finder = finders.bew_table {
                  results = entries,
                },
                entry_maker = function(entry)
                  return {
                    value = entry[1],
                    display = entry[1],
                    ordinal = entry[1],
                    path = entry[2],
                  }
                end,
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr)
                  actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    local path = selection.path
                    if vim.fn.isdirectory(path) == 1 then
                      vim.cmd("Dired " .. path)
                    else
                      vim.cmd("edit " .. path)
                    end
                  end)
                  return true
                end
  }):find()
end

return {
  files = files
}
