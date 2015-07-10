--[[
	Author: Noya
	Date: 16.01.2015.
	After the passive is upgraded, it checks all player controled units for the modifiers to update the buff.

	Note: To actually apply a synergy buff on every summoned unit as soon they are spawned, you'll need to run a thinker that globally checks your controlled units and applies modifier.
]]
function SynergyLevel( event )
	local caster = event.caster
	local targets = event.target_entities
	local ability = event.ability

	-- Unit name contains a part of the unit name, so you can make different levels of the unit and they will still be registered
	-- If you change this to "npc_" in the parameter passed, it will affect all self-controlled units
	local unit_name = event.unit_name
	
	-- Re-apply modifier_bear_synergy, only check for units that start with the unit_name
	for _,unit in pairs(targets) do
		print(unit:GetUnitName())
		if unit:GetOwner() == caster then
			local u = unit:GetUnitName()
			local string_contains_unit = string.find( tostring(u) , tostring(unit_name))

			if string_contains_unit == 1 then
				print("Remove and apply")
				unit:RemoveModifierByName("modifier_bear_synergy")
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_bear_synergy", {} )
			end
		end
	end

	-- Re-apply modifier_true_form on the caster
	if caster:HasModifier("modifier_true_form_synergy") then
		caster:RemoveModifierByName("modifier_true_form_synergy")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_true_form_synergy", {} )
	end

end