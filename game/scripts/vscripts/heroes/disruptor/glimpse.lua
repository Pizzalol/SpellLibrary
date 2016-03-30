--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Stores the positions of the target over the course of the last backtrack time in an array]]
function MovementCheck(keys)
	local target = keys.unit
	local ability = keys.ability
	local backtrack_time = ability:GetLevelSpecialValueFor("backtrack_time", ability:GetLevel() -1)
	
	-- Temporary position array and index
	local temp = {}
	local temp_index = 0
	
	-- Global position array and index
	local target_index = 0
	if target.position == nil then
		target.position = {}
	end
	
	-- Sets the position and game time values in the tempororary array, if the target moved within 4 seconds of current time
	while target.position do
		if target.position[target_index] == nil then
		break
		elseif Time() - target.position[target_index+1] <= backtrack_time then
			temp[temp_index] = target.position[target_index]
			temp[temp_index+1] = target.position[target_index+1]
			temp_index = temp_index + 2
		end
		target_index = target_index + 2
	end
	
	-- Places most recent position and current time in the temporary array
	temp[temp_index] = target:GetAbsOrigin()
	temp[temp_index+1] = Time()
	
	-- Sets the global array as the temporary array
	target.position = temp
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Adds the projectile]]
function ProjectileControl(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability	
	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability:GetLevel() -1)/100
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability:GetLevel() -1)
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability:GetLevel() -1)
	--[[This checks if the target has been moved yet
		This is necessary because the MoveTarget function can be called 2 ways (whichever is faster):
		1. After the particle reaches the glimpse location
		2. After a 1.8 second delay]]
	ability.moved = false
	
	-- The glimpse location will be the oldest stored position in the array, providing it has been instantiated
	if target.position[0] == nil then
		ability.glimpse_location = target:GetAbsOrigin()
	else
		ability.glimpse_location = target.position[0]
	end
	
	-- Creates a dummy unit at the glimpse location to throw the projectile at
	local dummy = CreateUnitByName("npc_dummy_unit", ability.glimpse_location, false, caster, caster, caster:GetTeamNumber())
	-- Applies a modifier that removes it health bar
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_dummy", {})
	
	-- Renders the glimpse location particle
	ability.particle = ParticleManager:CreateParticle(keys.particle2, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.particle, 0, ability.glimpse_location)
	ParticleManager:SetParticleControl(ability.particle, 1, ability.glimpse_location)
	ParticleManager:SetParticleControl(ability.particle, 2, ability.glimpse_location)
	
	-- Throws the glimpse projectile at the dummy
	local info = {
	Target = dummy,
	Source = target,
	Ability = ability,
	EffectName = keys.particle,
	bDodgeable = false,
	--[[Provides the caster's team with permanent vision over the starting position
	bProvidesVision = true,
	iVisionRadius = vision_radius,
	iVisionTeamNumber = caster:GetTeam(),]]
	iMoveSpeed = projectile_speed,
	iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile( info )
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Moves the target to the glimpse location]]
function MoveTarget(keys)
	local target = keys.target
	local ability = keys.ability
	
	-- Checks if the target has been moved yet
	if ability.moved == false then
		-- Plays the move sound on the target
		EmitSoundOn(keys.sound, target)
		-- Destroys the glimpse location particle
		ParticleManager:DestroyParticle(ability.particle, true)
		
		-- Moves the target
		target:SetAbsOrigin(ability.glimpse_location)
		FindClearSpaceForUnit(target, ability.glimpse_location, true)
	end
	
	ability.moved = true
end
