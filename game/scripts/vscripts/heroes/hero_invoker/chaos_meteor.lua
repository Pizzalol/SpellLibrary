--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called when Chaos Meteor is cast.
	Additional parameters: keys.LandTime, keys.TravelSpeed, keys.VisionDistance, keys.EndVisionDuration, and
	    keys.BurnDuration
================================================================================================================= ]]
function invoker_chaos_meteor_datadriven_on_spell_start(keys)
	local caster_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	
	local caster_point_temp = Vector(caster_point.x, caster_point.y, 0)
	local target_point_temp = Vector(target_point.x, target_point.y, 0)
	
	local point_difference_normalized = (target_point_temp - caster_point_temp):Normalized()
	local velocity_per_second = point_difference_normalized * keys.TravelSpeed
	
	keys.caster:EmitSound("Hero_Invoker.ChaosMeteor.Cast")
	keys.caster:EmitSound("Hero_Invoker.ChaosMeteor.Loop")

	--Create a particle effect consisting of the meteor falling from the sky and landing at the target point.
	local meteor_fly_original_point = (target_point - (velocity_per_second * keys.LandTime)) + Vector (0, 0, 1000)  --Start the meteor in the air in a place where it'll be moving the same speed when flying and when rolling.
	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, target_point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(1.3, 0, 0))
	
	--Chaos Meteor's main and burn damage is dependent on the level of Exort.  This values are stored now since leveling up Exort while the meteor is in midair should have no effect.
	local exort_ability = keys.caster:FindAbilityByName("invoker_exort_datadriven")
	local main_damage = 0
	local burn_dps = 0
	if exort_ability ~= nil then
		local exort_level = exort_ability:GetLevel()
		main_damage = keys.ability:GetLevelSpecialValueFor("main_damage", exort_level - 1)
		burn_dps = keys.ability:GetLevelSpecialValueFor("burn_dps", exort_level - 1)
	end
	
	--Chaos Meteor's travel distance is dependent on the level of Wex.  This value is stored now since leveling up Wex while the meteor is in midair should have no effect.
	local wex_ability = keys.caster:FindAbilityByName("invoker_wex_datadriven")
	local travel_distance = 0
	if wex_ability ~= nil then
		travel_distance = keys.ability:GetLevelSpecialValueFor("travel_distance", wex_ability:GetLevel() - 1)
	end
	
	--Spawn the rolling meteor after the delay.
	Timers:CreateTimer({
		endTime = keys.LandTime,
		callback = function()
			--Create a dummy unit will follow the path of the meteor, providing flying vision, sound, damage, etc.			
			local chaos_meteor_dummy_unit = CreateUnitByName("npc_dummy_unit", target_point, false, nil, nil, keys.caster:GetTeam())
			chaos_meteor_dummy_unit:AddAbility("invoker_chaos_meteor_datadriven")
			local chaos_meteor_unit_ability = chaos_meteor_dummy_unit:FindAbilityByName("invoker_chaos_meteor_datadriven")
			if chaos_meteor_unit_ability ~= nil then
				chaos_meteor_unit_ability:SetLevel(1)
				chaos_meteor_unit_ability:ApplyDataDrivenModifier(chaos_meteor_dummy_unit, chaos_meteor_dummy_unit, "modifier_invoker_chaos_meteor_datadriven_unit_ability", {duration = -1})
			end
			
			keys.caster:StopSound("Hero_Invoker.ChaosMeteor.Loop")
			chaos_meteor_dummy_unit:EmitSound("Hero_Invoker.ChaosMeteor.Impact")
			chaos_meteor_dummy_unit:EmitSound("Hero_Invoker.ChaosMeteor.Loop")  --Emit a sound that will follow the meteor.
			
			chaos_meteor_dummy_unit:SetDayTimeVisionRange(keys.VisionDistance)
			chaos_meteor_dummy_unit:SetNightTimeVisionRange(keys.VisionDistance)
			
			--Store the damage to deal in a variable attached to the dummy unit, so leveling Exort after Meteor is cast will have no effect.
			chaos_meteor_dummy_unit.invoker_chaos_meteor_main_damage = main_damage
			chaos_meteor_dummy_unit.invoker_chaos_meteor_burn_dps = burn_dps
			chaos_meteor_dummy_unit.invoker_chaos_meteor_parent_caster = keys.caster
		
			local chaos_meteor_duration = travel_distance / keys.TravelSpeed
			local chaos_meteor_velocity_per_frame = velocity_per_second * .03
			
			--It would seem that the Chaos Meteor projectile needs to be attached to a particle in order to move and roll and such.
			local projectile_information =  
			{
				EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
				Ability = chaos_meteor_unit_ability,
				vSpawnOrigin = target_point,
				fDistance = travel_distance,
				fStartRadius = 0,
				fEndRadius = 0,
				Source = chaos_meteor_dummy_unit,
				bHasFrontalCone = false,
				iMoveSpeed = keys.TravelSpeed,
				bReplaceExisting = false,
				bProvidesVision = true,
				iVisionTeamNumber = keys.caster:GetTeam(),
				iVisionRadius = keys.VisionDistance,
				bDrawsOnMinimap = false,
				bVisibleToEnemies = true, 
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_NONE ,
				fExpireTime = GameRules:GetGameTime() + chaos_meteor_duration + keys.EndVisionDuration,
			}
			
			projectile_information.vVelocity = velocity_per_second
			local chaos_meteor_projectile = ProjectileManager:CreateLinearProjectile(projectile_information)

			chaos_meteor_unit_ability:ApplyDataDrivenModifier(chaos_meteor_dummy_unit, chaos_meteor_dummy_unit, "modifier_invoker_chaos_meteor_datadriven_main_damage", nil)
			
			--Adjust the dummy unit's position every frame.
			local endTime = GameRules:GetGameTime() + chaos_meteor_duration
			Timers:CreateTimer({
				callback = function()
					chaos_meteor_dummy_unit:SetAbsOrigin(chaos_meteor_dummy_unit:GetAbsOrigin() + chaos_meteor_velocity_per_frame)
					if GameRules:GetGameTime() > endTime then
						--Stop the sound, particle, and damage when the meteor disappears.
						chaos_meteor_dummy_unit:StopSound("Hero_Invoker.ChaosMeteor.Loop")
						chaos_meteor_dummy_unit:StopSound("Hero_Invoker.ChaosMeteor.Destroy")
						chaos_meteor_dummy_unit:RemoveModifierByName("modifier_invoker_chaos_meteor_datadriven_main_damage")
					
						--Have the dummy unit linger in the position the meteor ended up in, in order to provide vision.
						Timers:CreateTimer({
							endTime = keys.EndVisionDuration,
							callback = function()
								chaos_meteor_dummy_unit:SetDayTimeVisionRange(0)
								chaos_meteor_dummy_unit:SetNightTimeVisionRange(0)
								
								--Remove the dummy unit after the burn damage modifiers are guaranteed to have all expired.
								Timers:CreateTimer({
									endTime = keys.BurnDuration,
									callback = function()
										chaos_meteor_dummy_unit:RemoveSelf()
									end
								})
							end
						})
						return 
					else 
						return .03
					end
				end
			})
		end
	})
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called regularly while the Chaos Meteor is rolling.
	Additional parameters: keys.AreaOfEffect
================================================================================================================= ]]
function modifier_invoker_chaos_meteor_datadriven_main_damage_on_interval_think(keys)
	local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.AreaOfEffect, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	if keys.caster.invoker_chaos_meteor_parent_caster ~= nil then
		for i, individual_unit in ipairs(nearby_enemy_units) do
			individual_unit:EmitSound("Hero_Invoker.ChaosMeteor.Damage")
			
			if keys.caster.invoker_chaos_meteor_main_damage == nil then
				keys.caster.invoker_chaos_meteor_main_damage = 0
			end
			
			ApplyDamage({victim = individual_unit, attacker = keys.caster.invoker_chaos_meteor_parent_caster, damage = keys.caster.invoker_chaos_meteor_main_damage, damage_type = DAMAGE_TYPE_MAGICAL,})
			
			keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_invoker_chaos_meteor_datadriven_burn_damage", nil)
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called regularly a unit is still burned from a Chaos Meteor.
	Additional parameters: keys.BurnDamagePerInterval
================================================================================================================= ]]
function modifier_invoker_chaos_meteor_datadriven_burn_damage_on_interval_think(keys)
	if keys.caster.invoker_chaos_meteor_parent_caster ~= nil and keys.caster.invoker_chaos_meteor_burn_dps ~= nil then
		ApplyDamage({victim = keys.target, attacker = keys.caster.invoker_chaos_meteor_parent_caster, damage = keys.caster.invoker_chaos_meteor_burn_dps * keys.BurnDPSInterval, damage_type = DAMAGE_TYPE_MAGICAL,})
	end
end