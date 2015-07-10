--[[Author: Pizzalol
	Date: 06.04.2015.
	Takes ownership of the target unit]]
function HolyPersuasion( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Initialize the tracking data
	ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count or 0
	ability.holy_persuasion_table = ability.holy_persuasion_table or {}

	-- Ability variables
	local max_units = ability:GetLevelSpecialValueFor("max_units", ability_level)
	local health_bonus = ability:GetLevelSpecialValueFor("health_bonus", ability_level)

	-- Change the ownership of the unit and restore its mana to full
	target:SetTeam(caster_team)
	target:SetOwner(caster)
	target:SetControllableByPlayer(player, true)
	target:SetMaxHealth(target:GetMaxHealth() + health_bonus)
	target:Heal(health_bonus, ability)
	target:GiveMana(target:GetMaxMana())

	-- Track the unit
	ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
	table.insert(ability.holy_persuasion_table, target)

	-- If the maximum amount of units is reached then kill the oldest unit
	if ability.holy_persuasion_unit_count > max_units then
		ability.holy_persuasion_table[1]:ForceKill(true) 
	end
end

--[[Author: Pizzalol
	Date: 06.04.2015.
	Removes the target from the table]]
function HolyPersuasionRemove( keys )
	local target = keys.target
	local ability = keys.ability

	-- Find the unit and remove it from the table
	for i = 1, #ability.holy_persuasion_table do
		if ability.holy_persuasion_table[i] == target then
			table.remove(ability.holy_persuasion_table, i)
			ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count - 1
			break
		end
	end
end