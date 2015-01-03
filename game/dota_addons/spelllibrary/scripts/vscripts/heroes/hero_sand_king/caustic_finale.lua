--[[
	Author: kritth
	Date: 3.1.2015.
	Fire effect at target's location upon dead
]]
function caustic_finale_dead_effect( keys )
	print( keys.target:GetHealth() )
	if not keys.target:IsAlive() then
		local particleName = "particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf"
		local soundEventName = "Ability.SandKing_CausticFinale"
		
		local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, keys.target )
		ParticleManager:ReleaseParticleIndex( fxIndex )
		StartSoundEvent( soundEventName, keys.target )
	end
end
