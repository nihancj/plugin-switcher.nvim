local M = {}

local au_group = vim.api.nvim_create_augroup("plugin-switcher", { clear = true })
local io = require("plugin-switcher.io")

M.profile = {}
M.profile.available = {}
M.profile.active = {}
M.profile.has_changed = false
M.filetype_mapping = {}
M.config = { plugins = {}, hooks = {}, ft = {}, persistence = {} }

local is_valid = function(value)
	if value == nil or value == "" or value == {} then
		return false
	end
	return true
end

local gen_filetype_mapping = vim.schedule_wrap(function()
	for profile, filetypes in pairs(M.config.ft) do
		for _, filetype in ipairs(filetypes) do
			M.filetype_mapping[filetype] = M.filetype_mapping[filetype] or {}
			table.insert(M.filetype_mapping[filetype], profile)
		end
	end
end)

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
	if is_valid(M.config.ft) then
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

M.profile.load = function(profile)
	require("lazy").load({ plugins = M.config.plugins[profile] })

	if type(M.config.hooks[profile]) == "function" then
		M.config.hooks[profile]()
	end
end

M.profile.safe_load = function(profile)
	if M.profile.is_active(profile) or not is_valid(M.config.plugins[profile]) then
		return
	end
	M.profile.load(profile)
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
	if not is_valid(M.config.persistence[profile_name]) or M.config.persistence[profile_name] == true then
		table.insert(M.profile.active, profile_name)
	end
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
		table.insert(M.profile.active, prev_profile)
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

	gen_filetype_mapping()
	gen_commands()
	M.on_startup()
end

return M
