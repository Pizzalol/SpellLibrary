--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when a hero affected by Urn of Shadows' hidden aura dies.  Increases the charges on the Urn.
	Known bugs:
		All players within range with Urns will gain a charge.  Only the closest Urn is supposed to.
		If multiple Urns are in a player's inventory, the one with the least amount of charges will gain a charge;
			this may work differently in the standard Dota 2 mode.
================================================================================================================= ]]
function modifier_item_urn_of_shadows_datadriven_aura_on_death(keys)	
	--Search for an Urn of Shadows in the aura creator's inventory.  If there are multiple Urns in the player's inventory,
	--the one with the least charges receives a charge (this may work differently in the standard Dota 2 mode).
	local urn_with_least_charges = nil
	
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			local item_name = current_item:GetName()
			
			if item_name == "item_urn_of_shadows_datadriven" then
				if urn_with_least_charges == nil then
					urn_with_least_charges = current_item
				elseif current_item:GetCurrentCharges() < urn_with_least_charges:GetCurrentCharges() then
					urn_with_least_charges = current_item
				end
			end
		end
	end

	if urn_with_least_charges ~= nil then
		if urn_with_least_charges:GetCurrentCharges() == 0 then
			urn_with_least_charges:SetCurrentCharges(2)
		else
			urn_with_least_charges:SetCurrentCharges(urn_with_least_charges:GetCurrentCharges() + 1)
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when a hero is killed by the player.  Increases the charges on the Urn if the killed hero was not within range.
	Known bugs:
		All players within range with Urns will gain a charge.  It may be that only one charge per kill is supposed to be awarded.
================================================================================================================= ]]
function modifier_item_urn_of_shadows_datadriven_aura_emitter_on_kill(keys)
	--We want to award a charge in the event of a long-range kill as well.  The killed unit will still have the aura modifier
	--on them if they are in range (in which case item_urn_of_shadows_modifier_aura_on_death() would award the killer a charge),
	--but will not have the modifier if they are out of range.
	if not keys.unit:HasModifier("modifier_item_urn_of_shadows_datadriven_aura") then
		item_urn_of_shadows_modifier_aura_on_death(keys)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called regularly while an enemy has Urn of Shadows' damaging modifier on them.  Damages them.
	Additional parameters: keys.TotalDamage, keys.TotalDuration, and keys.Interval
================================================================================================================= ]]
function modifier_item_urn_of_shadows_datadriven_damage_on_interval_think(keys)
	local damage_to_deal = keys.TotalDamage / keys.TotalDuration   --This gives us the damage per second.
	damage_to_deal = damage_to_deal * keys.Interval   --This gives us the damage per interval.
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage_to_deal, damage_type = DAMAGE_TYPE_PURE,})
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called regularly while an enemy has Urn of Shadows' healing modifier on them.  Heals them.
	Additional parameters: keys.TotalHeal keys.TotalDuration, and keys.Interval
================================================================================================================= ]]
function modifier_item_urn_of_shadows_datadriven_heal_on_interval_think(keys)
	local amount_to_heal = keys.TotalHeal / keys.TotalDuration   --This gives us the heal per second.
	amount_to_heal = amount_to_heal * keys.Interval   --This gives us the heal per interval.
	keys.target:Heal(amount_to_heal, keys.caster)
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when a unit with Urn of Shadows' heal modifier takes damage.  Removes the modifier if the damage was caused
	by a hero or tower.
	Additional parameters: keys.Damage
================================================================================================================= ]]
function modifier_item_urn_of_shadows_datadriven_heal_on_take_damage(keys)
	--Remove all Urn healing modifiers if this unit was damaged by an enemy hero or tower.
	if keys.Damage > 0 and (keys.attacker:IsTower() or keys.attacker:IsHero()) then
		keys.unit:RemoveModifierByName("modifier_item_urn_of_shadows_datadriven_heal")
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when Urn of Shadows is cast.  Applies the healing or damaging modifier, depending on if the targeted unit is
	an ally or enemy.
================================================================================================================= ]]
function item_urn_of_shadows_datadriven_on_spell_start(keys)
	keys.target:EmitSound("DOTA_Item.UrnOfShadows.Activate")
	
	if keys.caster:GetTeam() == keys.target:GetTeam() then   --Apply the healing version of the Urn modifier.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_urn_of_shadows_datadriven_heal", nil)
	else  --Apply the damaging version of the Urn modifier.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_urn_of_shadows_datadriven_damage", nil)
	end
	
	keys.ability:SetCurrentCharges(keys.ability:GetCurrentCharges() - 1)  --Decrement the charges on the Urn by one.
end