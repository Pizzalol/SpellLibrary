--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Creates the trap]]
function CreateTrap(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local max_traps = ability:GetLevelSpecialValueFor("max_traps", ability:GetLevel() - 1)
	
	-- Creates the list of traps and total_traps global variables
	if ability.total_traps == nil then
		ability.total_traps = 0
		ability.traps = {}
	end
	
	-- Ensures there are fewer than the maximum traps
	if ability.total_traps < max_traps then
		-- Creates a new trap
		local trap = CreateUnitByName("npc_dota_templar_assassin_psionic_trap", point, true, caster, nil, caster:GetTeam())
		
		-- Places the trap in the list and increments the total
		ability.total_traps = ability.total_traps + 1
		ability.traps[ability.total_traps-1] = trap
		
		-- Applies the modifier to the trap
		ability:ApplyDataDrivenModifier(caster, trap, "modifier_psionic_trap_datadriven", {})
		
		trap:SetOwner(caster)
		trap:SetControllableByPlayer(caster:GetPlayerID(), true)
		
		-- Removes the default trap ability and adds both new abilities
		trap:RemoveAbility("templar_assassin_self_trap")
		
		caster:AddAbility("trap_datadriven")
		caster:FindAbilityByName("trap_datadriven"):UpgradeAbility(true)
		
		trap:AddAbility("self_trap_datadriven")
		trap:FindAbilityByName("self_trap_datadriven"):UpgradeAbility(true)
	
		-- Plays the sounds
		EmitSoundOn(keys.sound, caster)
		EmitSoundOn(keys.sound2, trap)
		
		-- Renders the trap particle on the target position (it is not a model particle, so cannot be attached to the unit)
		trap.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(trap.particle, 0, point)
		ParticleManager:SetParticleControl(trap.particle, 1, point)
		ParticleManager:SetParticleControl(trap.particle, 2, point)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Increases the slow over time]]
function IncrementSlow(keys)
	local target = keys.target
	local ability = keys.ability
	local movement_speed_min = ability:GetLevelSpecialValueFor("movement_speed_min_tooltip", ability:GetLevel() - 1)
	local slow_per_tick = ability:GetLevelSpecialValueFor("slow_per_tick", ability:GetLevel() - 1)
	
	-- Initially sets the trap at minimum move speed
	if target.stacks == nil then
		target.stacks = movement_speed_min
	else
		-- Adds slow every tick
		target.stacks = target.stacks + slow_per_tick
	end
end

--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Checks the current slow of the trap and slows the targets]]
function CheckSlow(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local trap_radius = ability:GetLevelSpecialValueFor("trap_radius", ability:GetLevel() - 1)
	
	-- Units in the slow radius
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, trap_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_MECHANICAL, 0, 0, false)

	-- Applies the debuff to the targets
	for i,unit in ipairs(units) do
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_trap_debuff", {})
		unit:SetModifierStackCount("modifier_trap_debuff", ability, target.stacks)
	end
	
	-- Creates the destroy particle on the trap
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())
	
	-- Plays the sounds
	EmitSoundOn(keys.sound, caster)
	EmitSoundOn(keys.sound2, target)
	
	-- Kills the trap (triggers TrapDestroy)
	target:ForceKill(true)
end

--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Destroys all memory of the trap]]
function TrapDestroy(keys)
	local target = keys.unit
	local ability = keys.ability
	
	-- Creates a temporary list and index
	local temp = {}
	local temp_index = 0
	
	-- Places every trap in the trap list into the temporary list, except the dead one
	for i=0,ability.total_traps-1 do
		if ability.traps[i] ~= target then
			temp[temp_index] = ability.traps[i]
			temp_index = temp_index + 1
		end
	end
	ability.total_traps = ability.total_traps - 1
	
	-- Sets the trap list equal to the temporary list
	ability.traps = temp
	
	-- Destroys the trap particle
	ParticleManager:DestroyParticle(target.particle, true)
end

--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Finds the closest trap to the caster]]
function FindClosest(keys)
	local caster = keys.caster
	local ability = keys.ability
	-- The psionic trap ability
	local psionic_trap_ability = caster:FindAbilityByName("psionic_trap_datadriven")
	
	local closest = 100000
	local trap
	
	-- Ensures there are existing traps
	if psionic_trap_ability.total_traps > 0 then
		-- Loops through all existing traps
		for i=0,psionic_trap_ability.total_traps-1 do
			-- The trap's distance from the caster
			local distance = (caster:GetAbsOrigin() - psionic_trap_ability.traps[i]:GetAbsOrigin()):Length2D()
			
			-- Notes the closest distance and closest trap
			if distance < closest then
				closest = distance
				trap = psionic_trap_ability.traps[i]
			end
		end
				
	end
	
	-- Applies the destroy modifier to the trap (triggers CheckSlow)
	ability:ApplyDataDrivenModifier(caster, trap, "modifier_destroy", {})
end
