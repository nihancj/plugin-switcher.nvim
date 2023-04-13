local M = {}

M.active_profile = ""
M.core_plugins = {}
M.core_hooks = {}
M.io = require("lazy-plugin-switcher.io")

local is_valid_string = function(string)
	if string == nil or string == '' then
		return false
	end
	return true
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

	-- create auto command to save current session on exit
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = vim.api.nvim_create_augroup("lazy-plugin-switcher", { clear = true }),
		command = 'lua require("lazy-plugin-switcher").on_exit()',
	})
end

M.on_exit = function()
	M.io.write(M.active_profile)
end

M.load_profile = function(profile, is_on_startup)
	M.active_profile = profile
	local plugins = { plugins = M.core_plugins[profile] }
	require("lazy").load(plugins)

	if type(M.core_hooks[profile]) == "function" then
		M.core_hooks[profile](is_on_startup)
	end
end

M.toggle_profile = function(profile_name)
	if profile_name == M.active_profile then
		M.active_profile = ""
		vim.notify("Profile deacivated: " .. profile_name)
		return
	elseif not is_valid_string(M.core_plugins[profile_name]) then
		vim.notify("Invalid Profile")
		return
	end
	vim.notify("Profile acivated: " .. profile_name)
	M.load_profile(profile_name, false)
end

M.on_startup = function()
	-- fetching previous profile and loading it
	local prev_profile = M.io.read()
	if not is_valid_string(prev_profile) then
		return
	end
	M.load_profile(prev_profile, true)
end

M.setup = function(opts)
	M.config = opts
	for _, v in ipairs(opts["profiles"]) do
		M.core_plugins[v] = opts.plugins[v]
		M.core_hooks[v] = opts.hooks[v]
	end

	gen_commands()
	M.on_startup()
end

return M
