--[[
	Author: kritth
	Date: 13.01.2015.
	Mark targets, jump to attack, ignore if invisible
]]
function sleight_of_fist_init( keys )
	-- Cannot cast multiple stacks
	if keys.caster.sleight_of_fist_active ~= nil and keys.caster.sleight_of_fist_action == true then
		keys.ability:RefundManaCost()
		return nil
	end

	-- Inheritted variables
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local attack_interval = ability:GetLevelSpecialValueFor( "attack_interval", ability:GetLevel() - 1 )
	local modifierTargetName = "modifier_sleight_of_fist_target_datadriven"
	local modifierHeroName = "modifier_sleight_of_fist_target_hero_datadriven"
	local modifierCreepName = "modifier_sleight_if_fist_target_creep_datadriven"
	local casterModifierName = "modifier_sleight_of_fist_caster_datadriven"
	local dummyModifierName = "modifier_sleight_of_fist_dummy_datadriven"
	local particleSlashName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf"
	local particleTrailName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf"
	local particleCastName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf"
	local slashSound = "Hero_EmberSpirit.SleightOfFist.Damage"
	
	-- Targeting variables
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local unitOrder = FIND_ANY_ORDER
	
	-- Necessary varaibles
	local counter = 0
	caster.sleight_of_fist_active = true
	local dummy = CreateUnitByName( caster:GetName(), caster:GetAbsOrigin(), false, caster, nil, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
	
	-- Casting particles
	local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( castFxIndex, 0, targetPoint )
	ParticleManager:SetParticleControl( castFxIndex, 1, Vector( radius, 0, 0 ) )
	
	Timers:CreateTimer( 0.1, function()
			ParticleManager:DestroyParticle( castFxIndex, false )
			ParticleManager:ReleaseParticleIndex( castFxIndex )
		end
	)
	
	-- Start function
	local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), targetPoint, caster, radius, targetTeam,
		targetType, targetFlag, unitOrder, false
	)
	
	for _, target in pairs( units ) do
		counter = counter + 1
		ability:ApplyDataDrivenModifier( caster, target, modifierTargetName, {} )
		Timers:CreateTimer( counter * attack_interval, function()
				-- Only jump to it if it's alive
				if target:IsAlive() then
					-- Create trail particles
					local trailFxIndex = ParticleManager:CreateParticle( particleTrailName, PATTACH_CUSTOMORIGIN, target )
					ParticleManager:SetParticleControl( trailFxIndex, 0, target:GetAbsOrigin() )
					ParticleManager:SetParticleControl( trailFxIndex, 1, caster:GetAbsOrigin() )
					
					Timers:CreateTimer( 0.1, function()
							ParticleManager:DestroyParticle( trailFxIndex, false )
							ParticleManager:ReleaseParticleIndex( trailFxIndex )
							return nil
						end
					)
					
					-- Move hero there
					FindClearSpaceForUnit( caster, target:GetAbsOrigin(), false )
					
					if target:IsHero() then
						ability:ApplyDataDrivenModifier( caster, caster, modifierHeroName, {} )
					else
						ability:ApplyDataDrivenModifier( caster, caster, modifierCreepName, {} )
					end
					
					caster:PerformAttack( target, true, false, true, false )
					
					-- Slash particles
					local slashFxIndex = ParticleManager:CreateParticle( particleSlashName, PATTACH_ABSORIGIN_FOLLOW, target )
					StartSoundEvent( slashSound, caster )
					
					Timers:CreateTimer( 0.1, function()
							ParticleManager:DestroyParticle( slashFxIndex, false )
							ParticleManager:ReleaseParticleIndex( slashFxIndex )
							StopSoundEvent( slashSound, caster )
							return nil
						end
					)
					
					-- Clean up modifier
					caster:RemoveModifierByName( modifierHeroName )
					caster:RemoveModifierByName( modifierCreepName )
					target:RemoveModifierByName( modifierTargetName )
				end
				return nil
			end
		)
	end
	
	-- Return caster to origin position
	Timers:CreateTimer( ( counter + 1 ) * attack_interval, function()
			FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
			dummy:RemoveSelf()
			caster:RemoveModifierByName( casterModifierName )
			caster.sleight_of_fist_active = false
			return nil
		end
	)
end