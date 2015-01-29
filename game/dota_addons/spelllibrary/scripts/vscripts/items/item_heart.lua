--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when the unit takes damage.  Puts the Heart(s) in the player's inventory on cooldown, with a duration
	dependant on whether the unit is melee or ranged.
	Additional parameters: keys.CooldownMelee
================================================================================================================= ]]
function modifier_item_heart_datadriven_regen_on_take_damage(keys)
	if keys.caster:IsRangedAttacker() then
		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
	else  --If the caster is melee.
		keys.ability:StartCooldown(keys.CooldownMelee)
	end
	
	if keys.caster:HasModifier("modifier_item_heart_datadriven_regen_visible") then
		keys.caster:RemoveModifierByNameAndCaster("modifier_item_heart_datadriven_regen_visible", keys.caster)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called regularly while one or more Heart of Tarrasques are in the unit's inventory.  Heals them if the item is
	off cooldown, and displays an icon on the caster's modifier bar.
	Additional parameters: keys.HealthRegenPercentPerSecond and keys.HealInterval
================================================================================================================= ]]
function modifier_item_heart_datadriven_regen_on_interval_think(keys)
	if keys.ability:IsCooldownReady() and keys.caster:IsRealHero() then
		keys.caster:Heal(keys.caster:GetMaxHealth() * (keys.HealthRegenPercentPerSecond / 100) * keys.HealInterval, keys.caster)
		if not keys.caster:HasModifier("modifier_item_heart_datadriven_regen_visible") then
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_heart_datadriven_regen_visible", {duration = -1})
		end
	elseif keys.caster:HasModifier("modifier_item_heart_datadriven_regen_visible") then  --This is mostly a failsafe.
		keys.caster:RemoveModifierByNameAndCaster("modifier_item_heart_datadriven_regen_visible", keys.caster)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Heart of Tarrasque is dropped or sold or something.  Removes the visible modifier from the modifier bar.
================================================================================================================= ]]
function modifier_item_heart_datadriven_regen_on_destroy(keys)
	keys.caster:RemoveModifierByNameAndCaster("modifier_item_heart_datadriven_regen_visible", keys.caster)
end