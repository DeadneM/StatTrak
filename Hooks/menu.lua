_G.StatTrak = _G.StatTrak or {}
StatTrak._path = ModPath
StatTrak._menu_file = StatTrak._path .. "Hooks/options.txt"
StatTrak._data_path = SavePath .. "StatTrak_options.txt"
StatTrak._data = {}
StatTrak.modes = {
	"st_kills",
	"st_headshots",
	"st_acc",
	"se_kills",
	"se_headshots",
	"se_hs_per_kills",
	"se_acc",
	"range_finder",
	"se_down",
	"se_obj",
	"se_dmg"
}
StatTrak.colors = {
	modes = Color(0.5, 0.5, 0.5),
	stattrak = Color(0.4, 0.3, 0.6),
	session = Color(0.5, 0.4, 0.2),
	misc = Color(0.6, 0.2, 0.15),
	bg = Color(0, 0, 0),
	err = Color(1, 0, 0)
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
	MenuCallbackHandler.stattrak_change_mode = function(self, item)
	--Do nothing as we set the keybind in mod.txt for folder structure
	end
	StatTrak:Load()
	MenuHelper:LoadFromJsonFile(StatTrak._menu_file, StatTrak, StatTrak._data)
end )