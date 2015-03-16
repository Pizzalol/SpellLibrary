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

function WhirlingAxesMelee( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local forward_vector = caster:GetForwardVector()
	local front_position = caster_location + forward_vector * 1
	local axe_projectile = keys.axe_projectile
	local axe_modifier = keys.axe_modifier

	local angle_east = QAngle(0,-90,0)
	local angle_west = QAngle(0,90,0)

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

	caster.whirling_axes_east.particle = particle_east
	caster.whirling_axes_east.axe_radius = 1
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

	caster.whirling_axes_west.particle = particle_west
	caster.whirling_axes_west.axe_radius = 1
	caster.whirling_axes_west.start_time = GameRules:GetGameTime()
	caster.whirling_axes_west.side = 1
end

function WhirlingAxesMeleeThink( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local elapsed_time = GameRules:GetGameTime() - target.start_time


	


	--------------------------------------------------------------------------------
	-- Update the radius
	--
	local currentRadius	= target.axe_radius
	local deltaRadius = 7
	currentRadius = currentRadius + deltaRadius
	currentRadius = math.min( math.max( currentRadius, 1 ), 350 )

	print(currentRadius)

	target.axe_radius = currentRadius

	local rotation_angle = elapsed_time * 360 -- need to use time for this
	local relPos = Vector( 0, currentRadius, 0 )
	relPos = RotatePosition( Vector(0,0,0), QAngle( 0, -rotation_angle, 0 ), relPos )

	local absPos = GetGroundPosition( relPos + caster_location, target )
	target:SetAbsOrigin( absPos )

	if elapsed_time >= 3 then
		target:RemoveSelf()
	end
end