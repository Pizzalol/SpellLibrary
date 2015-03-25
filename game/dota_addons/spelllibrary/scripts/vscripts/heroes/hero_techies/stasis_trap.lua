
function StasisTrapPlant( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	print("Hello")

	-- Modifiers

	-- Ability variables
	local activation_time = ability:GetLevelSpecialValueFor("activation_time", ability_level) 
	local fade_time = ability:GetLevelSpecialValueFor("fade_time", ability_level) 
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level) 

	-- Create the land mine and apply the land mine modifier
	local stasis_trap = CreateUnitByName("npc_dota_techies_stasis_trap", target_point, false, nil, nil, caster:GetTeamNumber())
	stasis_trap:AddNewModifier(caster, ability, "modifier_kill", {Duration = duration}) 
end