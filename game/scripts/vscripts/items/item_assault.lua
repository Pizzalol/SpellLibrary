--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when the debuff aura modifier is created and regularly while it is on an enemy unit.  Since the debuff aura
	modifier should only be visible if the enemy team has vision over its emitter, check to see if this is the case and
	add or remove a visible aura accordingly.
================================================================================================================= ]]
function modifier_item_assault_datadriven_enemy_aura_on_interval_think(keys)
	local is_emitter_visible = keys.target:CanEntityBeSeenByMyTeam(keys.caster)
	
	if is_emitter_visible and not keys.target:HasModifier("modifier_item_assault_datadriven_enemy_aura_visible") then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_assault_datadriven_enemy_aura_visible", {duration = -1})
	elseif not is_emitter_visible and keys.target:HasModifier("modifier_item_assault_datadriven_enemy_aura_visible") then
		keys.target:RemoveModifierByNameAndCaster("modifier_item_assault_datadriven_enemy_aura_visible", keys.caster)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when the debuff aura modifier is removed.  Removes the associated visible modifier, if applicable.
================================================================================================================= ]]
function modifier_item_assault_datadriven_enemy_aura_on_destroy(keys)
	keys.target:RemoveModifierByNameAndCaster("modifier_item_assault_datadriven_enemy_aura_visible", keys.caster)
end