--[[
	CHANGELIST:
	09.01.2015 - Remove ReleaseParticleIndex( .. )
]]

--[[
	Author: kritth
	Date: 09.01.2015
	Fire effect at target's location upon dead
]]
function caustic_finale_dead_effect( keys )
	print( keys.target:GetHealth() )
	if not keys.target:IsAlive() then
		local particleName = "particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf"
		local soundEventName = "Ability.SandKing_CausticFinale"
		
		local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, keys.target )
		StartSoundEvent( soundEventName, keys.target )
	end
end
