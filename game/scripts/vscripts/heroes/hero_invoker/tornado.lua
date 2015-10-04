--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called when Tornado is cast.
	Additional parameters: keys.TravelSpeed, keys.AreaOfEffect, keys.VisionDistance, and keys.EndVisionDuration
	Known bugs:
	    When a tornado connects with an enemy unit, the Quas and Exort levels from the most recently cast Tornado
		    are used.  This should only cause a bug when Invoker casts Tornado, levels up Quas or Exort, uses a
			Refresher Orb, and then casts Tornado again before the previously cast Tornado connects with an enemy
			unit.  When projectile IDs are passed into OnProjectileHitUnit RunScript blocks, some included code
			can be uncommented to fix this bug.
================================================================================================================= ]]
function invoker_tornado_datadriven_on_spell_start(keys)
	local caster_origin = keys.caster:GetAbsOrigin()

	--Tornado's travel distance and lift duration are dependent on the level of Quas.
	local quas_ability = keys.caster:FindAbilityByName("invoker_quas_datadriven")
	local quas_level = 1
	local tornado_travel_distance = 0
	local tornado_lift_duration = 0
	if quas_ability ~= nil then
		quas_level = quas_ability:GetLevel()
		tornado_travel_distance = keys.ability:GetLevelSpecialValueFor("travel_distance", quas_level - 1)
		tornado_lift_duration = keys.ability:GetLevelSpecialValueFor("lift_duration", quas_level - 1)
	end
	
	--Tornado's landing damage bonus is dependent on the level of Wex.
	local wex_ability = keys.caster:FindAbilityByName("invoker_wex_datadriven")
	local wex_level = 1
	local tornado_landing_damage_bonus = 0
	if wex_ability ~= nil then
		wex_level = wex_ability:GetLevel()
		tornado_landing_damage_bonus = keys.ability:GetLevelSpecialValueFor("wex_damage", wex_level - 1)
	end

	--Create a dummy unit that will follow the path of the tornado, providing flying vision and sound.
	--Its invoker_tornado_datadriven ability also applies the cyclone modifier to hit enemy units, since if Invoker uninvokes Tornado,
	--existing modifiers linked to that ability can cause errors.
	local tornado_dummy_unit = CreateUnitByName("npc_dummy_unit", caster_origin, false, nil, nil, keys.caster:GetTeam())
	tornado_dummy_unit:AddAbility("invoker_tornado_datadriven")
	local emp_unit_ability = tornado_dummy_unit:FindAbilityByName("invoker_tornado_datadriven")
	if emp_unit_ability ~= nil then
		emp_unit_ability:SetLevel(1)
		emp_unit_ability:ApplyDataDrivenModifier(tornado_dummy_unit, tornado_dummy_unit, "modifier_invoker_tornado_datadriven_unit_ability", {duration = -1})
	end
	
	tornado_dummy_unit:EmitSound("Hero_Invoker.Tornado")  --Emit a sound that will follow the tornado.
	tornado_dummy_unit:SetDayTimeVisionRange(keys.VisionDistance)
	tornado_dummy_unit:SetNightTimeVisionRange(keys.VisionDistance)
	
	local projectile_information =  
	{
		EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
		Ability = emp_unit_ability,
		vSpawnOrigin = caster_origin,
		fDistance = tornado_travel_distance,
		fStartRadius = keys.AreaOfEffect,
		fEndRadius = keys.AreaOfEffect,
		Source = tornado_dummy_unit,
		bHasFrontalCone = false,
		iMoveSpeed = keys.TravelSpeed,
		bReplaceExisting = false,
		bProvidesVision = true,
		iVisionTeamNumber = keys.caster:GetTeam(),
		iVisionRadius = keys.VisionDistance,
		bDrawsOnMinimap = false,
		bVisibleToEnemies = true, 
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		fExpireTime = GameRules:GetGameTime() + 20.0,
	}

	local target_point = keys.target_points[1]
	target_point.z = 0
	local caster_point = keys.caster:GetAbsOrigin()
	caster_point.z = 0
	local point_difference_normalized = (target_point - caster_point):Normalized()
	projectile_information.vVelocity = point_difference_normalized * keys.TravelSpeed
	
	local tornado_projectile = ProjectileManager:CreateLinearProjectile(projectile_information)
	
	--When the projectile ID can be passed into a OnProjectileHitUnit block, an array like this can be used to store the stats associated with the projectile.
	--[[
	--Store the lift duration and bonus landing damage associated with the projectile, using the Quas/Exort levels from when Tornado was cast.
	if keys.caster.tornado_projectile_information == nil then
		keys.caster.tornado_projectile_information = {}
	end
	local tornado_projectile_information = {}
	tornado_projectile_information["tornado_lift_duration"] = tornado_lift_duration
	tornado_projectile_information[tornado_projectile])["tornado_landing_damage_bonus"] = tornado_landing_damage_bonus
	keys.caster.tornado_projectile_information[tornado_projectile] = tornado_projectile_information
	]]
	
	tornado_dummy_unit.invoker_tornado_lift_duration = tornado_lift_duration
	tornado_dummy_unit.invoker_tornado_landing_damage_bonus = tornado_landing_damage_bonus
	
	--Calculate where and when the Tornado projectile will end up.
	local tornado_duration = tornado_travel_distance / keys.TravelSpeed
	local tornado_final_position = caster_origin + (projectile_information.vVelocity * tornado_duration)
	local tornado_velocity_per_frame = projectile_information.vVelocity * .03
	
	--Adjust the dummy unit's position every frame to match that of the tornado particle effect.
	local endTime = GameRules:GetGameTime() + tornado_duration
	Timers:CreateTimer({
		endTime = .03,
		callback = function()
			tornado_dummy_unit:SetAbsOrigin(tornado_dummy_unit:GetAbsOrigin() + tornado_velocity_per_frame)
			if GameRules:GetGameTime() > endTime then
				tornado_dummy_unit:StopSound("Hero_Invoker.Tornado")
				
				--Have the dummy unit linger in the position the tornado ended up in, in order to provide vision.
				Timers:CreateTimer({
					endTime = keys.EndVisionDuration,
					callback = function()
						tornado_dummy_unit:RemoveSelf()
					end
				})
				
				return 
			else 
				return .03
			end
		end
	})
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called when Tornado hits an enemy unit.  Lifts them into the air, cycloning them.
================================================================================================================= ]]
function invoker_tornado_datadriven_on_projectile_hit_unit(keys)
	if keys.caster.invoker_tornado_lift_duration ~= nil then
		--Store the target's forward vector so they can be left facing in the same direction when they land.
		keys.target.invoker_tornado_forward_vector = keys.target:GetForwardVector()
		
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_tornado_datadriven_cyclone", {duration = keys.caster.invoker_tornado_lift_duration})
		
		keys.target:EmitSound("Hero_Invoker.Tornado.Target")
		
		--Stop the sound when the cycloning ends.
		Timers:CreateTimer({
			endTime = keys.caster.invoker_tornado_lift_duration,
			callback = function()
				keys.target:StopSound("Hero_Invoker.Tornado.Target")
			end
		})
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called when a unit lands after being lifted into the air from Tornado.  Damages them.
	Additional parameters: keys.BaseDamage
================================================================================================================= ]]
function modifier_invoker_tornado_datadriven_cyclone_on_destroy(keys)
	keys.target:EmitSound("Hero_Invoker.Tornado.LandDamage")
	
	--Set it so the target is facing the same direction as they were when they were hit by the tornado.
	if keys.target.invoker_tornado_forward_vector ~= nil then
		keys.target:SetForwardVector(keys.target.invoker_tornado_forward_vector)
	end
	
	if keys.caster.invoker_tornado_landing_damage_bonus ~= nil then
		ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.BaseDamage + keys.caster.invoker_tornado_landing_damage_bonus, damage_type = DAMAGE_TYPE_MAGICAL,})
	else  --Failsafe.
		ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.BaseDamage, damage_type = DAMAGE_TYPE_MAGICAL,})
	end
	
	keys.target.invoker_tornado_degrees_to_spin = nil
end


--[[ ============================================================================================================
	Author: Noya and Rook
	Date: April 06, 2015
	Rotates the cycloned unit, causing them to spin.
================================================================================================================= ]]
function modifier_invoker_tornado_datadriven_cyclone_on_interval_think(keys)
    local target = keys.target
	local total_degrees = 20
	
	--Rotate as close to 20 degrees per .03 seconds (666.666 degrees per second) as possible, but such that the target lands facing their initial direction.
	if keys.target.invoker_tornado_degrees_to_spin == nil and keys.caster.invoker_tornado_lift_duration ~= nil then
		local ideal_degrees_per_second = 666.666
		local ideal_full_spins = (ideal_degrees_per_second / 360) * keys.caster.invoker_tornado_lift_duration
		ideal_full_spins = math.floor(ideal_full_spins + .5)  --Round the number of spins to aim for to the closest integer.
		local degrees_per_second_ending_in_same_forward_vector = (360 * ideal_full_spins) / keys.caster.invoker_tornado_lift_duration
		
		keys.target.invoker_tornado_degrees_to_spin = degrees_per_second_ending_in_same_forward_vector * .03
	end
	
	target:SetForwardVector(RotatePosition(Vector(0,0,0), QAngle(0, keys.target.invoker_tornado_degrees_to_spin, 0), target:GetForwardVector()))
end


--[[ ============================================================================================================
	Author: Noya, edited by Rook
	Date: April 06, 2015
	Progressively sends the cycloned unit to a max height, then up and down between an interval, and finally back 
	to the original ground position.
	Additional parameters: keys.CycloneInitialHeight, keys.CycloneMinHeight, and keys.CycloneMaxHeight
================================================================================================================= ]]
function modifier_invoker_tornado_datadriven_cyclone_on_created(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- Position variables
	local target_origin = target:GetAbsOrigin()
	local target_initial_x = target_origin.x
	local target_initial_y = target_origin.y
	local target_initial_z = target_origin.z
	local position = Vector(target_initial_x, target_initial_y, target_initial_z)  --This is updated whenever the target has their position changed.
	
	local duration = 0
	if keys.caster.invoker_tornado_lift_duration ~= nil then
		duration = keys.caster.invoker_tornado_lift_duration
	else
		local quas_ability = keys.caster:FindAbilityByName("invoker_quas_datadriven")
		if quas_ability ~= nil then
			duration = keys.ability:GetLevelSpecialValueFor("duration", quas_ability:GetLevel() - 1)
		end
	end
	
	local ground_position = GetGroundPosition(position, target)
	local cyclone_initial_height = keys.CycloneInitialHeight + ground_position.z
	local cyclone_min_height = keys.CycloneMinHeight + ground_position.z
	local cyclone_max_height = keys.CycloneMaxHeight + ground_position.z
	local tornado_start = GameRules:GetGameTime()

	-- Height per time calculation
	local time_to_reach_initial_height = duration / 10  --1/10th of the total cyclone duration will be spent ascending and descending to and from the initial height.
	local initial_ascent_height_per_frame = ((cyclone_initial_height - position.z) / time_to_reach_initial_height) * .03  --This is the height to add every frame when the unit is first cycloned, and applies until the caster reaches their max height.
	
	local up_down_cycle_height_per_frame = initial_ascent_height_per_frame / 3  --This is the height to add or remove every frame while the caster is in up/down cycle mode.
	if up_down_cycle_height_per_frame > 7.5 then  --Cap this value so the unit doesn't jerk up and down for short-duration cyclones.
		up_down_cycle_height_per_frame = 7.5
	end
	
	local final_descent_height_per_frame = nil  --This is calculated when the unit begins descending.

	-- Time to go down
	local time_to_stop_fly = duration - time_to_reach_initial_height

	-- Loop up and down
	local going_up = true

	-- Loop every frame for the duration
	Timers:CreateTimer(function()
		local time_in_air = GameRules:GetGameTime() - tornado_start
		
		-- First send the target to the cyclone's initial height.
		if position.z < cyclone_initial_height and time_in_air <= time_to_reach_initial_height then
			--print("+",initial_ascent_height_per_frame,position.z)
			position.z = position.z + initial_ascent_height_per_frame
			target:SetAbsOrigin(position)
			return 0.03

		-- Go down until the target reaches the ground.
		elseif time_in_air > time_to_stop_fly and time_in_air <= duration then
			--Since the unit may be anywhere between the cyclone's min and max height values when they start descending to the ground,
			--the descending height per frame must be calculated when that begins, so the unit will end up right on the ground when the duration is supposed to end.
			if final_descent_height_per_frame == nil then
				local descent_initial_height_above_ground = position.z - ground_position.z
				--print("ground position: " .. GetGroundPosition(position, target).z)
				--print("position.z : " .. position.z)
				final_descent_height_per_frame = (descent_initial_height_above_ground / time_to_reach_initial_height) * .03
			end
			
			--print("-",final_descent_height_per_frame,position.z)
			position.z = position.z - final_descent_height_per_frame
			target:SetAbsOrigin(position)
			return 0.03

		-- Do Up and down cycles
		elseif time_in_air <= duration then
			-- Up
			if position.z < cyclone_max_height and going_up then 
				--print("going up")
				position.z = position.z + up_down_cycle_height_per_frame
				target:SetAbsOrigin(position)
				return 0.03

			-- Down
			elseif position.z >= cyclone_min_height then
				going_up = false
				--print("going down")
				position.z = position.z - up_down_cycle_height_per_frame
				target:SetAbsOrigin(position)
				return 0.03

			-- Go up again
			else
				--print("going up again")
				going_up = true
				return 0.03
			end

		-- End
		else
			--print(GetGroundPosition(target:GetAbsOrigin(), target))
			--print("End TornadoHeight")
		end
	end)
end