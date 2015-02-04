--[[ ============================================================================================================
	Author: Rook
	Date: February 4, 2015
	Called when the unit lands an attack on a target.  Applies the modifier so long as the target is not a structure.
	Additional parameters: keys.ColdDurationMelee and keys.ColdDurationRanged
================================================================================================================= ]]
function modifier_item_skadi_datadriven_on_orb_impact(keys)
	if keys.target.GetInvulnCount == nil then
		if keys.caster:IsRangedAttacker() then
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_skadi_datadriven_cold_attack", {duration = keys.ColdDurationRanged})
		else  --The caster is melee.
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_skadi_datadriven_cold_attack", {duration = keys.ColdDurationMelee})
		end
	end
end