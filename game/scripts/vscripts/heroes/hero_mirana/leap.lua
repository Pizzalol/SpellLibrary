--[[Author: Pizzalol
	Date: 05.01.2015.
	Leaps the target forward]]
function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local leap_distance = ability:GetLevelSpecialValueFor("leap_distance", (ability:GetLevel() - 1))
	local leap_speed = ability:GetLevelSpecialValueFor("leap_speed", (ability:GetLevel() - 1))

	-- Clears any current command
	caster:Stop()

	-- Physics
	local direction = caster:GetForwardVector()
	local velocity = leap_speed * 1.4
	local end_time = leap_distance / leap_speed
	local time_elapsed = 0
	local time = end_time/2
	local jump = end_time/0.03

	Physics:Unit(caster)

	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)	
	caster:SetPhysicsVelocity(direction * velocity)


	-- Move the unit
	Timers:CreateTimer(0, function()
		local ground_position = GetGroundPosition(caster:GetAbsOrigin() , caster)
		time_elapsed = time_elapsed + 0.03
		if time_elapsed < time then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,jump)) -- Going up
		else
			caster:SetAbsOrigin(caster:GetAbsOrigin() - Vector(0,0,jump)) -- Going down
		end
		-- If the target reached the ground then remove physics
		if caster:GetAbsOrigin().z - ground_position.z <= 0 then
			caster:SetPhysicsAcceleration(Vector(0,0,0))
			caster:SetPhysicsVelocity(Vector(0,0,0))
			caster:OnPhysicsFrame(nil)
			caster:PreventDI(false)
			caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
			caster:SetAutoUnstuck(true)
			caster:FollowNavMesh(true)
			caster:SetPhysicsFriction(.05)
			return nil
		end

		return 0.03
	end)
end