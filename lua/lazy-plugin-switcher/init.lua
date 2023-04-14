local M = {}

M.io = require("lazy-plugin-switcher.io")
M.config = { profiles = {}, plugins = {}, hooks = {}, ft = {} }
M.active_profile = ""

local is_valid_string = function(string)
	if string == nil or string == "" then
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

	-- auto command to save current session on exit
	local au_group = vim.api.nvim_create_augroup("lazy-plugin-switcher", { clear = true })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = au_group,
		command = 'lua require("lazy-plugin-switcher").on_exit()',
	})
	-- auto command to check buffer filetype
	vim.api.nvim_create_autocmd("BufEnter", {
		group = au_group,
		command = 'lua require("lazy-plugin-switcher").check_buf_ft()',
	})
end

M.on_exit = function()
	M.io.write(M.active_profile)
end

M.load_profile = function(profile, is_on_startup)
	local plugins = { plugins = M.config.plugins[profile] }
	require("lazy").load(plugins)

	if type(M.config.hooks[profile]) == "function" then
		M.config.hooks[profile](is_on_startup)
	end
end

M.toggle_profile = function(profile_name)
	if profile_name == M.active_profile then
		M.active_profile = ""
		vim.notify("Profile deacivated: " .. profile_name)
		return
	elseif not is_valid_string(M.config.plugins[profile_name]) then
		vim.notify("Invalid Profile")
		return
	end
	vim.notify("Profile acivated: " .. profile_name)
	M.active_profile = profile_name
	M.load_profile(profile_name, false)
end

M.check_buf_ft = function()
	local current_filetype = vim.api.nvim_buf_get_option(0, "filetype")
	for profile, profile_fts in pairs(M.config.ft) do
		for _, profile_ft in ipairs(profile_fts) do
			if current_filetype == profile_ft then
				M.load_profile(profile)
				M.config.ft[profile] = {}
				break
			end
		end
	end
end

M.on_startup = function()
	local prev_profile = M.io.read()
	if not is_valid_string(prev_profile) then
		return
	end
	M.active_profile = prev_profile
	M.load_profile(prev_profile, true)
end

M.setup = function(user_opts)
   for option, value in pairs(user_opts) do
      M.config[option] = value
   end

	gen_commands()
	M.on_startup()
end

return M
