--[[
	Author: Ractidous
	Date: 12.02.2015.

	Store the target location.
	If the caster has tethered ally, refresh the tether duration.

	The hard-coded one won't take care of the tethered ally's tether duration.
	We refresh even the ally's duration.
]]
function CastRelocate( event )

	local caster	= event.caster
	local ability	= event.ability
	local point		= event.target_points[1]

	-- Store the target loc
	ability.relocate_targetPoint = point

	-- Reset states
	ability.relocate_isInterrupted = false

	-- Try to refresh the tether duration
	local tetherModifierName = event.tether_modifier

	if caster:HasModifier( tetherModifierName ) then
		local tetherAbility = caster:FindAbilityByName( event.tether_ability )
		local tetheredAlly = tetherAbility[event.tether_ally_property_name]

		if IsRelocatableUnit( tetheredAlly ) then
			tetherAbility:ApplyDataDrivenModifier( caster, caster, tetherModifierName, {} )
			tetherAbility:ApplyDataDrivenModifier( caster, tetheredAlly, event.tether_ally_modifier, {} )
		end
	end

end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	Create the endpoint particle at the target location.
	And create a vision to the target location.
]]
function CreateMarkerEndpoint( event )
	
	local caster	= event.caster
	local ability	= event.ability

	local pfx = ParticleManager:CreateParticle( event.endpoint_particle, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, ability.relocate_targetPoint )

	-- Store the particle ID
	ability.relocate_endpointPfx = pfx

	-- Create vision
	ability:CreateVisibilityNode( ability.relocate_targetPoint, event.vision_radius, event.vision_duration )

end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	Check to see if the relocate has been interrupted.
]]
function CheckToInterrupt( event )
	local caster	= event.caster
	local ability	= event.ability

	if caster:IsStunned() or caster:IsHexed() or caster:IsNightmared() or caster:IsOutOfGame() then
		-- Interrupt the ability
		ability.relocate_isInterrupted = true
		caster:RemoveModifierByName( event.channel_modifier )
	end
end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	Destroy the endpoint particle.
]]
function DestroyMarkerEndpoint( event )
	local ability	= event.ability

	local pfx = ability.relocate_endpointPfx
	ParticleManager:DestroyParticle( pfx, false )

	ability.relocate_endpointPfx = nil
end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	Check to see if the teleport is possible.
	If the caster is ensnared when the delay time is expired, the teleport won't happen.
]]
function TryToTeleport( event )
	local caster	= event.caster
	local ability	= event.ability

	-- Interrupted by any disable?
	if ability.relocate_isInterrupted then
		ability.relocate_isInterrupted = nil
		return
	end

	-- Ensnared?
	if caster:IsRooted() then
		return
	end

	-- Now we teleport!
	ability:ApplyDataDrivenModifier( caster, caster, event.timer_modifier, {} )
end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	If the caster has tethered ally, refresh the tether duration.

	Store the original location and teleport the caster.
	Fire the teleport particle on the old location before the teleportation.

	After this function is called, trees around the caster will be destroyed.
]]
function Teleportation_PreDestroyTree( event )
	
	local caster	= event.caster
	local ability	= event.ability

	-- Try to refresh the tether duration
	local tetherModifierName = event.tether_modifier
	local tetherAbility = caster:FindAbilityByName( event.tether_ability )
	local tetheredAlly = nil

	if caster:HasModifier( tetherModifierName ) then
		tetheredAlly = tetherAbility[event.tether_ally_property_name]
		if IsRelocatableUnit( tetheredAlly ) then
			local tetherDuration = event.tether_duration

			tetherAbility:ApplyDataDrivenModifier( caster, caster, tetherModifierName, { duration = tetherDuration } )
			tetherAbility:ApplyDataDrivenModifier( caster, tetheredAlly, event.tether_ally_modifier, { duration = tetherDuration } )
		else
			tetheredAlly = nil
		end
	end
	ability.relocate_tetheredAlly = tetheredAlly

	-- Store the original loc
	ability.relocate_originalPoint = caster:GetAbsOrigin()

	-- Fire the teleport particle
	local pfx = ParticleManager:CreateParticle( event.teleport_particle, PATTACH_POINT, caster )
	ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true )

	if tetheredAlly then
		pfx = ParticleManager:CreateParticle( event.teleport_particle, PATTACH_POINT, tetheredAlly )
		ParticleManager:SetParticleControlEnt( pfx, 0, tetheredAlly, PATTACH_POINT, "attach_hitloc", tetheredAlly:GetAbsOrigin(), true )
	end

	-- Move to the location
	caster:SetAbsOrigin( ability.relocate_targetPoint )

end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	Find clear space for the caster, then teleport the tethered ally to near the caster.
	Discard current orders of caster and the tethered ally.

	We need to create the timer particle from script in order to control the number showing.
	Even the original location marker is created in this function.
]]
function Teleportation_PostDestroyTree( event )
	
	local caster	= event.caster
	local ability	= event.ability

	-- Find clear space for the caster, and stop
	FindClearSpaceForUnit( caster, ability.relocate_targetPoint, false )
	caster:Stop()

	-- Find clear space for the tethered ally
	-- Ally's teleportation point is always NORTH EAST from the caster.
	local tetheredAlly = ability.relocate_tetheredAlly
	if tetheredAlly then
		FindClearSpaceForUnit( tetheredAlly, ability.relocate_targetPoint + Vector( 16, 16, 0 ), false )
		tetheredAlly:Stop()

		ability.relocate_tetheredAlly = nil
	end

	-- Initialize the timer
	ability.relocate_timer = event.return_time

	local pfx = ParticleManager:CreateParticle( event.timer_particle, PATTACH_OVERHEAD_FOLLOW, caster )

	local timerCP1_x = event.return_time >= 10 and 1 or 0
	local timerCP1_y = event.return_time % 10
	ParticleManager:SetParticleControl( pfx, 1, Vector( timerCP1_x, timerCP1_y, 0 ) )

	ability.relocate_timerPfx = pfx

	-- Create original location marker
	pfx = ParticleManager:CreateParticle( event.marker_particle, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, ability.relocate_originalPoint )

	ability.relocate_markerPfx = pfx

end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	Update the timer particle.
]]
function UpdateTimer( event )

	local ability = event.ability
	ability.relocate_timer = ability.relocate_timer - 1

	local pfx = ability.relocate_timerPfx

	local timerCP1_x = ability.relocate_timer >= 10 and 1 or 0
	local timerCP1_y = ability.relocate_timer % 10
	ParticleManager:SetParticleControl( pfx, 1, Vector( timerCP1_x, timerCP1_y, 0 ) )

end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	Destroy the particle effects.
	Check to see if the caster is alive.
]]
function TryReturningTeleportation( event )

	local caster	= event.caster
	local ability	= event.ability

	-- Destroy particle FXs
	ParticleManager:DestroyParticle( ability.relocate_timerPfx, false )
	ParticleManager:DestroyParticle( ability.relocate_markerPfx, false )

	-- If caster is dead, skip the teleportation back
	if not caster:IsAlive() then
		return
	end

	-- Now we teleport to the original location!
	ability:ApplyDataDrivenModifier( caster, caster, event.returning_modifier, {} )

end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	If the caster is still alive, teleport back to the original location.
	Fire the teleport particle on the old location before the teleportation.

	After this function is called, trees around the caster will be destroyed.
]]
function ReturningTeleportation_PreDestroyTree( event )
	
	local caster	= event.caster
	local ability	= event.ability

	-- Grab the tethered ally
	local tetherAbility = caster:FindAbilityByName( event.tether_ability )
	local tetheredAlly = nil

	if caster:HasModifier( event.tether_modifier ) then
		tetheredAlly = tetherAbility[event.tether_ally_property_name]
		if not IsRelocatableUnit( tetheredAlly ) then
			tetheredAlly = nil
		end
	end
	ability.relocate_tetheredAlly = tetheredAlly

	-- Fire the teleport particle
	local pfx = ParticleManager:CreateParticle( event.teleport_particle, PATTACH_POINT, caster )
	ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true )

	if tetheredAlly then
		pfx = ParticleManager:CreateParticle( event.teleport_particle, PATTACH_POINT, tetheredAlly )
		ParticleManager:SetParticleControlEnt( pfx, 0, tetheredAlly, PATTACH_POINT, "attach_hitloc", tetheredAlly:GetAbsOrigin(), true )
	end

	-- Move to the location
	caster:SetAbsOrigin( ability.relocate_originalPoint )

end

--[[
	Author: Ractidous
	Date: 12.02.2015.

	Find clear space for the caster, then teleport back even the tethered ally.
	Discard current orders of caster and the tethered ally.
]]
function ReturningTeleportation_PostDestroyTree( event )
	
	local caster	= event.caster
	local ability	= event.ability

	-- Find clear space for the caster, and stop
	FindClearSpaceForUnit( caster, ability.relocate_originalPoint, false )
	caster:Stop()

	-- Find clear space for the tethered ally
	-- Ally's teleportation point is always NORTH EAST from the caster.
	local tetheredAlly = ability.relocate_tetheredAlly
	if tetheredAlly then
		FindClearSpaceForUnit( tetheredAlly, ability.relocate_originalPoint + Vector( 16, 16, 0 ), false )
		tetheredAlly:Stop()

		ability.relocate_tetheredAlly = nil
	end

end



--[[
	Author: Ractidous
	Date: 13.02.2015.
	Heroes, Illusions, LD's spirit bear, Warlock's Golem, Storm and Fire spirits from Primal Split can be relocated.

	Spirit bear, Golem, Storm and Fire spirits all have this property:
		"ConsideredHero" "1"
	So we can use it in order to check to see if the unit is relocatable.
]]
function IsRelocatableUnit( unit )
	if unit:IsHero() then return true end
	return false
end

--[[
	Author: Ractidous
	Date: 13.02.2015.
	Stop a sound on the target unit.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.target )
end