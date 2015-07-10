--[[Author: Pizzalol
	Date: 25.03.2015.
	Upgrades the focused detonate ability]]
function RemoteMinesUpgrade( keys )
	local caster = keys.caster
	local ability_name = keys.ability_name

	caster:FindAbilityByName(ability_name):SetLevel(1)
end

--[[Author: Pizzalol
	Date: 25.03.2015.
	Creates the remote mine and initializes its functions]]
function RemoteMinesPlant( keys )
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Modifiers
	local modifier_remote_mine = keys.modifier_remote_mine
	local modifier_remote_mine_invisibility = keys.modifier_remote_mine_invisibility

	-- Ability variables
	local activation_time = ability:GetLevelSpecialValueFor("activation_time", ability_level)
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local model_scale = ability:GetLevelSpecialValueFor("model_scale", ability_level) / 100

	-- Create the land mine and initialize it
	local remote_mine = CreateUnitByName("npc_dota_techies_remote_mine", target_point, false, nil, nil, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, remote_mine, modifier_remote_mine, {})
	remote_mine:AddNewModifier(caster, ability, "modifier_kill", {Duration = duration})
	remote_mine:SetModelScale(1 + model_scale)
	remote_mine:SetControllableByPlayer(player, true)

	-- Remove the base ability and add the datadriven one
	remote_mine:RemoveAbility("techies_remote_mines_self_detonate") 
	remote_mine:AddAbility("techies_remote_mines_self_detonate_datadriven")

	-- Level it up
	remote_mine:FindAbilityByName("techies_remote_mines_self_detonate_datadriven"):SetLevel(1)

	-- Apply the invisibility after the activation time
	Timers:CreateTimer(activation_time, function()
		ability:ApplyDataDrivenModifier(caster, remote_mine, modifier_remote_mine_invisibility, {})
	end)
end

--[[Author: Pizzalol
	Date: 25.03.2015.
	Detonates the selected mine]]
function RemoteMinesSelfDetonate( keys )
	local caster = keys.caster

	caster:ForceKill(true)
end

--[[Author: Pizzalol
	Date: 25.03.2015.
	Detonates all the mines in the radius]]
function RemoteMinesFocusedDetonate( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)

	local target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local target_types = DOTA_UNIT_TARGET_ALL
	local target_flags = DOTA_UNIT_TARGET_FLAG_NONE

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, radius, target_team, target_types, target_flags, FIND_CLOSEST, false)

	for _,unit in ipairs(units) do
		if unit:GetUnitName() == "npc_dota_techies_remote_mine" then
			unit:ForceKill(true) 
		end
	end
end