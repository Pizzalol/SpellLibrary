--[[
	Author: kritth
	Date: 13.01.2015.
	Apply modifiers to 2 targets in radius at random
]]
function searing_chains_pin_point( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local maxTarget = ability:GetLevelSpecialValueFor( "unit_count", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local modifierName = "modifier_searing_chains_debuff_datadriven"
	local particleName = "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_start.vpcf"
	local soundEvent = "Hero_EmberSpirit.SearingChains.Burn"
	
	-- Target stats
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	local unitOrder = FIND_ANY_ORDER

	-- Find and apply debuff
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam,
		targetType, targetFlag, unitOrder, false
	)
	local count = 0
	for k, v in pairs( units ) do
		if count < maxTarget then
			-- Apply effect
			local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, v:GetAbsOrigin() )
			StartSoundEvent( soundEvent, v )
			
			-- Properly destroy effect
			Timers:CreateTimer( duration, function()
					ParticleManager:DestroyParticle( fxIndex, false )
					ParticleManager:ReleaseParticleIndex( fxIndex )
					StopSoundEvent( soundEvent, v )
				end
			)
			
			-- Function
			v:Stop()
			ability:ApplyDataDrivenModifier( caster, v, modifierName, {} )
			count = count + 1
		end
	end
end