--[[
	Author: kritth
	Date: 11.01.2015.
	Create dummy to explode at location
]]
function static_remnant_init( keys )
	-- Variables
	local caster = keys.caster
	local target = caster:GetAbsOrigin()
	local ability = keys.ability
	local model_name = caster:GetModelName()
	local dummyModifierName = "modifier_static_remnant_dummy_datadriven"
	local dummyFreezeModifierName = "modifier_static_remnant_dummy_freeze_datadriven"
	local remnant_timer = 0.0
	local remnant_interval_check = 0.1
	local delay = ability:GetLevelSpecialValueFor( "static_remnant_delay", ability:GetLevel() - 1 )
	local trigger_radius = ability:GetLevelSpecialValueFor( "static_remnant_radius", ability:GetLevel() - 1 )
	local damage_radius = ability:GetLevelSpecialValueFor( "static_remnant_damage_radius", ability:GetLevel() - 1 )
	local ability_damage = ability:GetLevelSpecialValueFor( "static_remnant_damage", ability:GetLevel() - 1 )
	local ability_damage_type = ability:GetAbilityDamageType()
	local ability_duration = ability:GetDuration()
	
	-- Dummy creation
	local dummy = CreateUnitByName( caster:GetName(), target, false, caster, nil, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
	
	Timers:CreateTimer( delay, function()
			if not dummy:HasModifier( dummyFreezeModifierName ) then
				ability:ApplyDataDrivenModifier( caster, dummy, dummyFreezeModifierName, {} )
			end
	
			-- Check in aoe
			local units = FindUnitsInRadius( caster:GetTeamNumber(), target, caster, trigger_radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
			
			-- If there is at least one unit, explode
			if #units > 0 then
				print( "deal damage" )
				for k, v in pairs( units ) do
					local damageTable = {
						victim = v,
						attacker = caster,
						damage = ability_damage,
						damage_type = ability_damage_type
					}
					ApplyDamage( damageTable )
				end
				
				StartSoundEvent( "Hero_StormSpirit.StaticRemnantExplode", dummy )
				
				dummy:RemoveSelf()
				return nil
			end
			
			-- Update timer
			remnant_timer = remnant_timer + remnant_interval_check
			
			-- Check if timer should be expired
			if remnant_timer >= ability_duration then
				print( "killing" )
				dummy:RemoveSelf()
				return nil
			else
				return remnant_interval_check
			end
		end
	)
end