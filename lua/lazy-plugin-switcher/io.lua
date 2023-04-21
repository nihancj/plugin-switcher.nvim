M = {}

M.filename = vim.fn.stdpath("cache") .. "/lazypluginswitch.txt"

M.read = function ()
	local active_profiles = {}
	for line in io.lines(M.filename) do
		table.insert(active_profiles, line)
	end
return active_profiles end

M.write = function(profiles)
	local file = io.open(M.filename, "w")
	for _, profile in ipairs(profiles) do
		file:write(profile .. "\n")
	end
	io.close(file)
end

return M
