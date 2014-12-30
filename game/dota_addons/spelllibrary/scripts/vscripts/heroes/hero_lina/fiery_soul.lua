--[[Handling the stacking of Linas Fiery Soul ability
	Author: Pizzalol
	Date: 30.12.2014.]]
function FierySoul( keys )
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = ability:GetLevelSpecialValueFor("fiery_soul_max_stacks", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierName

	-- Always remove the stack modifier
	caster:RemoveModifierByName("modifier_fiery_soul_buff_stack_datadriven") 

	-- Counts the current stacks
	for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == "modifier_fiery_soul_buff_datadriven" then
			currentStack = currentStack + 1
		end
	end

	-- Remove all the old buff modifiers
	for i = 0, currentStack do
		print("Removing modifiers")
		caster:RemoveModifierByName("modifier_fiery_soul_buff_datadriven")
	end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fiery_soul_buff_stack_datadriven", {})

	-- Reapply the maximum number of stacks
	if currentStack >= maxStack then
		caster:SetModifierStackCount("modifier_fiery_soul_buff_stack_datadriven", ability, maxStack)

		-- Apply the new refreshed stack
		for i = 0, maxStack do
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_fiery_soul_buff_datadriven", {})
		end
	else
		-- Increase the number of stacks if there were no stacks before
		if currentStack == 0 then currentStack = currentStack + 1 end

		caster:SetModifierStackCount("modifier_fiery_soul_buff_stack_datadriven", ability, currentStack)

		-- Apply the new increased stack
		for i = 0, currentStack do
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_fiery_soul_buff_datadriven", {})
		end
	end
end