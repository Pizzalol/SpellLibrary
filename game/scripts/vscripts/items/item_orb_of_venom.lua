--[[ ============================================================================================================
	Author: Rook
	Date: February 4, 2015
	Called when a unit with an Orb of Venom lands an attack on a target.  Applies the correct Poison Attack modifier
	to the target, depending on whether the caster is a melee or ranged hero.
================================================================================================================= ]]
function modifier_item_orb_of_venom_datadriven_on_orb_impact(keys)	
	if keys.target.GetInvulnCount == nil then  --If the target is not a structure.
		--Orb of Venom refreshes the duration of whatever Poison Attack debuff version was first applied to the target,
		--even if both a melee and ranged hero have an Orb of Venom and are attacking the same target.  While unintuitive,
		--the behavior is maintained here for parity.
		if keys.target:HasModifier("modifier_item_orb_of_venom_datadriven_poison_attack_ranged") then
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_orb_of_venom_datadriven_poison_attack_ranged", nil)
		elseif keys.target:HasModifier("modifier_item_orb_of_venom_datadriven_poison_attack_melee") then
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_orb_of_venom_datadriven_poison_attack_melee", nil)
		else
			if keys.caster:IsRangedAttacker() then
				keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_orb_of_venom_datadriven_poison_attack_ranged", nil)
			else  --The caster is melee.
				keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_orb_of_venom_datadriven_poison_attack_melee", nil)
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 4, 2015
	Called regularly while Orb of Venom's Poison Attack is affecting a unit.  Damages them.
	Additional parameters: keys.PoisonDamagePerSecond and keys.PoisonDamageInterval
================================================================================================================= ]]
function modifier_item_orb_of_venom_datadriven_poison_attack_on_interval_think(keys)	
	local damage_to_deal = keys.PoisonDamagePerSecond * keys.PoisonDamageInterval   --This gives us the damage per interval.
	local current_hp = keys.caster:GetHealth()
	
	if damage_to_deal >= current_hp then  --Poison Attack damage over time is non-lethal, so deal less damage if needed.
		damage_to_deal = current_hp - 1
	end
	
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage_to_deal, damage_type = DAMAGE_TYPE_MAGICAL,})
end