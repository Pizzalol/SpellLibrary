--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called when Shadow Blade is cast.  Turns the caster invisible after a delay.
	Additional parameters: keys.WindwalkFadeTime
================================================================================================================= ]]
function item_invis_sword_datadriven_on_spell_start(keys)
	keys.caster:EmitSound("DOTA_Item.InvisibilitySword.Activate")
	
	--Start Shadow Blade's effect after the fade delay.
	Timers:CreateTimer({
		endTime = keys.WindwalkFadeTime,
		callback = function()
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_invis_sword_datadriven_active", nil)
		end
	})
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called when a unit under the effects of Shadow Blade's active attacks.
	Additional parameters: keys.WindwalkBonusDamage
================================================================================================================= ]]
function modifier_item_invis_sword_datadriven_active_on_attack_landed(keys)
	keys.caster:RemoveModifierByName("modifier_item_invis_sword_datadriven_active")
	if keys.target.GetInvulnCount == nil then  --If the caster is not attacking a building.
		ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.WindwalkBonusDamage, damage_type = DAMAGE_TYPE_PHYSICAL,})
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called regularly while under the effects of Shadow Blade's active.  Repeatedly apply the stock modifier_invisible
	for the sole purpose of making the unit have a transparent texture.  This can be gotten rid of when we discover
	how to apply a translucent texture manually.
================================================================================================================= ]]
function modifier_item_invis_sword_datadriven_active_on_interval_think(keys)
	keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_invisible", {duration = .1})
end
