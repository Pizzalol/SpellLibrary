--[[Author: Pizzalol
	Date: 02.04.2015.
	Deals damage around the holder of the ion shell modifier]]
function IonShell( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level) 
	local think_interval = ability:GetLevelSpecialValueFor("think_interval", ability_level) 
	local damage = ability:GetLevelSpecialValueFor("damage_per_second", ability_level) * think_interval
	local ion_particle = keys.ion_particle

	-- Targeting variables
	local target_teams = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = ability:GetAbilityTargetType() 
	local target_flags = DOTA_UNIT_TARGET_FLAG_NONE

	-- Initialize the damage table
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.damage = damage
	damage_table.damage_type = ability:GetAbilityDamageType() 
	damage_table.ability = ability

	-- Find all the valid units in radius
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)

	for _,unit in ipairs(units) do
		-- Damage the unit as long as the found unit is not the holder of the modifier
		if unit ~= target then
			-- Play the damage particle
			local particle = ParticleManager:CreateParticle(ion_particle, PATTACH_POINT_FOLLOW, unit) 
			ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true) 
			ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particle)

			damage_table.victim = unit
			ApplyDamage(damage_table)
		end
	end
end