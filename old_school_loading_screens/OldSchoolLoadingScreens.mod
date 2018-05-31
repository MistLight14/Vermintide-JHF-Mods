local directory_name = "old_school_loading_screens"
local file_name = "OldSchoolLoadingScreens"

local main_script_path = "scripts/mods/"..directory_name.."/"..file_name

print("'"..file_name.."' Mod loading...")

local ret = {
	run = function()
		if new_mod then
			local mod = new_mod(file_name, {
				mod_script       = main_script_path,
				mod_data         = main_script_path .. "_data",
				mod_localization = main_script_path .. "_localization"
			})
		else
			print(file_name.." requires the Vermintide Mod Framework to function.")
		end
	end,
	packages = {
		"resource_packages/"..directory_name.."/"..file_name
	},
}
return ret