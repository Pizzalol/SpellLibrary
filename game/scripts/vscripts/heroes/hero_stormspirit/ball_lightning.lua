--[[
	Author: kritth
	Date: 12.01.2015.
	Start traversing the caster, creating projectile, and check if caster should stop traversing based on destination or mana
	This ability cannot be casted multiple times while it is active
]]
function ball_lightning_traverse( keys )
	-- Check if spell has already casted
	if keys.caster.ball_lightning_is_running ~= nil and keys.caster.ball_lightning_is_running == true then
		keys.ability:RefundManaCost()
		return
	end

	-- Variables from keys
	local caster = keys.caster
	local casterLoc = caster:GetAbsOrigin()
	local target = keys.target_points[ 1 ] 
	local ability = keys.ability
	
	-- Variables inheritted from ability
	local speed = ability:GetLevelSpecialValueFor( "ball_lightning_move_speed", ability:GetLevel() - 1 )
	local destroy_radius = ability:GetLevelSpecialValueFor( "tree_destroy_radius", ability:GetLevel() - 1 )
	local vision_radius = ability:GetLevelSpecialValueFor( "ball_lightning_vision_radius", ability:GetLevel() - 1 )
	local mana_percent = ability:GetLevelSpecialValueFor( "ball_lightning_travel_cost_percent", ability:GetLevel() - 1 )
	local distance_per_mana = ability:GetLevelSpecialValueFor( "distance_per_mana", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor( "ball_lightning_aoe", ability:GetLevel() - 1 )
	local mana_cost_base = ability:GetLevelSpecialValueFor( "ball_lightning_travel_cost_base", ability:GetLevel() - 1 )
	
	-- Variables based on modifiers and precaches
	local particle_dummy = "particles/status_fx/status_effect_base.vpcf"
	local loop_sound_name = "Hero_StormSpirit.BallLightning.Loop"
	local modifierName = "modifier_ball_lightning_buff_datadriven"
	local modifierDestroyTreesName = "modifier_ball_lightning_destroy_trees_datadriven"
	
	-- Necessary pre-calculated variable
	local currentPos = casterLoc
	local intervals_per_second = speed / destroy_radius		-- This will calculate how many times in one second unit should move based on destroy tree radius
	local forwardVec = ( target - casterLoc ):Normalized()
	local mana_per_distance = ( mana_percent / 100 ) * caster:GetMaxMana()
	
	-- Set global value for damage mechanism
	caster.ball_lightning_start_pos = casterLoc
	caster.ball_lightning_is_running = true
	
	-- Adjust vision
	caster:SetDayTimeVisionRange( vision_radius )
	caster:SetNightTimeVisionRange( vision_radius )
	
	-- Start
	local distance = 0.0
	if caster:GetMana() > mana_per_distance then
		-- Spend initial mana 
		caster:SpendMana( mana_per_distance, ability )
		
		-- Create dummy projectile
		local projectileTable =
		{
			EffectName = particle_dummy,
			Ability = ability,
			vSpawnOrigin = caster:GetAbsOrigin(),
			vVelocity = speed * forwardVec,
			fDistance = 99999,
			fStartRadius = radius,
			fEndRadius = radius,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = true,
			bProvidesVision = true,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		local projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
		
		-- Traverse
		Timers:CreateTimer( function()
				-- Spending mana
				distance = distance + speed / intervals_per_second
				if distance >= distance_per_mana then
					-- Check if there is enough mana to cast
					local mana_to_spend = mana_cost_base + mana_per_distance
					if caster:GetMana() >= mana_to_spend then
						caster:SpendMana( mana_to_spend, ability )
					else
						-- Exit condition
						caster:RemoveModifierByName( modifierName )
						caster:RemoveModifierByName( modifierDestroyTreesName )
						StopSoundEvent( loop_sound_name, caster )
						caster.ball_lightning_is_running = false
						return nil
					end
					distance = distance - distance_per_mana
				end
				
				-- Update location
				currentPos = currentPos + forwardVec * ( speed / intervals_per_second )
				-- caster:SetAbsOrigin( currentPos ) -- This doesn't work because unit will not stick to the ground but rather travel in linear
				FindClearSpaceForUnit( caster, currentPos, false )
				
				-- Check if unit is close to the destination point
				if ( target - currentPos ):Length2D() <= speed / intervals_per_second then
					-- Exit condition
					caster:RemoveModifierByName( modifierName )
					caster:RemoveModifierByName( modifierDestroyTreesName )
					StopSoundEvent( loop_sound_name, caster )
					caster.ball_lightning_is_running = false
					return nil
				else
					return 1 / intervals_per_second
				end
			end
		)
	else
		ability:RefundManaCost()
	end
end

--[[
	Author: kritth
	Date: 12.01.2015.
	Damage the units that user runs into based on the distance
]]
function ball_lightning_damage( keys )
	-- Variables
	local targetLoc = keys.target:GetAbsOrigin()
	local casterLoc = keys.caster.ball_lightning_start_pos
	local ability = keys.ability
	local damage_per_distance = ability:GetAbilityDamage()
	local distance_per_damage = ability:GetLevelSpecialValueFor( "distance_per_damage", ability:GetLevel() - 1 )
	local damageType = ability:GetAbilityDamageType()
	
	-- Calculate and damage the unit
	local real_damage = ( targetLoc - casterLoc ):Length2D() * damage_per_distance / distance_per_damage
	local damageTable = {
		victim = keys.target,
		attacker = keys.caster,
		damage = real_damage,
		damage_type = damageType
	}
	ApplyDamage( damageTable )
end

--[[
	Author: kritth
	Date: 12.01.2015.
	Destroy trees
	NOTE:	This function is very important. When caster is set to invulnerable, KV will not be able to attach anything to the caster at all.
			Therefore, everything has to be done manually in lua.
]]
function ball_lightning_destroy_trees( keys )
	local modifierName = "modifier_ball_lightning_destroy_trees_datadriven"
	keys.caster:RemoveModifierByName( modifierName )
	keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, modifierName, {} )
end