--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called when the unit lands an attack on a target.  Applies a brief lifesteal modifier if not attacking a structure 
	(Lifesteal blocks in KV files will normally allow the unit to heal when attacking these), depending on whether
	Satanic has been activated.
================================================================================================================= ]]
function modifier_item_satanic_datadriven_on_attack_landed(keys)
	if keys.target.GetInvulnCount == nil then
		if keys.caster:HasModifier("modifier_item_satanic_datadriven_unholy_rage") then  --The caster has Satanic's active on them.
			keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_satanic_datadriven_unholy_rage_lifesteal", {duration = 0.03})
		end
		
		--The bonus lifesteal from Satanic's active effect stacks additively with its passive lifesteal, so always apply the base lifesteal modifier.
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_satanic_datadriven_lifesteal", {duration = 0.03})
	end
end