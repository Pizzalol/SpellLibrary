--[[
Author: Ragnar Homsar
Date: July 14, 2015

NOTE: At time of writing, Warpath is currently missing both its particle effects and run/idle animations.

WARPATH_MODEL_SCALE_PER_STACK: How much to add to the current model scale whenever a stack is created, and how much to remove when destroyed.

WARPATH_MODEL_SCALE_BASE: The initial model scale--needed because Bristleback's default model scale isn't 1.0.

ability_executed: Called by the hidden factory modifier whenever an ability is executed. Decides what buffs to place. Also handles model scale additions.

stack_destroyed: Called when a stack's duration expires. Sets the stack count on the counter modifier (or destroys it) appropriately and does model scale reductions.
]]

WARPATH_MODEL_SCALE_PER_STACK = 0.0125
WARPATH_MODEL_SCALE_BASE = 0.8

function ability_executed(params)
	local counter_buff = params.unit:FindModifierByName("modifier_warpath_datadriven_counter")

	-- If the handle to the unit passed in params doesn't have a model scale variable, create it.
	if params.unit.warpath_model_scale == nil then
		params.unit.warpath_model_scale = WARPATH_MODEL_SCALE_BASE
	end

	-- If the counter buff doesn't exist, create it. After creation, reassign the counter_buff variable so it's no longer nil.
	if counter_buff == nil then
		params.ability:ApplyDataDrivenModifier(params.unit, params.unit, "modifier_warpath_datadriven_counter", nil)
		counter_buff = params.unit:FindModifierByName("modifier_warpath_datadriven_counter")
	end

	-- If the current amount of stacks is under the max, create a new stack, set the counter stack number, and reset the counter's duration.
	if counter_buff:GetStackCount() < params.max_stacks then
		params.unit.warpath_model_scale = params.unit.warpath_model_scale + WARPATH_MODEL_SCALE_PER_STACK
		params.ability:ApplyDataDrivenModifier(params.unit, params.unit, "modifier_warpath_datadriven_stack", nil)
		counter_buff:IncrementStackCount()
		counter_buff:SetDuration(params.duration, true)
		params.unit:SetModelScale(params.unit.warpath_model_scale)

	-- Else, if we are over the number of maximum stacks, destroy a random stack and make a new one.
	else
		params.unit:FindModifierByName("modifier_warpath_datadriven_stack"):Destroy()
		params.ability:ApplyDataDrivenModifier(params.unit, params.unit, "modifier_warpath_datadriven_stack", nil)
		counter_buff:IncrementStackCount()
		counter_buff:SetDuration(params.duration, true)
		-- To counteract the scale reduction done in stack_destroyed.
		params.unit.warpath_model_scale = params.unit.warpath_model_scale + WARPATH_MODEL_SCALE_PER_STACK
		params.unit:SetModelScale(params.unit.warpath_model_scale)
	end
end

function stack_destroyed(params)
	local counter_buff = params.caster:FindModifierByName("modifier_warpath_datadriven_counter")

	-- Reduce model scale.
	params.caster.warpath_model_scale = params.caster.warpath_model_scale - WARPATH_MODEL_SCALE_PER_STACK
	params.caster:SetModelScale(params.caster.warpath_model_scale)

	-- If there's still stacks remaining, just decrement the stack counter.
	if counter_buff:GetStackCount() > 1 then
		counter_buff:DecrementStackCount()

	-- If the most recently destroyed stack was the last one, destroy the counter as well.
	else
		counter_buff:Destroy()
	end
end