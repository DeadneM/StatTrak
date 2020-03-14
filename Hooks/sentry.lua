-- unit:get_objects("*")


function SentryGunBase.spawn(owner, pos, rot, peer_id, verify_equipment, unit_idstring_index)
	local attached_data = SentryGunBase._attach(pos, rot)
	if not attached_data then
		return
	end
	if verify_equipment and not managers.player:verify_equipment(peer_id, "sentry_gun") then
		return
	end
	local sentry_owner
	if owner and owner:base().upgrade_value then
		sentry_owner = owner
	end
	local player_skill = PlayerSkill
	local ammo_multiplier = player_skill.skill_data("sentry_gun", "extra_ammo_multiplier", 1, sentry_owner)
	local armor_multiplier = 1 + (player_skill.skill_data("sentry_gun", "armor_multiplier", 1, sentry_owner) - 1) + (player_skill.skill_data("sentry_gun", "armor_multiplier2", 1, sentry_owner) - 1)
	local spread_level = player_skill.skill_data("sentry_gun", "spread_multiplier", 1, sentry_owner)
	local rot_speed_level = player_skill.skill_data("sentry_gun", "rot_speed_multiplier", 1, sentry_owner)
	local ap_bullets = player_skill.has_skill("sentry_gun", "ap_bullets", sentry_owner)
	local has_shield = player_skill.has_skill("sentry_gun", "shield", sentry_owner)
	local id_string = Idstring("units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry")
	if unit_idstring_index then
		id_string = tweak_data.equipments.sentry_id_strings[unit_idstring_index]
	end
	local unit = World:spawn_unit(id_string, pos, rot)
	log(tostring(unit))
	
	
	
	
	--log("objs:")
	local objs = table.collect(unit:get_objects_by_type(Idstring("material")), function(object)
			return object:name()
		end)
	--log(tostring(objs))
	--log(tostring(Idstring("c_box_base")))
	local obj = unit:get_object(Idstring("s_gun"))
	--log(tostring(obj))
	
	local yaw = rot:yaw()
	local pitch = rot:pitch()
	local roll = rot:roll()
	obj:set_rotation(Rotation(yaw-90,pitch-90,roll+0))
	local gui = World:newgui()
	local ws = gui:create_object_workspace(0, 0, obj, Vector3(200,2090,-5.37))
	ws:panel():set_w(1000)
	ws:panel():set_h(400)
	local _gui = ws:panel():gui(Idstring("guis/savefile_manager"))
	--log(tostring(ws:panel():width()))
	--log(tostring(ws:panel():height()))
	local _gui_script = _gui:script()	
	_gui_script.gui_text:set_render_template(Idstring("Text"))
	_gui_script.indicator:set_visible(false)
	_gui_script.gui_text:set_font_size(300)	
	_gui_script.gui_text:set_w(_gui_script.gui_text:parent():w())
	_gui_script.gui_text:set_h(_gui_script.gui_text:parent():h())
	_gui_script.gui_text:set_center_x(_gui_script.gui_text:parent():w()/2)
	_gui_script.gui_text:set_center_y(_gui_script.gui_text:parent():h()/2)
	_gui_script.gui_text:set_align("center")
	_gui_script.gui_text:set_color(Color(0.32,0.38,0.35))
	_gui_script.gui_text:set_text("StatTrak")
	_gui_script.gui_text:set_visible(true)	
	_gui_script.background:set_color(Color(0.015,0.03,0.045))
	_gui_script.background:set_visible(true)
	
	
	
	local spread_multiplier = SentryGunBase.SPREAD_MUL[spread_level]
	local rot_speed_multiplier = SentryGunBase.ROTATION_SPEED_MUL[rot_speed_level]
	managers.network:session():send_to_peers_synched("sync_equipment_setup", unit, 0, peer_id or 0)
	ammo_multiplier = SentryGunBase.AMMO_MUL[ammo_multiplier]
	unit:base():setup(owner, ammo_multiplier, armor_multiplier, spread_multiplier, rot_speed_multiplier, has_shield, attached_data)
	local owner_id = unit:base():get_owner_id()
	if ap_bullets and owner_id then
		local fire_mode_unit = World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry_fire_mode"), unit:position(), unit:rotation())
		unit:weapon():interaction_setup(fire_mode_unit, owner_id)
		managers.network:session():send_to_peers_synched("sync_fire_mode_interaction", unit, fire_mode_unit, owner_id)
	end
	local team
	if owner then
		team = owner:movement():team()
	else
		team = managers.groupai:state():team_data(tweak_data.levels:get_default_team_ID("player"))
	end
	unit:movement():set_team(team)
	unit:brain():set_active(true)
	SentryGunBase.deployed = (SentryGunBase.deployed or 0) + 1
	return unit, spread_level, rot_speed_level
end

Hooks:PostHook( SentryGunBase , "init" , "StatTrak_spawn" , function(unit)
	log("sdf")
	log(tostring(unit._unit))
	log("asd")
end )

Hooks:PostHook( SentryGunBase , "pre_destroy" , "StatTrak_spawn" , function(self)
	log("sdf")
	log(tostring(self._unit))
	log("asd")
end )