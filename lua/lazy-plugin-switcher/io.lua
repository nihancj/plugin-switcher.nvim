M =
{
	filename = vim.fn.stdpath("cache") .. "/lazypluginloader.json"
}

-- Only reads from active_profile at the moment.
M.read = function ()
	local file = io.open(M.filename, "r")
	io.input(file)
	local json = io.read()
	io.close(file)
	local settings = vim.fn.json_decode(json)
return settings["active_profiles"] end

-- Only writes to active_profile at the moment.
M.write = function(text)
	local settings = { active_profiles = text }
	local json = vim.fn.json_encode(settings)
	local file = io.open(M.filename, "w+")
	io.output(file)
	io.write(json)
	io.close(file)
end

return M
