-- local variables for API functions. any changes to the line below will be lost on re-generation
local client_color_log, client_delay_call, client_set_clan_tag, client_userid_to_entindex, entity_get_all, entity_get_local_player, entity_get_prop, globals_curtime, globals_tickcount, globals_tickinterval, json_parse, math_ceil, renderer_indicator, string_format, table_insert, table_remove, ui_get, ui_new_button, ui_new_checkbox, ui_new_combobox, ui_new_label, ui_new_multiselect, ui_new_slider, ui_reference, pairs, type, ui_set, ui_set_callback, ui_set_visible = client.color_log, client.delay_call, client.set_clan_tag, client.userid_to_entindex, entity.get_all, entity.get_local_player, entity.get_prop, globals.curtime, globals.tickcount, globals.tickinterval, json.parse, math.ceil, renderer.indicator, string.format, table.insert, table.remove, ui.get, ui.new_button, ui.new_checkbox, ui.new_combobox, ui.new_label, ui.new_multiselect, ui.new_slider, ui.reference, pairs, type, ui.set, ui.set_callback, ui.set_visible

--[[

					Coded by: ally ( Allison / UID 2187 )
					
								Credits
						 Shavit - Clantag Spammer

						Credits to code reviewers
					   	  Jessica, Shavit, Phil

					Credits to who came up with the idea
							 	Lee Surge

            /////////////////////////////////////////////////////////           
      /////////////////////////////////////////////////////////////////////     
    /////////////////////////////////////////////////////////////////////////   
  ///////////////////////////////////////////////////////////////////////////// 
 ///////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///////////////////////////////%@@@@@@@@@@@@@@@@@&//////////////////////////////
///////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@//////////////////////////
////////////////////////%@@@@@@@/////////////////@@@@@@@&///////////////////////
//////////////////////&@@@@@@/////////@@@@@/////////&@@@@@&/////////////////////
/////////////////////@@@@@#/////////@@@@@@@@@@@@%/////(@@@@@////////////////////
////////////////////@@@@@/////////////@@@@@@@@@@@@@/////@@@@@///////////////////
///////////////////@@@@@/////@////////@@@@@@@@@@@@@@(////@@@@@//////////////////
///////////////////@@@@(////@@@@////@@@@@@@@@@@@@@@@@////(@@@@//////////////////
//////////////////(@@@@/////@@@@@@@@@@@@@@@@@@@@@@@@@/////@@@@#/////////////////
///////////////////@@@@(////@@@@@@@@@@@@@@@@@@@@@@@@@////(@@@@//////////////////
///////////////////@@@@@/////@@@@@@@@@@@@@@@@@@@@@@@(////@@@@@//////////////////
////////////////////@@@@@/////@@@@@@@@@@@@@@@@@@@@@/////@@@@@///////////////////
/////////////////////@@@@@#/////%@@@@@@@@@@@@@@@@/////(@@@@@////////////////////
//////////////////////&@@@@@@////////%@@@@@@////////&@@@@@&/////////////////////
////////////////////////%@@@@@@@/////////////////@@@@@@@&///////////////////////
///////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@//////////////////////////
///////////////////////////////%@@@@@@@@@@@@@@@@@&//////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
 ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////// 
    /////////////////////////////////////////////////////////////////////////   
      ////////////////////////////////////////////////////////////////////

--]]

-- Requires
local http 				= require "gamesense/http"

-- Label Creation, Vibration Queue, and api connection
local website, port 	= 'unknown','0000'
local vibration_queue	= { }
local master_switch 	= ui_new_checkbox("Config", "Lua", "Lovense")
local title 			= ui_new_label("Config", "Lua", '                Current Lovense Info')
local sep 				= ui_new_label("Config", "Lua", "-------------------------------------------------")

-- Information spacing
local data 				= ui_new_label("Config", "Lua", website..':'..port)
local space 			= ui_new_label("Config", "Lua", "\n")

-- All Vibration Information
local options 			= ui_new_multiselect("Config", "Lua", "Activators", 'Kill', 'On Hit', 'On Death')
local toys 				= ui_new_combobox("Config", "Lua", 'Lovense Sex Toys', 'Edge', 'Other')
local max 				= ui_new_slider("Config", "Lua", "Max Intensity", 0, 20, 20)
local hitmarker 		= ui_new_slider("Config", "Lua", "On Hit Intensity", 0, 20, 20)
local lovense_ind 		= ui_new_checkbox("Config", "Lua", "Lovense Indicator")
local clantag			= ui_new_checkbox("Config", "Lua", "Lovense Clantag")

-- Ui References
local menu_color		= ui_reference("MISC", "Settings", "Menu color")

local function color_print(...)
    local args = {...}
    local color, def = {255, 255, 255}
    local text, len = "No text", #args
    for k,v in pairs(args) do
        if type(v) == "table" then
            v[1] = v[1] or 255
            v[2] = v[2] or 255
            v[3] = v[3] or 255
            color = v
        else
            text = v
            client_color_log(color[1], color[2], color[3], text .. (k == len and "" or "\0"))
        end
    end

	return color_print
end

-- Credits - L.A gave me this awhile back when I first created the lua
function table.remove_indices(self)
    local return_table = {}

    for index, value in next, self do
        if type(value) == 'table' then
            table_insert(return_table, table.remove_indices(value))
        else
            table_insert(return_table, value)
        end
    end

    return return_table
end

-- Function for handling all vibration requests
local function sex_toy(speed, time, special)
	local format_string = special and "http://%s:%s/AVibrate1?v=%s&sec=%s&AVbrate2?v=%s&sec=%s" or "http://%s:%s/Vibrate?v=%s"
	local url = string_format(format_string, website, port, speed, time, speed, time)
	http.get(url, function(success, response)
		if response.body == nil then return end
		local parsed = json_parse(response.body)
		local status = ( parsed.code == '200' ) and 'Vibration Successful!' or 'Vibration Unsuccesful!'
		color_print({247, 44, 133}, "[Lovense] ", {255, 255, 255}, status)
	end)
end

-- Function for checking the api lan page for all required information
local lovense = ui_new_button("Config", "Lua", "Connect to Lovense", function ()
	http.get("https://api.lovense.com/api/lan/getToys", function(success, response)
		local response = table.remove_indices(json_parse(response.body))
		if (response == nil or response[1] == nil) then color_print({247, 44, 133}, "[Lovense] ", {255, 255, 255}, "No Devices found!") return end
		website = response[1][1]
		port = response[1][3]
		if website ~= nil and port ~= nil then
			color_print({247, 44, 133}, "[Lovense] ", {255, 255, 255}, "Device has been paired!")
			ui_set(data, website..':'..port)
			ui_set(master_switch, false)
			ui_set(master_switch, true)
		end
	end)
end)

-- Menu items
local menu_items        = { title, sep, data, space, options, toys, max, hitmarker, lovense_ind, lovense, clantag }

local function contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

local function clamp(val, min, max)
	local new_val = val
	new_val = new_val < min and min or new_val
	new_val = new_val > max and max or new_val
	return new_val
end

local inf = {
	kills 		= 0,
	scoreKills 	= 0,
	deaths 		= 0,
	headshot 	= 0
}

local function on_paint()
	if entity_get_local_player() ~= nil then

		if #vibration_queue > 0 then
			local request = vibration_queue[1]
			if not request[5] then
				color_print({247, 44, 133}, "[Lovense] ", {255, 255, 255}, string.format("Vibration sent for %d seconds at %d strength.", request[3], request[2]))
				sex_toy(request[2], request[3], request[1] == 'Edge' and true or false)
				request[4] = globals_curtime()
				request[5] = true
			else
				if request[4]+request[3] < globals_curtime() then
					table_remove(vibration_queue, 1)
					sex_toy(0, 0, false)
				end
			end
		end

		if ui_get(lovense_ind) and inf.scorekills and inf.kills > 0 then

			local strength = clamp(math_ceil(inf.kills/inf.deaths*5), 0, ui_get(max))
			local time = math_ceil((inf.headshot/inf.scorekills)*100/7)
			local cc = {ui_get(menu_color)}
			renderer_indicator(cc[1], cc[2], cc[3], cc[4], string_format('Str: %d (K/D) | Sec: %d (HS%%)', strength, time))

		end

	end
end

local function on_setup_command(cmd)
	local player_resource = entity_get_all("CCSPlayerResource")[1]
	local local_player = entity_get_local_player()
	inf.kills 		= entity_get_prop(player_resource, "m_iKills", local_player)
	inf.scorekills 	= entity_get_prop(player_resource, "m_iMatchStats_Kills_Total", local_player)
	inf.deaths 		= entity_get_prop(player_resource, "m_iDeaths", local_player)
	inf.headshot 	= entity_get_prop(player_resource, "m_iMatchStats_HeadShotKills_Total", local_player)
end

local function register_kill(event)
	local killer_index 	= client_userid_to_entindex(event.attacker)
	local victim_index 	= client_userid_to_entindex(event.userid)
	local toy 			= (ui_get(toys) == 'Edge') and 'Edge' or 'Other'
	local local_player 	= entity_get_local_player()

	if victim_index == local_player then

		if contains(ui_get(options), 'On Death') then

			table_insert(vibration_queue, {toy, ui_get(max), 0, globals_curtime(), false})

		end

	elseif killer_index == local_player then

		local kd = clamp(math_ceil(inf.kills/inf.deaths*5), 0, ui_get(max))
		local time = math_ceil((inf.headshot/inf.scorekills)*100/7)
		if contains(ui_get(options), 'Kill') and time > 0.50 then
		
			local strength_method = (event.weapon == 'knife') and ui_get(max) or kd
			table_insert(vibration_queue, {toy, strength_method, time, globals_curtime(), false})

		end
	end
end

local function register_hit(event)
	if not contains(ui_get(options), 'On Hit') then return end
	local toy = (ui_get(toys) == 'Edge') and 'Edge' or 'Other'
	table_insert(vibration_queue, {toy, ui_get(hitmarker), 1, globals_curtime(), false})
end

local function reset_vibrator()
	local toy = (ui_get(toys) == 'Edge') and 'Edge' or 'Other'
	table_insert(vibration_queue, {toy, ui_get(hitmarker), 1, globals_curtime(), false})
end

local function restore_clantag()
	cvar.cl_clanid:invoke_callback()
end

local function net_update_end()
	if ui_get(clantag) then
		if globals_tickcount() % 16 == 0 then
			local strength 	= clamp(math_ceil(inf.kills/inf.deaths*5), 0, ui_get(max))
			local time 		= math_ceil((inf.headshot/inf.scorekills)*100/7)
            client_set_clan_tag(string_format("Lovense: %d/%ds", strength, time))
        end
	end
end

local function handle_clantag(ref)
	local enabled = ui_get(ref)

	if not enabled then
		client_delay_call(globals_tickinterval() * 3, restore_clantag)
	end
end


local function handle_callbacks(state)
	local call_back = (website ~= 'unknown' and state) and client.set_event_callback or client.unset_event_callback

	-- Handles player information
	call_back('setup_command', on_setup_command)

	-- Vibration Queue / Indicator
	call_back('paint', on_paint)

	-- Vibration Triggers
	call_back("aim_hit", register_hit)
	call_back('player_death', register_kill)

	-- Clantag Spammer ( Because Why Not)
	call_back('net_update_end', net_update_end)
	ui_set_callback(clantag, handle_clantag)

	-- Resets Vibrator
	call_back("round_end", reset_vibrator)
	call_back("round_start", reset_vibrator)
	call_back("client_disconnect", reset_vibrator)
	call_back("level_init", reset_vibrator)
	call_back("player_connect_full", function(e) if client_userid_to_entindex(e.userid) == entity_get_local_player() then reset_vibrator() end end)
end

local function handle_master_switch(ref)
	local enabled = ui_get(ref)

	for i = 1, #menu_items do
		ui_set_visible(menu_items[i], enabled)
	end

	handle_callbacks(enabled)
end

ui_set_callback(master_switch, handle_master_switch)
handle_master_switch(master_switch)