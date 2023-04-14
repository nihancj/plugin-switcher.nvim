local M = {}

local au_group = vim.api.nvim_create_augroup("lazy-plugin-switcher", { clear = true })
local io = require("lazy-plugin-switcher.io")
M.active_profile = ""
M.filetype_mapping = {}
M.config = { profiles = {}, plugins = {}, hooks = {}, ft = {} }

local is_valid = function(value)
	if value == nil or value == "" or value == {} then
		return false
	end
	return true
end

local gen_filetype_mapping = function()
	for profile, filetypes in pairs(M.config.ft) do
		for _, filetype in ipairs(filetypes) do
			M.filetype_mapping[filetype] = M.filetype_mapping[filetype] or {}
			table.insert(M.filetype_mapping[filetype], profile)
		end
	end
end

local gen_commands = function()
	-- creating user command
	vim.api.nvim_create_user_command("SwitchPlugins", function(opts)
		require("lazy-plugin-switcher").toggle_profile(opts.fargs[1])
	end, {
		nargs = 1,
		complete = function(_, _, _)
			return M.config.profiles
		end,
	})

	-- auto command to save current session on exit
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = au_group,
		command = 'lua require("lazy-plugin-switcher").on_exit()',
	})
	-- auto command to check buffer filetype
	if is_valid(M.config.ft) then
		vim.api.nvim_create_autocmd("BufEnter", {
			group = au_group,
			command = 'lua require("lazy-plugin-switcher").check_buf_ft()',
		})
	end
end

M.on_exit = function()
	io.write(M.active_profile)
end

M.load_profile = function(profile, is_on_startup)
	if profile == M.active_profile or not is_valid(M.config.plugins[profile]) then
		return
	end
	M.active_profile = profile
	require("lazy").load({ plugins = M.config.plugins[profile] })

	if type(M.config.hooks[profile]) == "function" then
		M.config.hooks[profile](is_on_startup)
	end
end

M.toggle_profile = function(profile_name)
	if profile_name == M.active_profile then
		M.active_profile = ""
		vim.notify("Profile deacivated: " .. profile_name)
		return
	elseif not is_valid(M.config.plugins[profile_name]) then
		vim.notify("Invalid Profile")
		return
	end
	vim.notify("Profile acivated: " .. profile_name)
	M.load_profile(profile_name, false)
end

M.check_buf_ft = function()
	local current_filetype = vim.api.nvim_buf_get_option(0, "filetype")
	M.filetype_mapping[current_filetype] = M.filetype_mapping[current_filetype] or nil
	if is_valid(M.filetype_mapping[current_filetype]) then
		for _, profile in pairs(M.filetype_mapping[current_filetype]) do
			M.load_profile(profile)
		end
		M.filetype_mapping[current_filetype] = nil
	end
end

M.on_startup = function()
	local prev_profile = io.read()
	if not is_valid(prev_profile) then
		return
	end
	M.load_profile(prev_profile, true)
end

M.setup = function(user_opts)
	for option, value in pairs(user_opts) do
		M.config[option] = value
	end

	gen_filetype_mapping()
	gen_commands()
	M.on_startup()
end

return M
