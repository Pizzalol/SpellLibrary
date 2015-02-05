--[[ ============================================================================================================
	Author: Rook
	Date: February 4, 2015
	Called when Arcane Boots is cast.  Restores mana to nearby allies.
	Additional parameters: keys.ReplenishAmount and keys.ReplenishRadius
================================================================================================================= ]]
function item_arcane_boots_datadriven_on_spell_start(keys)	
	keys.caster:EmitSound("DOTA_Item.ArcaneBoots.Activate")
	ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)

	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.ReplenishRadius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
	for i, individual_unit in ipairs(nearby_allied_units) do  --Restore mana and play a particle effect for every found ally.
		individual_unit:GiveMana(keys.ReplenishAmount)
		ParticleManager:CreateParticle("particles/items_fx/arcane_boots_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
	end
end