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