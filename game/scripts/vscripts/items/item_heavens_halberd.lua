--[[ ============================================================================================================
	Author: Rook
	Date: February 4, 2015
	Called when the unit lands an attack on a target and the chance to Lesser Maim is successful.  Applies the
	modifier so long as the target is not a structure.
================================================================================================================= ]]
function modifier_item_heavens_halberd_datadriven_on_attack_landed_random_on_success(keys)
	if keys.target.GetInvulnCount == nil then  --If the target is not a structure.
		keys.target:EmitSound("DOTA_Item.Maim")
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_item_heavens_halberd_datadriven_lesser_maim", nil)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 4, 2015
	Called when Heaven's Halberd is cast on an enemy unit.  Applies a disarm with a duration dependant on whether the
	target is melee or ranged.
	Additional parameters: keys.DisarmDurationRanged and keys.DisarmDurationMelee
================================================================================================================= ]]
function item_heavens_halberd_datadriven_on_spell_start(keys)
	keys.caster:EmitSound("DOTA_Item.HeavensHalberd.Activate")
	
	if keys.target:IsRangedAttacker() then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_heavens_halberd_datadriven_disarm", {duration = keys.DisarmDurationRanged})
	else  --The target is melee.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_heavens_halberd_datadriven_disarm", {duration = keys.DisarmDurationMelee})
	end
end