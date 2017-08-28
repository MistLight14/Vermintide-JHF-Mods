--[[
	author: Aussiemon
	
	-----
 
	Copyright 2017 Aussiemon

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
	-----
 
	Supplementary additions to grimalackt, iamlupo, and walterr's BotImprovements mod.
--]]

local mod_name = "BotImprovementsExtra"

-- ##########################################################
-- ################### Variables ############################

BotImprovementsExtra = {
	SETTINGS = {
		BOTS_BLOCK_ON_PATH_SEARCH = {
			["save"] = "cb_bot_improvements_extra_block_pathing",
			["widget_type"] = "stepper",
			["text"] = "Block While Path-Searching",
			["tooltip"] = "Block While Path-Searching\n" ..
				"Bots block as they pause to search for a path to the player.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		}
	}
}

-- ##########################################################
-- ################## Functions #############################

BotImprovementsExtra.create_options = function()
	if not BotImprovements then
		Mods.option_menu:add_group("bot_improvements_extra", "Bot Improvements Extra")
		Mods.option_menu:add_item("bot_improvements_extra", BotImprovementsExtra.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH, true)
	else
		Mods.option_menu:add_group("bot_improvements", "Bot Improvements")
		Mods.option_menu:add_item("bot_improvements", BotImprovementsExtra.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH, true)
	end
end

BotImprovementsExtra.manual_block = function(unit, blackboard, should_block, t)
	if unit and Unit.alive(unit) and blackboard and blackboard.input_extension then
		local input_extension = blackboard.input_extension
		
		if should_block then
			input_extension:wield("slot_melee")
			input_extension._defend = true
			blackboard._block_start_time_BIE = t
			
		elseif t > (blackboard._block_start_time_BIE + 1) then
			input_extension._defend = false
			blackboard._block_start_time_BIE = nil
		end
	end
end

BotImprovementsExtra.auto_block = function(unit, status)
	if unit and Unit.alive(unit) and ScriptUnit.has_extension(unit, "status_system") then
		local status_extension = ScriptUnit.extension(unit, "status_system")
		local go_id = Managers.state.unit_storage:go_id(unit)

		Managers.state.network.network_transmit:send_rpc_clients("rpc_set_blocking", go_id, status)
	   
		status_extension.set_blocking(status_extension, status)
	end
end

local get = function(data)
	return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings

-- ##########################################################
-- #################### Hooks ###############################

-- ## Bots Block on Path Search - Teleport to Ally Action ##
-- Start blocking as the teleport action begins
Mods.hook.set(mod_name, "BTBotTeleportToAllyAction.enter", function (func, self, unit, blackboard, t)
	
	if get(BotImprovementsExtra.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH) then 
		BotImprovementsExtra.manual_block(unit, blackboard, true, t)
	end
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	return result
end)

-- Continue blocking as the teleport action runs
Mods.hook.set(mod_name, "BTBotTeleportToAllyAction.run", function (func, self, unit, blackboard, t)
	
	if get(BotImprovementsExtra.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH) then 
		BotImprovementsExtra.manual_block(unit, blackboard, true, t)
	end
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	return result
end)

-- Cancel blocking when the teleport action ends
Mods.hook.set(mod_name, "BTBotTeleportToAllyAction.leave", function (func, self, unit, blackboard, t)
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	
	if get(BotImprovementsExtra.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH) then 
		BotImprovementsExtra.manual_block(unit, blackboard, false, t)
	end
	
	return result
end)


-- ## Bots Block on Path Search - Nil Action ##
-- Start blocking when the nil action ends, and hold the block until the game decides to release it
Mods.hook.set(mod_name, "BTNilAction.leave", function (func, self, unit, blackboard, t)
	
	if get(BotImprovementsExtra.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH) then 
		BotImprovementsExtra.manual_block(unit, blackboard, true, t)
	end
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	return result
end)

-- ##########################################################
-- ################### Script ###############################

BotImprovementsExtra.create_options()

-- ##########################################################
