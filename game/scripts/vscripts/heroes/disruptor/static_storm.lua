--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Deals an increasing amount of damage on every pulse]]
function DealDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_increase = ability:GetLevelSpecialValueFor("damage_increase", ability.level -1)
	local pulses = ability:GetLevelSpecialValueFor("pulses", ability.level -1)
	local radius = ability:GetLevelSpecialValueFor("radius", ability.level -1)
	
	-- Instantiates the pulse variable, and increments it on every run
	if ability.pulse == nil then
		ability.pulse = 1
	else
		ability.pulse = ability.pulse + 1
	end
	
	-- Our damage variable that increases on every pulse
	local damage = ability.pulse * damage_increase
	
	-- Finds all units in the radius and applies the pulse damage
	local units = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    for _, unit in ipairs(units) do
        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
    end
	
	-- If there are no pulses left, we destroy the particles and reset the pulse variable
	if ability.pulse == pulses then
		ParticleManager:DestroyParticle(ability.particle, true)
		ability.pulse = nil
	end
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Renders the particles over the radius]]
function RenderParticles(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	
	ability.level = ability:GetLevel()
	
	ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.particle, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(ability.particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.particle, 2, target:GetAbsOrigin())
end
