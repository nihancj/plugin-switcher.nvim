local M = {}

M.active_profile = ''
M.core_plugins = {}
M.core_hooks = {}
M.io = require 'lazy-plugin-switcher.io'

local gen_commands = function ()
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

M.setup = function (opts)
	M.config = opts
	for _, v in ipairs(opts["profiles"]) do
		M.core_plugins[v] = opts.plugins[v]
		M.core_hooks[v] = opts.hooks[v]
	end

	gen_commands()
	M.on_startup()
end

M.toggle_profile = function (profile)
	if profile == M.active_profile then
		M.active_profile = ''
		vim.notify("Profile deacivated: " .. profile)
		return
	elseif M.core_plugins[profile] == nil or M.core_plugins[profile] == '' then
		vim.notify("Invalid Profile")
		return
	end
	vim.notify("Profile acivated: " .. profile)
	M.load_profile(profile, false)
end

M.load_profile = function (profile, is_on_startup)
	M.active_profile = profile
	local plugins = { plugins = M.core_plugins[profile] }
	require('lazy').load(plugins)

	if M.core_hooks[profile] ~= nil then
		M.core_hooks[profile](is_on_startup)
	end
end


M.on_startup = function ()
	-- reading previous session data
	local profile = M.io.read()
	if profile == nil or  profile == '' then return end
	M.load_profile(profile, true)
end

M.on_exit = function ()
	M.io.write(M.active_profile)
end

return M
