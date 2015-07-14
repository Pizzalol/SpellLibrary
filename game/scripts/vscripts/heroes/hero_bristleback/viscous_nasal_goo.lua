--[[
Author: Ragnar Homsar
Date: July 13, 2015

determine_debuff: Called by the invisible determiner debuff that's applied by the Viscous Nasal Goo projectile. Determines what debuff to inflict on the target, and whether or not to increment the stack count. Also controls setting the stack count indicator above the debuffed target.

destroy_particles: Clears out the indicator particle associated with the target. The actual debuff particle is cleared through the keyvalue system.
]]

function determine_debuff(params)
	-- There's a very good chance that at least half of these will be nil. This doesn't matter; we use nil to determine what debuffs to inflict.
	-- If one of these is nil, that means the target doesn't have the debuff, allowing us to easily determine what to do.
	local hero_base = params.target:FindModifierByName("modifier_viscous_nasal_goo_datadriven_base_hero")
	local creep_base = params.target:FindModifierByName("modifier_viscous_nasal_goo_datadriven_base_creep")
	local hero_stack = params.target:FindModifierByName("modifier_viscous_nasal_goo_datadriven_stack_hero")
	local creep_stack = params.target:FindModifierByName("modifier_viscous_nasal_goo_datadriven_stack_creep")

	-- Case 1: Target is a hero. Target does not have the base debuff.
	-- In this case, apply the base debuff and a stack debuff, as well as create the stack indicator particle.
	if params.target:IsHero() and hero_base == nil then
		-- Take note of the fact that we store the particle index in the target's handle! We use this to clear out the particle once the duration's run out, all the way down in destroy_particles.
		params.target.goo_particle_index = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, params.target)
		-- The Viscous Nasal Goo stack indicator particle uses the Y coordinate of Control Point 1 to determine what to show. Therefore, it should be fed a Vector that only has a Y coordinate of whatever you want to set it to.
		ParticleManager:SetParticleControl(params.target.goo_particle_index, 1, Vector(0, 1, 0))
		-- As the keyvalue entry suggests, the base debuff does nothing but apply the 20% base slow. The stack debuffs are what apply the stack-based slow and the armor reduction.
		params.ability:ApplyDataDrivenModifier(params.caster, params.target, "modifier_viscous_nasal_goo_datadriven_base_hero", nil)
		params.ability:ApplyDataDrivenModifier(params.caster, params.target, "modifier_viscous_nasal_goo_datadriven_stack_hero", nil)
		params.target:FindModifierByName("modifier_viscous_nasal_goo_datadriven_stack_hero"):IncrementStackCount()

	-- Case 2: Target is a hero. Target has the base debuff.
	-- In this case, increment the stack count if needed, reset the durations on both the base and stack debuffs, and update the counter particle.
	elseif params.target:IsHero() and hero_base ~= nil then
		-- Only update the stack count if we are below what's defined as the maximum number.
		if hero_stack:GetStackCount() < params.max_stacks then hero_stack:IncrementStackCount() end
		hero_base:SetDuration(params.debuff_duration, true)
		hero_stack:SetDuration(params.debuff_duration, true)
		ParticleManager:SetParticleControl(params.target.goo_particle_index, 1, Vector(0, hero_stack:GetStackCount(), 0))

	-- Case 3: Target is a creep. Target does not have the base debuff.
	elseif params.target:IsCreep() and creep_base == nil then
		params.target.goo_particle_index = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, params.target)
		ParticleManager:SetParticleControl(params.target.goo_particle_index, 1, Vector(0, 1, 0))
		params.ability:ApplyDataDrivenModifier(params.caster, params.target, "modifier_viscous_nasal_goo_datadriven_base_creep", nil)
		params.ability:ApplyDataDrivenModifier(params.caster, params.target, "modifier_viscous_nasal_goo_datadriven_stack_creep", nil)
		params.target:FindModifierByName("modifier_viscous_nasal_goo_datadriven_stack_creep"):IncrementStackCount()

	-- Case 4: Target is a creep. Target has the base debuff.
	elseif params.target:IsCreep() and creep_base ~= nil then
		if creep_stack:GetStackCount() < params.max_stacks then creep_stack:IncrementStackCount() end
		creep_base:SetDuration(params.debuff_duration_creep, true)
		creep_stack:SetDuration(params.debuff_duration_creep, true)
		ParticleManager:SetParticleControl(params.target.goo_particle_index, 1, Vector(0, creep_stack:GetStackCount(), 0))
	end
end

function destroy_particles(params)
	ParticleManager:DestroyParticle(params.target.goo_particle_index, true)
end