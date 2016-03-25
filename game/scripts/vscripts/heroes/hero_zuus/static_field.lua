--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Checks if the event was called by an ability and if so deals the health-based damage]]
function StaticField(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local damage_health_pct = ability:GetLevelSpecialValueFor("damage_health_pct", (ability:GetLevel() -1))/100
	local is_ability = false
	
	-- Finds the ability that caused the event trigger by checking if the cooldown is equal to the full cooldown
	for i=0, 15 do
		if caster:GetAbilityByIndex(i) ~= null then
			local cd = caster:GetAbilityByIndex(i):GetCooldownTimeRemaining()
			local full_cd = caster:GetAbilityByIndex(i):GetCooldown(caster:GetAbilityByIndex(i):GetLevel()-1)
			-- There is a delay after the ability cast event and before the ability goes on cooldown
			-- If the ability is on cooldown and the cooldown is within a small buffer of the full cooldown
			-- We set the is_ability variable to true
			if cd > 0 and full_cd - cd < 0.04 then
				is_ability = true
			end
		end
	end
	
	if is_ability == true then
		-- Finds every unit in the radius
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
		for i,unit in ipairs(units) do
			-- Attaches the particle
			local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, unit)
			ParticleManager:SetParticleControl(particle,0,unit:GetAbsOrigin())
			-- Plays the sound on the target
			EmitSoundOn(keys.sound, unit)
			-- Deals the damage based on the unit's current health
			ApplyDamage({victim = unit, attacker = caster, damage = unit:GetHealth() * damage_health_pct, damage_type = ability:GetAbilityDamageType()})
		end
	end
end
