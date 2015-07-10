--[[Author: kritth, Pizzalol
	Date: 20.04.2015.
	Creates vision over the targeted area and creates the charge particle for every player
	on the casters team]]
function sun_strike_charge( keys )
	local caster = keys.caster
	local caster_team = caster:GetTeam()
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local charge_particle = keys.charge_particle
	local delay = ability:GetLevelSpecialValueFor("delay", ability_level)
	local area_of_effect = ability:GetLevelSpecialValueFor("area_of_effect", ability_level)
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level) 
	local vision_distance = ability:GetLevelSpecialValueFor("vision_distance", ability_level) 
	local all_heroes = HeroList:GetAllHeroes()

	-- Create the vision
	local duration = delay + vision_duration
	ability:CreateVisibilityNode(target_location, vision_distance, vision_duration)

	-- Create the sun strike charge up particle for each player on the caster team
	for _,hero in pairs(all_heroes) do
		if hero:GetPlayerID() and hero:GetTeam() == caster_team then
			local particle = ParticleManager:CreateParticleForPlayer(charge_particle, PATTACH_ABSORIGIN, hero, PlayerResource:GetPlayer(hero:GetPlayerID()))
			ParticleManager:SetParticleControl(particle, 0, target_location) 
			ParticleManager:SetParticleControl(particle, 1, Vector(area_of_effect,0,0))

			-- Remove the particle after the charging is done
			Timers:CreateTimer(delay, function()
				ParticleManager:DestroyParticle(particle, false)
			end)
		end
	end
end

--[[Author: Pizzalol
	Date: 20.04.2015.
	Deal damage split between enemy heroes depending on the level of Exort]]
function sun_strike_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin() 
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local exort_level = caster:FindAbilityByName("invoker_exort_datadriven"):GetLevel() - 1

	-- Ability variables
	local area_of_effect = ability:GetLevelSpecialValueFor("area_of_effect", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", exort_level)

	-- Targeting variables
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()

	local found_targets = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, area_of_effect, target_teams, target_types, target_flags, FIND_CLOSEST, false)

	-- Initialize the damage table
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType() 
	damage_table.damage = damage / #found_targets

	-- Deal damage to each found hero
	for _,hero in pairs(found_targets) do
		damage_table.victim = hero
		ApplyDamage(damage_table)
	end
end