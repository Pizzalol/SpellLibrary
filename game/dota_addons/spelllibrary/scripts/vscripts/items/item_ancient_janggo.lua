--[[ ============================================================================================================
	Author: Rook
	Date: February 5, 2015
	Called when Drum of Endurance is cast.  Consumes a charge to give nearby units the Endurance buff modifier.
	Additional parameters: keys.EnduranceRadius
================================================================================================================= ]]
function item_ancient_janggo_datadriven_on_spell_start(keys)	
	local current_charges = keys.ability:GetCurrentCharges()
	
	if current_charges >= 1 then
		keys.caster:EmitSound("DOTA_Item.DoE.Activate")

		local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.EnduranceRadius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
			
		for i, nearby_ally in ipairs(nearby_allied_units) do  --Apply the buff modifier to every found ally.
			keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_item_ancient_janggo_datadriven_endurance", nil)
		end
		
		keys.ability:SetCurrentCharges(current_charges - 1)  --Decrement the charges on the Drum by one.
	else  --The caster doesn't have any charges on the item, so it can't be cast.
		keys.ability:EndCooldown()
		keys.ability:RefundManaCost()
	end
end