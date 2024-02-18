local M = {}

local au_group = vim.api.nvim_create_augroup("plugin-switcher", { clear = true })
local io = require("plugin-switcher.io")

M.profile = {}
M.profile.available = {}
M.profile.active = {}
M.profile.has_changed = false
M.filetype_mapping = {}
M.config = { plugins = {}, filetype_plugins = {}, hooks = {}, persistence = {} }

local is_valid = function(value)
	if value == nil or value == "" or value == {} then
		return false
	end
	return true
end

local gen_commands = function()
	-- creating user command
	vim.api.nvim_create_user_command("Pload", function(opts)
		require("plugin-switcher").profile.toggle(opts.fargs[1])
	end, {
		nargs = 1,
		complete = function(_, _, _)
			return M.profile.available
		end,
	})

	-- auto command to save current session on exit
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = au_group,
		command = 'lua require("plugin-switcher").on_exit()',
	})
	-- auto command to check buffer filetype
	if is_valid(M.config.filetype_plugins) then
		vim.api.nvim_create_autocmd("BufEnter", {
			group = au_group,
			command = 'lua require("plugin-switcher").check_buf_ft()',
		})
	end
end

M.on_exit = function()
	if M.profile.has_changed then
		io.write(M.profile.active)
	end
end

M.profile.is_active = function(profile_name)
	for key, value in pairs(M.profile.active) do
		if value == profile_name then
			return key
		end
	end
end

local load = function(plugins_n_hook)
	require("lazy").load({ plugins = plugins_n_hook[1] })

	if type(plugins_n_hook[2]) == "function" then
		plugins_n_hook[2]()
	end
end

M.profile.load = function(profile_name)
	if M.profile.is_active(profile_name) then
		return
	end
	if is_valid(M.config.plugins[profile_name]) then
		load({ M.config.plugins[profile_name], M.config.hooks[profile_name] })
		table.insert(M.profile.active, profile_name)
	elseif is_valid(M.config.filetype_plugins[profile_name]) then
		load({ M.config.filetype_plugins[profile_name], M.config.hooks[profile_name] })
	end
end

M.profile.toggle = function(profile_name)
	M.profile.has_changed = true
	local active = M.profile.is_active(profile_name)
	if active then
		vim.notify("Profile deacivated: " .. profile_name)
		table.remove(M.profile.active, active)
		return
	elseif not is_valid(M.config.plugins[profile_name]) then
		vim.notify("Invalid Profile")
		return
	end
	vim.notify("Profile acivated: " .. profile_name)
	-- if not is_valid(M.config.persistence[profile_name]) or M.config.persistence[profile_name] == true then
	-- 	table.insert(M.profile.active, profile_name)
	-- end
	M.profile.load(profile_name)
end

M.check_buf_ft = vim.schedule_wrap(function()
	local current_filetype = vim.api.nvim_buf_get_option(0, "filetype")
	M.filetype_mapping[current_filetype] = M.filetype_mapping[current_filetype] or nil
	if is_valid(M.filetype_mapping[current_filetype]) then
		for _, profile in pairs(M.filetype_mapping[current_filetype]) do
			M.profile.safe_load(profile)
		end
		M.filetype_mapping[current_filetype] = nil
	end
end)

M.on_startup = function()
	local prev_profiles = io.read()
	if not is_valid(prev_profiles) then
		return
	end
	for _, prev_profile in ipairs(prev_profiles) do
		M.profile.load(prev_profile)
	end
end

M.setup = function(user_opts)
	for option, value in pairs(user_opts) do
		M.config[option] = value
		if option == "plugins" then
			for profile_name, _ in pairs(value) do
				table.insert(M.profile.available, profile_name)
			end
		end
	end

	gen_commands()
	M.on_startup()
end

return M
