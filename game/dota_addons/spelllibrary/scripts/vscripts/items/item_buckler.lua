--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when Buckler is cast.  Applies a modifier to nearby units with a duration dependent on whether the unit
	is a hero or non-hero.
	Additional parameters: keys.ActiveRadius, keys.ActiveDurationUnit, and keys.ActiveDurationHero
================================================================================================================= ]]
function item_buckler_datadriven_on_spell_start(keys)	
	keys.caster:EmitSound("DOTA_Item.Buckler.Activate")
	ParticleManager:CreateParticle("particles/items_fx/buckler.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)

	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.ActiveRadius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
	for i, nearby_ally in ipairs(nearby_allied_units) do
		if nearby_ally:IsHero() then
			keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_item_buckler_datadriven_active", {duration = keys.ActiveDurationHero})
		else
			keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_item_buckler_datadriven_active", {duration = keys.ActiveDurationUnit})
		end
	end
end