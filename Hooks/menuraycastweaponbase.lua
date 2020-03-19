_G.StatTrak = _G.StatTrak or {}
local stattrak_guis = {}

function StatTrak:update_screen()
	if not stattrak_guis then return end
	for k, v in pairs(stattrak_guis) do
		v.gui:script().gui_text:set_alpha(self._data.stattrak_brightness)
		v.gui:script().background:set_alpha(self._data.stattrak_brightness_screen)
	end
end
Hooks:PostHook( NewRaycastWeaponBase , "_assemble_completed" , "StatTrak_assemble_completed" , function(self)
	--PrintTable(self._parts)
	if not self._parts or (not self._parts["wpn_fps_trk_stattrak"] and not self._parts["wpn_fps_trk_pis_stattrak"]) then
		if stattrak_guis[self._factory_id] then
			stattrak_guis[self._factory_id].gui:hide()
		end
		return 
	end
	local gui = World:newgui()
	local part = nil
	if self._parts["wpn_fps_trk_stattrak"] then
		part = self._parts["wpn_fps_trk_stattrak"]
	elseif self._parts["wpn_fps_trk_pis_stattrak"] then
		part = self._parts["wpn_fps_trk_pis_stattrak"]
	end
	if not part.unit then return end
	local s_pos = Vector3(0,0,0)
	local s_rot = Rotation(0,0,0)
	if stattrak_pos and stattrak_pos[self._factory_id] then
		s_pos = stattrak_pos[self._factory_id].pos
		s_rot = stattrak_pos[self._factory_id].rot
	end
	local obj = part.unit:get_object(Idstring("g_gfx_lens"))
	rot = obj:rotation()
	rot2 = Rotation()
	obj:set_rotation(s_rot)
	local ws = gui:create_object_workspace(0, 0, obj, s_pos)
	local _gui = ws:panel():gui(Idstring("guis/savefile_manager"))
	if stattrak_guis[self._factory_id] then
		stattrak_guis[self._factory_id].gui:hide()
	end
	stattrak_guis[self._factory_id] = {}
	stattrak_guis[self._factory_id].gui = _gui
	stattrak_guis[self._factory_id].ws = ws
	s_id = self._factory_id
	local _gui_script = _gui:script()
	_gui_script.indicator:set_visible(false)
	--Background--
		--"opacity_add" or --"normal"
	_gui_script.background:set_blend_mode("opacity_add")
		--Rounded effect="VertexColorTexturedPatterns" or
		--Rect opaque="OverlayVertexColorTextured" or
		--Rect transp="VertexColorTextured"
	_gui_script.background:set_render_template(Idstring("VertexColorTextured"))
	_gui_script.background:set_w(_gui_script.background:parent():w())
	_gui_script.background:set_h(_gui_script.background:parent():h())
	_gui_script.background:set_center_x(_gui_script.background:parent():w()/2)
	_gui_script.background:set_center_y(_gui_script.background:parent():h()/2)
	_gui_script.background:set_align("center")
	_gui_script.background:set_color(StatTrak.colors.bg)
	_gui_script.background:set_visible(true)
	--Text--
		-- "opacity_add" or --"normal"
	_gui_script.gui_text:set_blend_mode("opacity_add")
	_gui_script.gui_text:set_render_template(Idstring("Text"))
	_gui_script.gui_text:set_font_size(300)
	_gui_script.gui_text:set_w(_gui_script.gui_text:parent():w())
	_gui_script.gui_text:set_h(_gui_script.gui_text:parent():h())
	_gui_script.gui_text:set_center_x(_gui_script.gui_text:parent():w()/2)
	_gui_script.gui_text:set_center_y(_gui_script.gui_text:parent():h()/2)
	_gui_script.gui_text:set_align("center")
	_gui_script.gui_text:set_color(StatTrak.colors.stattrak)
	local text = "0"
	if managers.statistics and  managers.statistics._global and managers.statistics._global.killed_by_weapon and managers.statistics._global.killed_by_weapon[self._name_id] and managers.statistics._global.killed_by_weapon[self._name_id].count then
		text = managers.statistics._global.killed_by_weapon[self._name_id].count
	end
	_gui_script.gui_text:set_text(text)
	_gui_script.gui_text:set_visible(true)
	StatTrak:update_screen()
end )
Hooks:PostHook( NewRaycastWeaponBase , "_update_stats_values" , "change_wpn_parts" , function(self)
	local parts = self._parts
	if parts["wpn_fps_trk_stattrak"] or parts["wpn_fps_trk_pis_stattrak"] then return end
	for k, v in pairs(stattrak_guis) do
		if k ~= self._factory_id then
			v.gui:hide()
		end
	end
end )
Hooks:PreHook( MenuSceneManager , "_delete_character_weapon" , "change_wpn_parts3" , function(self, owner, type)
	local weapons = {}
	self._weapon_units[owner:key()] = self._weapon_units[owner:key()] or {}
	if type == "all" then
		table.insert(weapons, self._weapon_units[owner:key()].primary)
		table.insert(weapons, self._weapon_units[owner:key()].secondary)
	else
		table.insert(weapons, self._weapon_units[owner:key()][type])
	end
	for _, old_weapon_data in ipairs(weapons) do
		local name = old_weapon_data.name
		for k, v in pairs(stattrak_guis) do
			local id = Idstring(tweak_data.weapon.factory[k].unit)
			if id == name then
				v.gui:hide()
			end
		end
	end
end )
Hooks:PostHook( MenuComponentManager , "_create_lobby_chat_gui" , "change_wpn_parts2" , function(self)
	for k, v in pairs(stattrak_guis) do
		v.gui:hide()
	end
end )