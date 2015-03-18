--[[
	Author: Noya
	Used by: Pizzalol
	Date: 14.03.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

--[[Author: Pizzalol
	Date: 18.03.2015.
	Initialize the axes]]
function WhirlingAxesMelee( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local start_radius = ability:GetLevelSpecialValueFor("start_radius", ability_level)
	caster.whirling_axes_melee_hit_table = {} 
	
	-- Visuals
	local axe_projectile = keys.axe_projectile
	local axe_modifier = keys.axe_modifier

	-- Starting position calculation
	local angle_east = QAngle(0,-90,0)
	local angle_west = QAngle(0,90,0)

	local forward_vector = caster:GetForwardVector()
	local front_position = caster_location + forward_vector * start_radius

	local position_east = RotatePosition(caster_location, angle_east, front_position) 
	local position_west = RotatePosition(caster_location, angle_west, front_position)

	-- East axe
	if caster.whirling_axes_east and IsValidEntity(caster.whirling_axes_east) then
		caster.whirling_axes_east:RemoveSelf()
	end

	-- Create the axe
	caster.whirling_axes_east = CreateUnitByName("npc_dota_troll_warlord_axe", position_east, false, caster, caster, caster:GetTeam() )
	ability:ApplyDataDrivenModifier(caster, caster.whirling_axes_east, axe_modifier, {})

	-- Set the particle
	local particle_east = ParticleManager:CreateParticle(axe_projectile, PATTACH_ABSORIGIN_FOLLOW, caster.whirling_axes_east)
	ParticleManager:SetParticleControlEnt(particle_east, 1, caster.whirling_axes_east, PATTACH_POINT_FOLLOW, "attach_hitloc", caster.whirling_axes_east:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle_east, 4, Vector(5,0,0))

	-- Save the relevant data for movement calculation
	caster.whirling_axes_east.axe_radius = start_radius
	caster.whirling_axes_east.start_time = GameRules:GetGameTime()
	caster.whirling_axes_east.side = 0

	-- West axe
	if caster.whirling_axes_west and IsValidEntity(caster.whirling_axes_west) then
		caster.whirling_axes_west:RemoveSelf()
	end

	-- Create the axe
	caster.whirling_axes_west = CreateUnitByName("npc_dota_troll_warlord_axe", position_west, false, caster, caster, caster:GetTeam() )
	ability:ApplyDataDrivenModifier(caster, caster.whirling_axes_west, axe_modifier, {})
	
	-- Set the particle
	local particle_west = ParticleManager:CreateParticle(axe_projectile, PATTACH_ABSORIGIN_FOLLOW, caster.whirling_axes_west)
	ParticleManager:SetParticleControlEnt(particle_west, 1, caster.whirling_axes_west, PATTACH_POINT_FOLLOW, "attach_hitloc", caster.whirling_axes_west:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle_west, 4, Vector(5,0,0))

	-- Save the relevant data for movement calculation
	caster.whirling_axes_west.axe_radius = start_radius
	caster.whirling_axes_west.start_time = GameRules:GetGameTime()
	caster.whirling_axes_west.side = 1
end

--[[Author: Pizzalol, Ractidous
	Date: 18.03.2015.
	Moves the axes around the caster]]
function WhirlingAxesMeleeThink( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local elapsed_time = GameRules:GetGameTime() - target.start_time

	-- If the caster is not alive then remove the axes
	if not caster:IsAlive() then
		target:RemoveSelf()
		return
	end

	-- Ability variables
	local axe_movement_speed = ability:GetLevelSpecialValueFor("axe_movement_speed", ability_level) 
	local max_range = ability:GetLevelSpecialValueFor("max_range", ability_level) 
	local whirl_duration = ability:GetLevelSpecialValueFor("whirl_duration", ability_level) 
	local axe_turn_rate = ability:GetLevelSpecialValueFor("axe_turn_rate", ability_level)
	local hit_radius = ability:GetLevelSpecialValueFor("hit_radius", ability_level)
	local think_interval = ability:GetLevelSpecialValueFor("think_interval", ability_level)

	-- Calculate the radius and limit it to the max range
	local currentRadius	= target.axe_radius 
	local deltaRadius = axe_movement_speed / whirl_duration/2 * think_interval -- This is how fast the axe grows outwards
	currentRadius = currentRadius + deltaRadius
	currentRadius = math.min( currentRadius, (max_range - hit_radius)) -- Limit it to the max range

	-- Save the radius for the next think interval
	target.axe_radius = currentRadius

	-- Check which axe is it and then rotate it accordingly
	local rotation_angle
	if target.side == 1 then
		rotation_angle = elapsed_time * axe_turn_rate -- 360 is the turnrate
	else
		rotation_angle = elapsed_time * axe_turn_rate + 180 -- Add 180 to rotate it 180 degrees so both axes dont appear at 1 point
	end

	-- Rotate the current position
	local relPos = Vector( 0, currentRadius, 0 )
	relPos = RotatePosition( Vector(0,0,0), QAngle( 0, -rotation_angle, 0 ), relPos )

	-- Set the position around the target it is supposed to spin around
	local absPos = GetGroundPosition( relPos + caster_location, target )
	target:SetAbsOrigin( absPos )

	-- Check if its time to kill the axes
	if elapsed_time >= whirl_duration then
		target:RemoveSelf()
	end
end

--[[Author: Pizzalol
	Date: 18.03.2015.
	Checks if the target has been hit before and then does logic according to that]]
function WhirlingAxesMeleeHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier
	local sound = keys.sound

	-- Ability variables
	local blind_duration = ability:GetLevelSpecialValueFor("blind_duration", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)

	-- Check if the target has been hit before
	local hit_check = false

	for _,unit in ipairs(caster.whirling_axes_melee_hit_table) do
		if unit == target then
			hit_check = true
			break
		end
	end

	-- If the target hasnt been hit before then insert it into the hit table to keep track of it
	if not hit_check then
		table.insert(caster.whirling_axes_melee_hit_table, target)

		-- Apply the blind modifier and play the sound
		ability:ApplyDataDrivenModifier(caster, target, modifier, {Duration = blind_duration})
		EmitSoundOn(sound, target)

		-- Initialize the damage table and deal damage to the target
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = damage

		ApplyDamage(damage_table)
	end
end