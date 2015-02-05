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
	Date: 05.02.2015.
	Shows the dazzle friendly armor particle
]]
function WeavePositiveParticle( event )
	local target = event.target
	local location = target:GetAbsOrigin()
	local particleName = event.particle_name
	local modifier = event.modifier

	-- Count the number of weave modifiers
	local count = 0

	for i = 0, target:GetModifierCount() do
		if target:GetModifierNameByIndex(i) == modifier then
			count = count + 1
		end
	end

	-- If its the first one then apply the particle
	if count == 1 then 
		target.WeavePositiveParticle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)
		ParticleManager:SetParticleControl(target.WeavePositiveParticle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(target.WeavePositiveParticle, 1, target:GetAbsOrigin())

		ParticleManager:SetParticleControlEnt(target.WeavePositiveParticle, 1, target, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", target:GetAbsOrigin(), true)
	end
end

-- Destroys the particle when the modifier is destroyed, only when the target doesnt have the modifier
function EndWeavePositiveParticle( event )
	local target = event.target
	local particleName = event.particle_name
	local modifier = event.modifier

	if not target:HasModifier(modifier) then
		ParticleManager:DestroyParticle(target.WeavePositiveParticle,false)
	end
end

--[[
	Author: Noya, Pizzalol
	Date: 05.02.2015.
	Shows the dazzle enemy armor particle
]]
function WeaveNegativeParticle( event )
	local target = event.target
	local location = target:GetAbsOrigin()
	local particleName = event.particle_name
	local modifier = event.modifier

	-- Count the number of weave modifiers
	local count = 0

	for i = 0, target:GetModifierCount() do
		if target:GetModifierNameByIndex(i) == modifier then
			count = count + 1
		end
	end

	-- If its the first one then apply the particle
	if count == 1 then 
		target.WeaveNegativeParticle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)
		ParticleManager:SetParticleControl(target.WeaveNegativeParticle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(target.WeaveNegativeParticle, 1, target:GetAbsOrigin())

		ParticleManager:SetParticleControlEnt(target.WeaveNegativeParticle, 1, target, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", target:GetAbsOrigin(), true)
	end
end

-- Destroys the particle when the modifier is destroyed, only when the target doesnt have the modifier
function EndWeaveNegativeParticle( event )
	local target = event.target
	local particleName = event.particle_name
	local modifier = event.modifier

	if not target:HasModifier(modifier) then
		ParticleManager:DestroyParticle(target.WeaveNegativeParticle,false)
	end
end