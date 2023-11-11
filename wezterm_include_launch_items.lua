local lfs = require("lfs")

function add_slash(s)
    if s:find("\"$") then
        s = s:sub(1, -2) .. "/"
    elseif not s:find("/$") then
        s = s .. "/"
    elseif s:find("//$") then
        s = s:sub(1, -2)
    end
    return s
end

-- The update_menu function
local function include_launch_items(userDirectory, directory, key, launch_menu_directory)
	local sourceDirectory = ""

	directory = add_slash(string.gsub(directory, "\\", "/"))

	if not userDirectory then
		userDirectory = string.gsub(os.getenv('HOME'), "\\", "/")
	else
		userDirectory = string.gsub(userDirectory, "\\", "/")
	end

	if not launch_menu_directory then
		launch_menu_directory = userDirectory .. "/.config/wezterm/config/launch_menu.lua"
	else
		launch_menu_directory = string.gsub(launch_menu_directory, "\\", "/")
	end

	local sourceDirectory = userDirectory .. directory

	local file, err = io.open(launch_menu_directory, "r")

	-- Check if the file was opened successfully
	if file then
		local lines = {}
		for line in file:lines() do
			table.insert(lines, line)
		end
		file:close()

		-- Find the lines with the comments and remember their indices
		local startIndex, endIndex = nil, nil
		for i, line in ipairs(lines) do
			if line:find("^%s*%-%- Include the '" .. key .. "' directories to menu items below here%s*$") then
				startIndex = i
			elseif line:find("^%s*%-%- Ends Include the '" .. key .. "' directories to menu items below here%s*$") then
				endIndex = i
			end
		end

		-- If the comments were found, replace the lines between them
		if startIndex and endIndex then
			-- Remove the old lines
			for i = endIndex - 1, startIndex + 1, -1 do
				table.remove(lines, i)
			end

			-- Insert the new lines
			for item in lfs.dir(sourceDirectory) do
				if item ~= "." and item ~= ".." then
					local fullPath = sourceDirectory .. "/" .. item
					if lfs.attributes(fullPath, "mode") == "directory" then
						table.insert(lines, startIndex + 1, '\ttable.insert(menuItems, {')
						table.insert(lines, startIndex + 2, '\t\tlabel = "' key .. " - " .. item .. '",')
						table.insert(lines, startIndex + 3, '\t\targs = { "' .. add_slash(userDirectory) .. 'scoop/shims/pwsh.exe" },')
						table.insert(lines, startIndex + 4, '\t\tcwd = "' .. fullPath .. '",')
						table.insert(lines, startIndex + 5, '\t\tdomain = { DomainName = "local" },')
						table.insert(lines, startIndex + 6, '\t})')
						startIndex = startIndex + 6
					end
				end
			end
		end

		-- Write the modified file
		file = io.open(launch_menu_directory, "w")
		for _, line in ipairs(lines) do
			file:write(line .. "\n")
		end
		file:close()
	else
		print("Failed to open file: " .. err)
	end
end

-- Parse command-line arguments
local args = { ... }
local userDirectory, directory, key, launch_menu_directory = nil, nil, nil, nil
for i = 1, #args do
	if args[i]:find("^%-%-userDirectory=") then
		userDirectory = args[i]:gsub("^%-%-userDirectory=", "")
	elseif args[i]:find("^%-%-directory=") then
		directory = args[i]:gsub("^%-%-directory=", "")
	elseif args[i]:find("^%-%-key=") then
		key = args[i]:gsub("^%-%-key=", "")
	elseif args[i]:find("^%-%-launch_menu_directory=") then
		launch_menu_directory = args[i]:gsub("^%-%-launch_menu_directory=", "")
	end
end

-- Call the update_menu function with the parsed arguments
if directory and key then
	include_launch_items(userDirectory, directory, key, launch_menu_directory)
else
	if not directory then
		print("Directory is required.")
	end
	if not key then
		print("Key is required.")
	end
end
