--[[
	Author: Noya
	Date: 9.1.2015.
	Plays the slardar_amp_damage particle and destroys it later
]]
function AmplifyDamageParticle( event )
	local target = event.target
	local location = target:GetAbsOrigin()
	local particleName = "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"

-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		target.AmpDamageParticle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)
		ParticleManager:SetParticleControl(target.AmpDamageParticle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(target.AmpDamageParticle, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(target.AmpDamageParticle, 2, target:GetAbsOrigin())

		ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 1, target, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 2, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	end)
end

-- Destroys the particle when the modifier is destroyed
function EndAmplifyDamageParticle( event )
	local target = event.target
	ParticleManager:DestroyParticle(target.AmpDamageParticle,false)
end