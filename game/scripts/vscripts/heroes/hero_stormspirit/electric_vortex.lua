--[[
	Author: kritth
	Date: 11.01.2015.
	Pull target toward caster's origin
]]
function electric_vortex_pull( keys )
	-- Variables
	local vortexOrigin = keys.caster:GetAbsOrigin()
	local target = keys.target
	local ability = keys.ability
	local distance_per_second = ability:GetLevelSpecialValueFor( "electric_vortex_pull_units_per_second", ability:GetLevel() - 1 )
	local vortex_duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local particle_name = "particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex.vpcf"
	local timer = 0.0
	local interval = 0.05
	
	-- Fire particle
	local fxIndex = ParticleManager:CreateParticle( particle_name, PATTACH_CUSTOMORIGIN, target )
	ParticleManager:SetParticleControl( fxIndex, 0, vortexOrigin )
	ParticleManager:SetParticleControlEnt( fxIndex, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
	
	-- Pulling
	Timers:CreateTimer( function()
			if timer >= vortex_duration then
				ParticleManager:DestroyParticle( fxIndex, false )
				ParticleManager:ReleaseParticleIndex( fxIndex )
				return nil
			else
				if not electric_vortex_stop( vortexOrigin, target:GetAbsOrigin() ) then
					-- Move
					local targetLoc = target:GetAbsOrigin()
					local forwardVec = vortexOrigin - targetLoc
					forwardVec = forwardVec:Normalized()
					target:SetAbsOrigin( targetLoc + forwardVec * ( interval * 100 ) )
				end
				timer = timer + interval
				return interval
			end
		end
	)
end

--[[
	Author: kritth
	Date: 11.01.2015.
	Helper: Check if distance is below 50
]]
function electric_vortex_stop( pointA, pointB )
	local dx = pointA.x - pointB.x
	local dy = pointA.y - pointB.y
	local distance = math.sqrt( dx * dx + dy * dy )
	if distance < 50 then
		return true
	else
		return false
	end
end