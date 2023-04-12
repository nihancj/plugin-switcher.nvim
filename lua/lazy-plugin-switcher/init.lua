local M = {}

M.active_profile = ''
M.core_plugins = {}
M.core_hooks = {}
M.io = require 'lazy-plugin-switcher.io'

M.setup = function (opts)
	for _, v in ipairs(opts["profiles"]) do
		M.core_plugins[v] = opts[v]
		M.core_hooks[v] = opts.hooks[v]
	end

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
	local profile = M.io.read()
	if profile == nil or  profile == '' then return end
	M.load_profile(profile, true)
end

M.on_exit = function ()
	M.io.write(M.active_profile)
end

return M
