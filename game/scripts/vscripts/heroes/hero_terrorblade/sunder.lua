--[[Author: Noya
	Date: 11.01.2015.
	Swaps the health percentage of caster and target up to a threshold
]]
function Sunder( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local hit_point_minimum_pct = ability:GetLevelSpecialValueFor( "hit_point_minimum_pct", ability:GetLevel() - 1 ) * 0.01
	local caster_maxHealth = caster:GetMaxHealth()
	local target_maxHealth = target:GetMaxHealth()
	local casterHP_percent = caster:GetHealth() / caster_maxHealth
	local targetHP_percent = target:GetHealth() / target_maxHealth

	-- Swap the HP of the caster
	if targetHP_percent <= hit_point_minimum_pct then
		caster:SetHealth(caster_maxHealth * hit_point_minimum_pct)
	else
		caster:SetHealth(caster_maxHealth * targetHP_percent)
	end

	-- Swap the HP of the target
	if casterHP_percent <= hit_point_minimum_pct then
		target:SetHealth(target_maxHealth * hit_point_minimum_pct)
	else
		target:SetHealth(target_maxHealth * casterHP_percent)
	end

	-- Show the particle caster-> target
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"	
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, target )

	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

	-- Show the particle target-> caster
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"	
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )

	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

end