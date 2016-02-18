--[[Author: YOLOSPAGHETTI
	Date: February 17, 2016
	Creates the eidelons]]
function CreateEidelons(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local target_origin = target:GetAbsOrigin()
	local direction = target:GetForwardVector()
	local duration = ability:GetLevelSpecialValueFor("duration_tooltip", ability:GetLevel())
	local count = ability:GetLevelSpecialValueFor("spawn_count", ability:GetLevel())
	local xp_radius = ability:GetLevelSpecialValueFor("xp_radius", ability:GetLevel())
	local bounty = target:GetGoldBounty()
	local xp = target:GetDeathXP()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_origin, nil, xp_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
	local shared_xp = xp/table.getn(units)
	local eidelon_level = keys.ability:GetLevel()
	
	if eidelon_level >= 1 and eidelon_level <= 4 then
		-- Takes note of the caster for when the eidelons split
		ability.caster = caster
		-- Kills the target unit
		target:ForceKill(true)
		-- Gives the caster the gold bounty
		caster:SetGold(caster:GetGold() + bounty, false)
		-- Splits the experience among heroes in range
		for i,unit in ipairs(units) do
			unit:AddExperience(shared_xp, 0, false, false)
		end
		-- Creates the eidelons on the target and facing the same direction
		for i=0,count-1 do
			local eidelon = CreateUnitByName("eidelon_" .. eidelon_level .. "_datadriven", target_origin, true, caster, nil, caster:GetTeam())
			eidelon:SetForwardVector(direction)
			eidelon:SetControllableByPlayer(caster:GetPlayerID(), true)
			eidelon:SetOwner(caster)
		
			-- Adds the green duration circle, and kills the eidelon after the duration ends
			eidelon:AddNewModifier(eidelon, nil, "modifier_kill", {duration = duration})
			-- Phases the eidelon for a short period so there is no unit collision
			eidelon:AddNewModifier(eidelon, nil, "modifier_phased", {duration = 0.03})
			-- Applies the modifier to count each eidelon's attacks
			ability:ApplyDataDrivenModifier( eidelon, eidelon, "modifier_check_attacks", {} )
			-- Takes note of the game time, so we know the duration for the split eidelons
			eidelon.time = GameRules:GetGameTime()
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 17, 2016
	Splits the eidelons if they hit the attack count]]
function CheckAttacks(keys)
	local caster = keys.caster -- The eidelon
	local target = keys.target -- The target it is attacking
	local ability = keys.ability
	local attack_count = ability:GetLevelSpecialValueFor("split_attack_count", ability:GetLevel())
	local duration = ability:GetLevelSpecialValueFor("duration_tooltip", ability:GetLevel())
	local time_left = duration - (GameRules:GetGameTime() - caster.time)
	
	-- Counts the number of attacks for each eidelon
	if target:GetTeam() ~= caster:GetTeam() and target:IsBuilding() == false then
		if caster.attacks == nil then
			caster.attacks = 1
		else
			caster.attacks = caster.attacks + 1
		end
	end
	
	-- If the number of attacks is greater than the necessary count, we split the eidelon (create a new one)
	if caster.attacks >= attack_count then
		local eidelon = CreateUnitByName(caster:GetUnitName(), caster:GetAbsOrigin(), true, ability.caster, ability.caster, ability.caster:GetTeam())
		eidelon:SetForwardVector(caster:GetForwardVector())
		eidelon:SetControllableByPlayer(ability.caster:GetPlayerID(), true)
		eidelon:SetOwner(ability.caster)
		
		--Adds the green duration circle, and kill the eidelon after the duration ends
		eidelon:AddNewModifier(eidelon, nil, "modifier_kill", {duration = time_left})
		-- Phases the eidelon for a short period so there is no unit collision
		eidelon:AddNewModifier(eidelon, nil, "modifier_phased", {duration = 0.03})
		-- Remove the modifier to check attacks
		caster:RemoveModifierByName("modifier_check_attacks")
		-- Heal the original eidelon to full
		caster:Heal(caster:GetMaxHealth(), caster)
	end
end
