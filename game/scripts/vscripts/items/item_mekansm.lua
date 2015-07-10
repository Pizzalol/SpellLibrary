--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when Mekansm is cast.  Heals nearby units if they have not been healed by a Mekansm recently.
	Additional parameters: keys.HealAmount and keys.HealRadius
================================================================================================================= ]]
function item_mekansm_datadriven_on_spell_start(keys)	
	keys.caster:EmitSound("DOTA_Item.Mekansm.Activate")
	ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)

	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.HealRadius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
	for i, nearby_ally in ipairs(nearby_allied_units) do  --Restore health and play a particle effect for every found ally.
		if not nearby_ally:HasModifier("modifier_item_mekansm_datadriven_heal_debuff") then
			nearby_ally:Heal(keys.HealAmount, keys.caster)
		end
		
		nearby_ally:EmitSound("DOTA_Item.Mekansm.Target")
		ParticleManager:CreateParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, nearby_ally)
		
		keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_item_mekansm_datadriven_heal_armor", nil)
		keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_item_mekansm_datadriven_heal_debuff", nil)
	end
end