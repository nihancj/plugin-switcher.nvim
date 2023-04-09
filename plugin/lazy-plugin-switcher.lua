vim.api.nvim_create_user_command('SwitchPlugins',
	function (opts)
		require("lazy-plugin-switcher").toggle_profile(opts.fargs[1])
	end,
	{ nargs=1 })

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("lazy-plugin-switcher", {clear = true}),
	command = 'lua require("lazy-plugin-switcher").on_exit()'
	})
