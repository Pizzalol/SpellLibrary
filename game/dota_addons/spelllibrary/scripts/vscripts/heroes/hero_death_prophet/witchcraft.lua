--[[
	Author: Noya
	Date: 02.02.2015.
	Each time the ability is upgraded, replace Ability1 and Ability2 by a new copy of the same abilities with reduced manacost and cooldown
]]
function WitchCraft( event )
	local caster = event.caster
	local ability = event.ability
	local witchcraft_level = ability:GetLevel()
	
	-- Abilities to update
	local ability1_name = event.Ability1Name
	local ability2_name = event.Ability2Name

	-- Current ability handles, always on the first 2 slots
	local ability1 = caster:GetAbilityByIndex(0)
	local ability2 = caster:GetAbilityByIndex(1)

	-- Levels
	local ability1_level = ability1:GetLevel()
	local ability2_level = ability2:GetLevel()

	-- Names
	local ability1_old_name = ability1:GetAbilityName()
	local ability2_old_name = ability2:GetAbilityName()
	--print("Ability1: "..ability1_old_name,"Ability1: "..ability2_old_name)

	-- This is the extension added to the copies of ability1/ability2, one for each level.
	local witchcraft_string_level = "_witchcraft"..witchcraft_level

	-- Set new names
	local ability1_new_name = ability1_name..witchcraft_string_level
	local ability2_new_name = ability2_name..witchcraft_string_level

	-- Add, Swap, Find Handle, Set Level and Remove the old ability
	caster:AddAbility(ability1_new_name)
	caster:SwapAbilities(ability1_old_name, ability1_new_name, false, true)
	local new_ability_handle = caster:FindAbilityByName(ability1_new_name)
	new_ability_handle:SetLevel(ability1_level)
	print("Swapped "..ability1_old_name.." to "..ability1_new_name)
	caster:RemoveAbility(ability1_old_name)

	-- Same for ability 2
	caster:AddAbility(ability2_new_name)
	caster:SwapAbilities(ability2_old_name, ability2_new_name, false, true)
	local new_ability_handle = caster:FindAbilityByName(ability2_new_name)
	new_ability_handle:SetLevel(ability2_level)
	print("Swapped "..ability2_old_name.." to "..ability2_new_name)
	caster:RemoveAbility(ability2_old_name)


end