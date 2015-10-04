--[[
	CHANGELIST:
	09.01.2015 - Standardized variables
]]

--[[
	Author: kritth
	Date: 09.01.2015.
	Deal constant interval damage shared in the radius
]]
function mystic_flare_start( keys )
	-- Variables
	local ability = keys.ability
	local caster = keys.caster
	local current_instance = 0
	local dummyModifierName = "modifier_mystic_flare_dummy_vfx_datadriven"
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local interval = ability:GetLevelSpecialValueFor( "damage_interval", ability:GetLevel() - 1 )
	local max_instances = math.floor( duration / interval )
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local target = keys.target_points[1]
	local total_damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
	local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_HERO
	local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
	local damageType = ability:GetAbilityDamageType() -- DAMAGE_TYPE_MAGICAL
	local soundTarget = "Hero_SkywrathMage.MysticFlare.Target"
	
	-- Create for VFX particles on ground
	local dummy = CreateUnitByName( "npc_dummy_unit", target, false, caster, caster, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
	
	-- Referencing total damage done per interval
	local damage_per_interval = total_damage / max_instances
	
	-- Deal damage per interval equally
	Timers:CreateTimer( function()
			local units = FindUnitsInRadius(
				caster:GetTeamNumber(), target, caster, radius, targetTeam,
				targetType, targetFlag, FIND_ANY_ORDER, false
			)
			if #units > 0 then
				local damage_per_hero = damage_per_interval / #units
				for k, v in pairs( units ) do
					-- Apply damage
					local damageTable = {
						victim = v,
						attacker = caster,
						damage = damage_per_hero,
						damage_type = damageType
					}
					ApplyDamage( damageTable )
					
					-- Fire sound
					StartSoundEvent( soundTarget, v )
				end
			end
			
			current_instance = current_instance + 1
			
			-- Check if maximum instances reached
			if current_instance >= max_instances then
				dummy:Destroy()
				return nil
			else
				return interval
			end
		end
	)
end
