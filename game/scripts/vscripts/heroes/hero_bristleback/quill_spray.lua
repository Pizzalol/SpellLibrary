--[[
Author: Ragnar Homsar
Date: July 12, 2015

Handles the functionality for creating new invisible Quill Spray debuffs and damaging the target based on the stack count.
]]

function stack_created(params)
	local parent = params.target
	local modifier_ui_handle = parent:FindModifierByName("modifier_quill_spray_datadriven_user_display")

	-- If the visual stack counter modifier doesn't exist on the parent unit, create it.
	if modifier_ui_handle == nil then
		params.ability:ApplyDataDrivenModifier(params.caster, parent, "modifier_quill_spray_datadriven_user_display", nil)
		modifier_ui_handle = parent:FindModifierByName("modifier_quill_spray_datadriven_user_display")
	end

	-- Determine the total damage by adding the base Quill Spray damage to the stack damage multiplied by the number of stacks.
	local final_damage = params.base_damage + (params.stack_damage * modifier_ui_handle:GetStackCount())

	-- If the total damage exceeds the defined maximum damage, clamp it.
	if final_damage > params.max_damage then
		final_damage = params.max_damage
	end

	-- The table containing the information needed for ApplyDamage.
	local damage_table =
	{
		victim = parent,
		attacker = params.caster,
		damage = final_damage,
		damage_type = params.ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = params.ability,
	}

	ApplyDamage(damage_table)

	-- Increase the visual stack counter debuff's stack count, and reset the duration. True for SetDuration refers to whether or not to inform clients of the duration reset; in this case, we very much want to inform them.
	modifier_ui_handle:IncrementStackCount()
	modifier_ui_handle:SetDuration(params.stack_duration, true)
end

function stack_destroyed(params)
	local parent = params.target
	local modifier_ui_handle = parent:FindModifierByName("modifier_quill_spray_datadriven_user_display")

	-- If a unit dies while still having quill stacks on them, stack_destroyed is called even though the stack counter buff has disappeared due to the unit dying.
	-- This causes an error if we don't check for if the stack counter is nil.
	if modifier_ui_handle ~= nil then
		-- If the unit still has Quill Spray stacks, just decrement the visual counter.
		if modifier_ui_handle:GetStackCount() > 1 then
			modifier_ui_handle:DecrementStackCount()
		-- If the unit has no more Quill Spray stacks, destroy the visual counter.
		elseif modifier_ui_handle:GetStackCount() == 1 then
			modifier_ui_handle:Destroy()
		end
	end
end

-- This is the first modifier that's applied to units hit by Quill Spray. It runs a simple check on the parent unit, and applies the appropriate debuff (for particle effect reasons).
function determine_debuff(params)
	if params.target:IsHero() then
		params.ability:ApplyDataDrivenModifier(params.caster, params.target, "modifier_quill_spray_datadriven_stack_hero", {duration = params.stack_duration})
	elseif params.target:IsCreep() then
		params.ability:ApplyDataDrivenModifier(params.caster, params.target, "modifier_quill_spray_datadriven_stack_creep", {duration = params.stack_duration})
	end
end