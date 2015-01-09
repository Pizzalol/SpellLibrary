--[[
	Author: Noya
	Date: 9.1.2015.
	Does non lethal magic damage to the caster
]]
function DoubleEdgeSelfDamage( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local self_damage = ability:GetLevelSpecialValueFor( "edge_damage" , ability:GetLevel() - 1  )
	local HP = caster:GetHealth()
	local MagicResist = caster:GetMagicalArmorValue()
	local damageType = ability:GetAbilityDamageType()

	-- Calculate the magic damage
	local damagePostReduction = self_damage * (1 - MagicResist)
	
	-- If its lethal damage, set hp to 1, else do the full self damage
	if HP <= damagePostReduction then
		caster:SetHealth(1)
	else
		-- Self Damage
		ApplyDamage({ victim = caster, attacker = caster, damage = self_damage,	damage_type = damageType })
	end

end

function DoubleEdgeParticle( event )
	local caster = event.caster
	local target = event.target

	-- Particle
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- Origin
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) -- Destination
	ParticleManager:SetParticleControl(particle, 5, target:GetAbsOrigin()) -- Hit Glow
end