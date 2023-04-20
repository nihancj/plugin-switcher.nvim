M = {}

M.filename = vim.fn.stdpath("cache") .. "/lazypluginswitch.txt"

M.read = function ()
	local active_profiles = {}
	for line in io.lines(M.filename) do
		table.insert(active_profiles, line)
	end
return active_profiles end

M.write = function()
	local active_profiles = require("lazy-plugin-switcher").profile.active
	local file = io.open(M.filename, "w")
	for _, line in ipairs(active_profiles) do
		file:write(line .. "\n")
	end
	io.close(file)
end

return M
