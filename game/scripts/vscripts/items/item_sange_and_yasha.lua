--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called when the unit lands an attack on a target and the chance to Greater Maim is successful.  Applies the
	modifier so long as the target is not a structure.
================================================================================================================= ]]
function modifier_item_sange_and_yasha_datadriven_on_attack_landed_random_on_success(keys)
	if keys.target.GetInvulnCount == nil then  --If the target is not a structure.
		keys.target:EmitSound("DOTA_Item.Maim")
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_item_sange_and_yasha_datadriven_greater_maim", nil)
	end
end