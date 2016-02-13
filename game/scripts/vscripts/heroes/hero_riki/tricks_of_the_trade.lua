--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Riki attacks the target and applies all passive effects]]
function PerformAttacks(keys)
	local caster = keys.caster
	local target = keys.target
	
	caster:PerformAttack(target, true, true, true, false, false)
end

--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Riki backstabs the target]]
function ProcBackstab(keys)
	local caster = keys.caster
	local target = keys.target
	local cloak_and_dagger = caster:FindAbilityByName("cloak_and_dagger_datadriven")
	local ability_level = cloak_and_dagger:GetLevel() - 1

	local agility_damage_multiplier = cloak_and_dagger:GetLevelSpecialValueFor("agility_damage", ability_level) / 100
	if ability_level > 0 then
		-- Play the sound on the victim.
		EmitSoundOn(keys.sound, keys.target)
		-- Create the back particle effect.
		local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, target) 
		-- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
		-- Apply extra backstab damage based on Riki's agility
		ApplyDamage({victim = target, attacker = caster, damage = caster:GetAgility() * agility_damage_multiplier, damage_type = cloak_and_dagger:GetAbilityDamageType()})
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Riki's model is hidden]]
function RemoveModel(keys)
	local caster = keys.caster
	
	caster:AddNoDraw()	
end

--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Riki's model is redrawn]]
function DrawModel(keys)
	local caster = keys.caster

	caster:RemoveNoDraw()
end
