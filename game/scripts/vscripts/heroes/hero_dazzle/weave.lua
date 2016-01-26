--[[Author: Pizzalol
	Date: 26.01.2016.
	Creates vision over the area]]
function WeaveVision( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local vision_radius = ability:GetLevelSpecialValueFor("vision", ability_level)
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level)

	AddFOWViewer(caster:GetTeamNumber(),target_point,vision_radius,vision_duration,true)
end

--[[Author: Pizzalol
	Date: 26.01.2016.
	Removes the targeted modifier]]
function WeaveRemoveModifier( keys )
	local target = keys.target
	local modifier = keys.modifier

	target:RemoveModifierByName(modifier)
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

--[[Author: Pizzalol
	Date: 26.01.2016.
	Destroys the particle when the modifier is destroyed, only when the target doesnt have the modifier]]
function EndWeaveParticle( event )
	local target = event.target
	local modifier = event.modifier
	local particle_type = event.particle_type -- 0 negative and 1 positive

	if not target:HasModifier(modifier) then
		if particle_type == 0 then
			ParticleManager:DestroyParticle(target.WeaveNegativeParticle,false)
		else
			ParticleManager:DestroyParticle(target.WeavePositiveParticle,false)
		end
	end
end

--[[Author: Pizzalol
	Date: 26.01.2016.
	Increment the stack count]]
function WeaveIncrement( keys )
	local caster = keys.caster
	local target = keys.target
	local modifier = keys.modifier

	local current_stack = target:GetModifierStackCount(modifier,caster)

	if current_stack < 1 then
		target:SetModifierStackCount(modifier,caster,1)
	else
		target:SetModifierStackCount(modifier,caster,current_stack + 1)
	end
end