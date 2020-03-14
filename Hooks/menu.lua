_G.StatTrak = _G.StatTrak or {}
StatTrak._path = ModPath
StatTrak._data_path = SavePath .. "StatTrak_options.txt"
StatTrak._data = {}
StatTrak.modes = {"st_kills", "st_headshots",  "st_acc",  "se_kills", "se_headshots", "se_hs_per_kills", "se_acc","range_finder","se_down", "se_obj", "se_dmg"}
StatTrak.colors = {
	stattrak = Color(0.32,0.38,0.35),
	session = Color(0.45, 0.38, 0.18),
	modes = Color(0.5, 0.5, 0.5),
	bg = Color(0,0,0),
	err = Color(0.5,0,0),
	misc = Color(0.45,0.25,0.35)
}
StatTrak.used_modes = {}
function StatTrak:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
	StatTrak.used_modes = {}
	for k, v in pairs(StatTrak.modes) do
		if StatTrak._data["mode_" .. v] then
			table.insert(StatTrak.used_modes, v)
		end
	end
end
function StatTrak:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
		if self._data.stattrak_brightness == nil then self._data.stattrak_brightness = 1 end
		if self._data.mode_st_kills == nil then self._data.mode_st_kills = true end
		if self._data.mode_st_headshots == nil then self._data.mode_st_headshots = true end
		if self._data.mode_st_acc == nil then self._data.mode_st_acc = true end
		if self._data.mode_range_finder == nil then self._data.mode_range_finder = true end
		if self._data.mode_se_kills == nil then self._data.mode_se_kills = true end
		if self._data.mode_se_headshots == nil then self._data.mode_se_headshots = true end
		if self._data.mode_se_hs_per_kills == nil then self._data.mode_st_hs_per_kills = true end
		if self._data.mode_se_acc == nil then self._data.mode_se_acc = true end
		if self._data.mode_se_down == nil then self._data.mode_se_down = true end
		if self._data.mode_se_obj == nil then self._data.mode_se_obj = true end
		if self._data.mode_se_dmg == nil then self._data.mode_se_dmg = true end
		StatTrak:Save()
	end
	StatTrak.used_modes = {}
	for k, v in pairs(StatTrak.modes) do
		--log(v)
		if StatTrak._data["mode_" .. v] then
			table.insert(StatTrak.used_modes, v)
		end
	end
end
Hooks:Add("MenuManagerInitialize", "StatTrak_MenuManagerInitialize", function(menu_manager)
	MenuCallbackHandler.stattrak_save = function(self, item)
		StatTrak:Save()
	end	
	MenuCallbackHandler.stattrak_brightness = function(self, item)
		StatTrak._data.stattrak_brightness = item:value()
		if StatTrak.update_screen then
			StatTrak:update_screen()
		end
	end	
	MenuCallbackHandler.stattrak_mode_st_kills = function(self, item)
		StatTrak._data.mode_st_kills = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_mode_st_headshots = function(self, item)
		StatTrak._data.mode_st_headshots = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_mode_st_acc = function(self, item)
		StatTrak._data.mode_st_acc = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_mode_range_finder = function(self, item)
		StatTrak._data.mode_range_finder = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_mode_se_kills = function(self, item)
		StatTrak._data.mode_se_kills = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_mode_se_headshots = function(self, item)
		StatTrak._data.mode_se_headshots = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_mode_se_hs_per_kills = function(self, item)
		StatTrak._data.mode_se_hs_per_kills = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_mode_se_acc = function(self, item)
		StatTrak._data.mode_se_acc = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_mode_se_down = function(self, item)
		StatTrak._data.mode_se_down = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_mode_se_obj = function(self, item)
		StatTrak._data.mode_se_obj = (item:value() == "on" and true or false)
	end
	MenuCallbackHandler.stattrak_mode_se_dmg = function(self, item)
		StatTrak._data.mode_se_dmg = (item:value() == "on" and true or false)
	end	
	MenuCallbackHandler.stattrak_change_mode = function(self)
		if Utils:IsInHeist() then
			StatTrak.mode = StatTrak.mode + 1
			if StatTrak.mode > #StatTrak.used_modes then
				StatTrak.mode = 1
			end
			if not DelayedCalls or not DelayedCalls._calls then return end
			if #StatTrak.used_modes > 0 then
				StatTrak.force_text = managers.localization:text("st_mode_" .. StatTrak.used_modes[StatTrak.mode])
			else
				StatTrak.force_text = managers.localization:text("st_mode_empty")
			end
			local function refresh()
				StatTrak.force_text = nil
				StatTrak:update_screen()
			end
			
			for k, v in pairs(DelayedCalls._calls) do
				if v.stattrak then
					DelayedCalls._calls[k] = nil
				end
			end
			DelayedCalls:Add("StatTrak_show_mode", 1, refresh)
			DelayedCalls._calls["StatTrak_show_mode"].stattrak = true
			StatTrak:update_screen()			
		end
	end
	StatTrak:Load()
	MenuHelper:LoadFromJsonFile(StatTrak._path .. "Hooks/options.txt", StatTrak, StatTrak._data)
end )