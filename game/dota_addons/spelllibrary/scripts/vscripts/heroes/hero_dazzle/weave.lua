--[[Author: Pizzalol
	Date: 02.02.2015.
	Creates vision over the area]]
function WeaveVision( keys )
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local vision_radius = ability:GetLevelSpecialValueFor("vision", ability_level)
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level)

	ability:CreateVisibilityNode(target_point, vision_radius, vision_duration)
end

--[[Author: Pizzalol
	Date: 02.02.2015.
	Removes the applied positive armor buffs from the target]]
function WeaveRemovePositive( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier

	-- Modifier variables
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local tick_interval = ability:GetLevelSpecialValueFor("tick_interval", ability_level)

	-- Calculating how many modifiers we have to remove
	local modifiers_to_remove = duration / tick_interval

	-- Removing them
	for i = 1, modifiers_to_remove do
		target:RemoveModifierByNameAndCaster(modifier, caster)
	end
end

--[[Author: Pizzalol
	Date: 02.02.2015.
	Removes the applied negative armor buffs from the target]]
function WeaveRemoveNegative( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier

	-- Modifier variables
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local tick_interval = ability:GetLevelSpecialValueFor("tick_interval", ability_level)

	-- Calculating how many modifiers we have to remove
	local modifiers_to_remove = duration / tick_interval

	-- Removing them
	for i = 1, modifiers_to_remove do
		target:RemoveModifierByNameAndCaster(modifier, caster)
	end
end

--[[
	Author: Noya, Pizzalol
	Date: 02.02.2015.
	Shows the dazzle friendly armor particle
]]
function WeavePositiveParticle( event )
	local target = event.target
	local location = target:GetAbsOrigin()
	local particleName = event.particle_name

	local particle_table = {}
	particle_table.target = target

	if target.WeavePositiveParticle ~= nil then
		EndWeavePositiveParticle(particle_table)
	end
	-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		target.WeavePositiveParticle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)
		ParticleManager:SetParticleControl(target.WeavePositiveParticle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(target.WeavePositiveParticle, 1, target:GetAbsOrigin())

		ParticleManager:SetParticleControlEnt(target.WeavePositiveParticle, 1, target, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", target:GetAbsOrigin(), true)
	end)
end

-- Destroys the particle when the modifier is destroyed
function EndWeavePositiveParticle( event )
	local target = event.target
	ParticleManager:DestroyParticle(target.WeavePositiveParticle,false)
	target.WeavePositiveParticle = nil
end