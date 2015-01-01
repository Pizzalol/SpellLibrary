--[[Author: Pizzalol
	Date: 1.1.2015.
	Applies flesh heap modifiers according to the kills and assists before the ability was leveled up]]
function FleshHeap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local fleshHeapModifier = "modifier_flesh_heap_bonus_datadriven"
	local fleshHeapStackModifier = "modifier_flesh_heap_aura_datadriven"
	local assists = caster:GetAssists()
	local kills = caster:GetKills()

	for i = 1, (assists + kills) do
		ability:ApplyDataDrivenModifier(caster, caster, fleshHeapModifier, {})
		print("Current number: " .. i)
	end

	caster:SetModifierStackCount(fleshHeapStackModifier, ability, (assists + kills))
end

--[[Author: Pizzalol
	Date. 1.1.2015.
	Increases the stack count of Flesh Heap.]]
function StackCountIncrease( keys )
	local caster = keys.caster
	local ability = keys.ability
	local fleshHeapStackModifier = "modifier_flesh_heap_aura_datadriven"
	local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

	caster:SetModifierStackCount(fleshHeapStackModifier, ability, (currentStacks + 1))
end

--[[Author: Pizzalol
	Date: 1.1.2015.
	Adjusts the strength provided by the modifiers on ability upgrade]]
function FleshHeapAdjust( keys )
	local caster = keys.caster
	local ability = keys.ability
	local fleshHeapModifier = "modifier_flesh_heap_bonus_datadriven"
	local fleshHeapStackModifier = "modifier_flesh_heap_aura_datadriven"
	local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

	-- Remove the old modifiers
	for i = 1, currentStacks do
		caster:RemoveModifierByName(fleshHeapModifier)
	end

	-- Add the same amount of new ones
	for i = 1, currentStacks do
		ability:ApplyDataDrivenModifier(caster, caster, fleshHeapModifier, {}) 
	end
end