--[[Author: Pizzalol
	Date: 10.02.2015.
	Checks if the target hp is below the threshold and depending on that it kills the target
	or deals magic damage]]
function CullingBlade( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin() 
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Sound variables
	local sound_fail = keys.sound_fail
	local sound_success = keys.sound_success

	-- Particle
	local particle_kill = keys.particle_kill

	-- Speed modifier
	local modifier_sprint = keys.modifier_sprint

	-- Ability variables
	local kill_threshold = ability:GetLevelSpecialValueFor("kill_threshold", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local speed_duration = ability:GetLevelSpecialValueFor("speed_duration", ability_level)
	local speed_aoe = ability:GetLevelSpecialValueFor("speed_aoe", ability_level)

	-- Exception table
	-- this is where you insert the modifiers that cant be purged but would
	-- prevent a units death
	local exception_table = {}
	table.insert(exception_table, "modifier_dazzle_shallow_grave")
	table.insert(exception_table, "modifier_shallow_grave_datadriven")

	-- Initializing the damage table
	local damage_table = {}
 	damage_table.victim = target
 	damage_table.attacker = caster
 	damage_table.ability = ability
 	damage_table.damage_type = ability:GetAbilityDamageType()
 	damage_table.damage = damage

 	-- Check if the target HP is equal or below the threshold
	if target:GetHealth() <= kill_threshold then
		-- If it is then purge it and manually remove unpurgable modifiers
		target:Purge(true, true, false, false, true)

		local modifier_count = target:GetModifierCount()
		for i = 0, modifier_count do
			local modifier_name = target:GetModifierNameByIndex(i)
			local modifier_check = false

			-- Compare if the modifier is in the exception table
			-- If it is then set the helper variable to true and remove it
			for j = 0, #exception_table do
				if exception_table[j] == modifier_name then
					modifier_check = true
					break
				end
			end

			-- Remove the modifier depending on the helper variable
			if modifier_check then
				target:RemoveModifierByName(modifier_name)
			end
		end

		-- Play the kill particle
		local culling_kill_particle = ParticleManager:CreateParticle(particle_kill, PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:ReleaseParticleIndex(culling_kill_particle)

		-- Play the sound
		caster:EmitSound(sound_success)
		-- Update the table info and apply the damage
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.damage = kill_threshold
		ApplyDamage(damage_table)

		-- Find the valid units in the area that should recieve the speed buff and then apply it to them
		local units_to_buff = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, speed_aoe, DOTA_UNIT_TARGET_TEAM_FRIENDLY, ability:GetAbilityTargetType() , 0, FIND_CLOSEST, false)
		for _,v in pairs(units_to_buff) do
			ability:ApplyDataDrivenModifier(caster, v, modifier_sprint, {duration = speed_duration})
		end

		-- Reset the ability cooldown if its a hero
		if target:IsRealHero() then
			ability:EndCooldown()
		end				
	else
		-- If its not equal or below the threshold then play the failure sound and deal normal damage
		caster:EmitSound(sound_fail)
		ApplyDamage(damage_table)
	end
end