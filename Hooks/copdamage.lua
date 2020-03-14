Hooks:PostHook( CopDamage , "_on_damage_received" , "StatTrak_on_damage_received" , function(self, damage_info)
	if not damage_info or not damage_info.attacker_unit or not damage_info.damage then return end
	if not damage_info.weapon_unit or not damage_info.weapon_unit.base then return end
	local attacker = alive(damage_info.attacker_unit) and damage_info.attacker_unit
	if attacker ~= managers.player:player_unit() then return end
	if damage_info.is_molotov then return end
	-- if not damage_info.weapon_unit:base()._factory_id then return end	
	if damage_info or type(damage_info) ~= 'number' then return end
	local factory_id = damage_info.weapon_unit:base()._factory_id
	if not factory_id then
		return
	end
	managers.statistics._global.session.damage_dealt = managers.statistics._global.session.damage_dealt or {}
	managers.statistics._global.session.damage_dealt[factory_id] = managers.statistics._global.session.damage_dealt[factory_id] or 0	
	local damage = tonumber(damage_info.damage)*10 or 0	
	managers.statistics._global.session.damage_dealt[factory_id] = managers.statistics._global.session.damage_dealt[factory_id] + damage
	StatTrak:update_screen()
end )