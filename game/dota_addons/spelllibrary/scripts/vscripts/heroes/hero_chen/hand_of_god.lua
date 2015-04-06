--[[Author: Pizzalol
	Date: 06.04.2015.
	If the target unit is owned by the caster then heal it to full]]
function HandOfGod( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local sound = keys.sound
	local hand_particle = keys.hand_particle

	if target:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and target ~= caster then
		local particle = ParticleManager:CreateParticle(hand_particle, PATTACH_POINT_FOLLOW, target) 
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle) 

		EmitSoundOn(sound, target) 

		target:Heal(target:GetMaxHealth(), ability)
	end
end