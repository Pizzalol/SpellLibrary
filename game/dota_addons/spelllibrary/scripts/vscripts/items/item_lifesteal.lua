--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when the unit lands an attack on a target.  Applies a brief lifesteal modifier if not attacking a structure 
	or mechanical unit (Lifesteal blocks in KV files will normally allow the unit to heal when attacking these).
================================================================================================================= ]]
function modifier_item_lifesteal_datadriven_on_attack_landed(keys)
	if keys.target.GetInvulnCount == nil and not keys.target:IsMechanical() then
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_lifesteal_datadriven_lifesteal", {duration = 0.03})
	end
end