local M = {}

M.active_profile = ''
M.core_plugins = {}
M.io = require 'lazy-plugin-switcher.io'

M.setup = function (opts)
	for _, v in ipairs(opts["profiles"]) do
		M.core_plugins[v] = opts[v]
	end

	M.on_startup()
end

M.toggle_profile = function (profile)
	if profile == M.active_profile then
		M.active_profile = ''
		return
	elseif M.core_plugins[profile] == nil or M.core_plugins[profile] == '' then
		print("Invalid Profile")
		return
	end
	M.load_profile(profile)
end

M.load_profile = function (profile)
	M.active_profile = profile
	local plugins = { plugins = M.core_plugins[profile] }
	require('lazy').load(plugins)
	vim.cmd "LspStart"
end

M.on_startup = function ()
	local profile = M.io.read()
	if profile == nil or  profile == '' then return end
	M.load_profile(profile)
end

M.on_exit = function ()
	M.io.write(M.active_profile)
end

return M
