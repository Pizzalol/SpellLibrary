--[[Author: Pizzalol
	Date: 08.04.2015.
	Rolls the dice and then determines the damage and stun duration according to that]]
function ChaosBolt( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local stun_min = ability:GetLevelSpecialValueFor("stun_min", ability_level)
	local stun_max = ability:GetLevelSpecialValueFor("stun_max", ability_level) 
	local damage_min = ability:GetLevelSpecialValueFor("damage_min", ability_level) 
	local damage_max = ability:GetLevelSpecialValueFor("damage_max", ability_level)
	local chaos_bolt_particle = keys.chaos_bolt_particle

	-- Calculate the stun and damage values
	local random = RandomFloat(0, 1)
	local stun = stun_min + (stun_max - stun_min) * random
	local damage = damage_min + (damage_max - damage_min) * (1 - random)

	-- Calculate the number of digits needed for the particle
	local stun_digits = string.len(tostring(math.floor(stun))) + 1
	local damage_digits = string.len(tostring(math.floor(damage))) + 1

	-- Create the stun and damage particle for the spell
	local particle = ParticleManager:CreateParticle(chaos_bolt_particle, PATTACH_OVERHEAD_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, target_location) 

	-- Damage particle
	ParticleManager:SetParticleControl(particle, 1, Vector(9,damage,4)) -- prefix symbol, number, postfix symbol
	ParticleManager:SetParticleControl(particle, 2, Vector(2,damage_digits,0)) -- duration, digits, 0

	-- Stun particle
	ParticleManager:SetParticleControl(particle, 3, Vector(8,stun,0)) -- prefix symbol, number, postfix symbol
	ParticleManager:SetParticleControl(particle, 4, Vector(2,stun_digits,0)) -- duration, digits, 0
	ParticleManager:ReleaseParticleIndex(particle)

	-- Apply the stun duration
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})

	-- Initialize the damage table and deal the damage
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage

	ApplyDamage(damage_table)
end