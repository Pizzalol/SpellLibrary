--[[Author: Pizzalol
	Date: 07.03.2015.
	Initializes all the needed starting values for the Mystic Snake]]
function MysticSnakeInitialize( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local base_damage = ability:GetLevelSpecialValueFor("snake_damage", ability_level) 
	local base_mana = ability:GetLevelSpecialValueFor("snake_mana_steal", ability_level)

	caster.mystic_snake_jumps = 1
	caster.mystic_snake_damage = base_damage
	caster.mystic_snake_mana = base_mana
	caster.mystic_snake_stolen_mana = 0
	caster.mystic_snake_table = {}
end

--[[Author: Pizzalol
	Date: 07.03.2015.
	Handles all the targeting and other actions logic]]
function MysticSnake( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local jump_radius = ability:GetLevelSpecialValueFor("radius", ability_level) 
	local max_jumps = ability:GetLevelSpecialValueFor("snake_jumps", ability_level) 
	local snake_scale = 1 + (ability:GetLevelSpecialValueFor("snake_scale", ability_level) / 100)
	local initial_speed = ability:GetLevelSpecialValueFor("initial_speed", ability_level) 
	local return_speed = ability:GetLevelSpecialValueFor("return_speed", ability_level) 
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level)

	-- Sounds
	local sound_friendly = keys.sound_friendly
	local sound_enemy = keys.sound_enemy

	-- Particles
	local mystic_snake_projectile = keys.mystic_snake_projectile
	local particle_impact_enemy = keys.particle_impact_enemy
	local particle_impact_friendly = keys.particle_impact_friendly

	-- Check if the hit target is the caster or an enemy unit
	if target ~= caster then
		-- If its an enemy unit then insert it into the snake table
		-- so that we can keep track that we hit it
		table.insert(caster.mystic_snake_table, target)

		-- Initialize the damage table
		local damage_table = {}

		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage = caster.mystic_snake_damage

		-- Check if it has the Dota or Datadriven Stone Gaze modifiers
		if target:HasModifier("modifier_medusa_stone_gaze_stone") or target:HasModifier("modifier_stone_gaze_stone_datadriven") then
			damage_table.damage_type = DAMAGE_TYPE_PURE
		else
			damage_table.damage_type = ability:GetAbilityDamageType()
		end

		-- Check if the target has mana
		-- Remove the mana if it does, update the stolen mana and increase the mana steal for the next jump
		if target:GetMaxMana() >= 1 then
			target:ReduceMana(caster.mystic_snake_mana)
			caster.mystic_snake_stolen_mana = caster.mystic_snake_stolen_mana + caster.mystic_snake_mana
			caster.mystic_snake_mana = caster.mystic_snake_mana * snake_scale
		end

		-- Play the sound and particle of the spell
		EmitSoundOn(sound_enemy, target)

		local particle_enemy = ParticleManager:CreateParticle(particle_impact_enemy, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(particle_enemy, 0, target_location) 
		ParticleManager:SetParticleControl(particle_enemy, 1, target_location)

		-- Deal the damage
		ApplyDamage(damage_table)

		-- Check if we can do more jumps
		if caster.mystic_snake_jumps < max_jumps then
			-- If we can then increase the snake damage for the next jump
			caster.mystic_snake_damage = caster.mystic_snake_damage * snake_scale

			-- Set up the targeting variables
			local target_team = ability:GetAbilityTargetTeam()
			local target_type = ability:GetAbilityTargetType() 
			local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

			-- Find all the valid units to jump to
			local jump_targets = FindUnitsInRadius(caster:GetTeam(), target_location, nil, jump_radius, target_team, target_type, target_flags, FIND_CLOSEST, false) 
			local hit_helper -- This variable helps in the case we find only target units that we have already hit before

			-- Check if we found more than 1 target because the original target is included in the search
			if #jump_targets > 1 then
				
				-- Loop through the targets to see if we have a valid one
				for _,v in ipairs(jump_targets) do
					hit_helper = true
					local hit_check = false -- Determines if the target has been hit before or not

					-- Check if the current target has been hit
					for _,k in ipairs(caster.mystic_snake_table) do
						if v == k then
							hit_check = true
							break
						end
					end

					-- If it wasnt then launch a new snake at it
					if not hit_check then
						local projectile_info = 
						{
							EffectName = mystic_snake_projectile,
							Ability = ability,
							vSpawnOrigin = target_location,
							Target = v,
							Source = target,
							bHasFrontalCone = false,
							iMoveSpeed = initial_speed,
							bReplaceExisting = false,
							bProvidesVision = true,
							iVisionRadius = vision_radius,
							iVisionTeamNumber = caster:GetTeamNumber()
						}
						ProjectileManager:CreateTrackingProjectile(projectile_info)

						-- Increase the jump count and update the helper variable
						caster.mystic_snake_jumps = caster.mystic_snake_jumps + 1
						hit_helper = false
						break
					end
				end
			else
				-- Send the snake back to the caster if we havent found more targets
				local projectile_info = 
				{
					EffectName = mystic_snake_projectile,
					Ability = ability,
					vSpawnOrigin = target_location,
					Target = caster,
					Source = target,
					bHasFrontalCone = false,
					iMoveSpeed = return_speed,
					bReplaceExisting = false,
					bProvidesVision = true,
					iVisionRadius = vision_radius,
					iVisionTeamNumber = caster:GetTeamNumber()
				}
				ProjectileManager:CreateTrackingProjectile(projectile_info)
			end
			-- Check the helper variable to determine if we have to send the snake back to the caster
			-- Happens only in the case where we find only targets that we hit before but havent reached
			-- the jump limit
			if hit_helper then
				local projectile_info = 
				{
					EffectName = mystic_snake_projectile,
					Ability = ability,
					vSpawnOrigin = target_location,
					Target = caster,
					Source = target,
					bHasFrontalCone = false,
					iMoveSpeed = return_speed,
					bReplaceExisting = false,
					bProvidesVision = true,
					iVisionRadius = vision_radius,
					iVisionTeamNumber = caster:GetTeamNumber()
				}
				ProjectileManager:CreateTrackingProjectile(projectile_info)
			end
		else
			-- Send the snake back to the caster because we hit the jump limit
			local projectile_info = 
			{
				EffectName = mystic_snake_projectile,
				Ability = ability,
				vSpawnOrigin = target_location,
				Target = caster,
				Source = target,
				bHasFrontalCone = false,
				iMoveSpeed = return_speed,
				bReplaceExisting = false,
				bProvidesVision = true,
				iVisionRadius = vision_radius,
				iVisionTeamNumber = caster:GetTeamNumber()
			}
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	else
		-- If its the caster then give the stolen mana to the caster
		caster:GiveMana(caster.mystic_snake_stolen_mana)

		-- and play the sound and particles for the spell
		EmitSoundOn(sound_friendly, caster) 
		local particle_friendly = ParticleManager:CreateParticle(particle_impact_friendly, PATTACH_ABSORIGIN_FOLLOW, caster) 
		ParticleManager:SetParticleControlEnt(particle_friendly, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_location, true)
	end
end