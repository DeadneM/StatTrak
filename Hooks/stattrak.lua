local Net = _G.LuaNetworking
_G.StatTrak = _G.StatTrak or {}
StatTrak:Load()
local stattrak_guis = {}
StatTrak.mode = 1
StatTrak.distance = 0
StatTrak.force_text = nil

function StatTrak:update_screen()
	if not stattrak_guis then return end
	for k, v in pairs(stattrak_guis) do
		local text = "ERROR"
		local color = self.colors.err
		local font_size = 350
		if self.force_text then		
			text = self.force_text
			color = self.colors.modes
			font_size = 200
		elseif self.used_modes[self.mode] == "st_kills" then --StatTrak kills
			if managers.statistics._global.killed_by_weapon[v.id] and managers.statistics._global.killed_by_weapon[v.id].count then
				text = managers.statistics._global.killed_by_weapon[v.id].count
			else
				text = "0"
			end	
			color = self.colors.stattrak
		elseif self.used_modes[self.mode] == "st_headshots" then --StatTrak headshots
			if managers.statistics._global.killed_by_weapon[v.id] and managers.statistics._global.killed_by_weapon[v.id].headshots then
				text = "°" .. managers.statistics._global.killed_by_weapon[v.id].headshots .. "°"
			else
				text = "°0°"
			end
			color = self.colors.stattrak
		elseif self.used_modes[self.mode] == "st_acc" then --StatTrak accuracy
			if managers.statistics._global.shots_by_weapon[v.id] then
				local shots = managers.statistics._global.shots_by_weapon[v.id]
				text = math.floor(shots.hits/shots.total*100) .. "%"
			else
				text = "0%"
			end
			color = self.colors.stattrak
		elseif self.used_modes[self.mode] == "range_finder" then --Range finder
			text = self.distance .. " m"
			color = self.colors.misc
		elseif self.used_modes[self.mode] == "se_kills" then --Session kills
			if managers.statistics._global.session.killed_by_weapon[v.id] and managers.statistics._global.session.killed_by_weapon[v.id].count then
				text = managers.statistics._global.session.killed_by_weapon[v.id].count
			else
				text = "0"
			end
			color = self.colors.session
		elseif self.used_modes[self.mode] == "se_headshots" then --Session headshots
			if managers.statistics._global.session.killed_by_weapon[v.id] and managers.statistics._global.session.killed_by_weapon[v.id].headshots then
				text = "°" .. managers.statistics._global.session.killed_by_weapon[v.id].headshots .. "°"
			else
				text = "°0°"
			end
			color = self.colors.session
		elseif self.used_modes[self.mode] == "se_hs_per_kills" then --Session headshots/kills
			local hs = 0
			if managers.statistics._global.session.killed_by_weapon[v.id] and managers.statistics._global.session.killed_by_weapon[v.id].headshots then
				hs = managers.statistics._global.session.killed_by_weapon[v.id].headshots
			end
			local kills = 0
			if managers.statistics._global.session.killed_by_weapon[v.id] and managers.statistics._global.session.killed_by_weapon[v.id].count then
				kills = managers.statistics._global.session.killed_by_weapon[v.id].count
			end
			text = "°" .. hs .. "°" .. "/" .. kills
			color = self.colors.session
		elseif self.used_modes[self.mode] == "se_acc" then --Session accuracy
			if managers.statistics._global.session.shots_by_weapon[v.id] then
				local shots = managers.statistics._global.session.shots_by_weapon[v.id]
				text = math.floor(shots.hits/shots.total*100) .. "%"
			else
				text = "0%"
			end
			color = self.colors.session		
		elseif self.used_modes[self.mode] == "se_down" then --Downs
			local downs = managers.statistics._global.session.downed.bleed_out + managers.statistics._global.session.downed.incapacitated
			text = "!" .. downs .. "!"
			color = self.colors.misc
		elseif self.used_modes[self.mode] == "se_obj" then --Objectives completed
			local all_objs = managers.objectives:total_objectives(Global.level_data and Global.level_data.level_id)
			local objs = managers.statistics._global.session.objectives.count
			if all_objs == 0 then
				text = 	"[" .. objs .. "]"
			else
				text = 	"[" .. objs .. "]" .. " / " .. all_objs
			end
			color = self.colors.misc
		elseif self.used_modes[self.mode] == "se_dmg" then --Damage dealt
			text =  math.round(managers.statistics._global.session.damage_dealt and managers.statistics._global.session.damage_dealt[k] or 0)
			color = self.colors.misc
		end
		v.ws:panel():set_alpha(self._data.stattrak_brightness)
		for _, gui in pairs(v.guis) do
			gui:script().gui_text:set_text(text)
			gui:script().gui_text:set_font_size(font_size)
			gui:script().gui_text:set_color(color)
		end
	end
end
Hooks:PostHook( NewRaycastWeaponBase , "assemble_from_blueprint" , "assemblydone" , function(self, factory_id, blueprint, skip_queue, clbk)
	--log(factory_id)
	if not self._parts or (not self._parts["wpn_fps_trk_stattrak"] and not self._parts["wpn_fps_trk_pis_stattrak"]) then return end
	if string.match(self._factory_id, "npc") then return end
	local s_pos = Vector3(0,0,0)
	local s_rot = Rotation(0,0,0)
	if stattrak_pos and stattrak_pos[factory_id] then
		s_pos = stattrak_pos[factory_id].pos
		s_rot = stattrak_pos[factory_id].rot
	end
	local gui = World:newgui()
	local part = nil
	if self._parts["wpn_fps_trk_stattrak"] then
		part = self._parts["wpn_fps_trk_stattrak"]
	elseif self._parts["wpn_fps_trk_pis_stattrak"] then
		part = self._parts["wpn_fps_trk_pis_stattrak"]
	end
	if not part or not part.unit then return end
	local obj = part.unit:get_object(Idstring("g_gfx_lens"))
	rot = obj:rotation()
	rot2 = Rotation()
	obj:set_rotation(s_rot)
	local ws = gui:create_object_workspace(0, 0, obj, s_pos)
	local _gui = ws:panel():gui(Idstring("guis/savefile_manager"))
	if not stattrak_guis[factory_id] then
		stattrak_guis[factory_id] = {}
		stattrak_guis[factory_id].guis = {}
		stattrak_guis[factory_id].id = self._name_id
	end
	if not npc then
		table.insert(stattrak_guis[factory_id].guis, _gui)
		stattrak_guis[factory_id].ws = ws
	end
	local _gui_script = _gui:script()	
	_gui_script.gui_text:set_render_template(Idstring("Text"))
		-- "opacity_add" or "normal"
	_gui_script.gui_text:set_blend_mode("opacity_add")
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
	_gui_script.gui_text:set_text(StatTrak)
	_gui_script.gui_text:set_visible(true)
	StatTrak:update_screen()
end )
Hooks:PostHook( NewRaycastWeaponBase , "set_scope_range_distance" , "StatTrak_set_scope_range_distance" , function(self, distance)
	if not distance then return end
	if StatTrak.used_modes[StatTrak.mode] == "range_finder" then
		StatTrak.distance = math.round(distance)
		StatTrak:update_screen()
	end
end )
Hooks:PostHook( NewRaycastWeaponBase , "tweak_data_anim_play" , "StatTrak_tweak_data_anim_play" , function(self, anim, speed_multiplier)
	if not stattrak_guis[self._factory_id] then return end 
	if tostring(anim) == "unequip" then
		for k,v in pairs(stattrak_guis[self._factory_id].guis) do			
			v:hide()
		end
	elseif tostring(anim) == "equip" then
		for k,v in pairs(stattrak_guis[self._factory_id].guis) do			
			v:show()
		end
	end
end )