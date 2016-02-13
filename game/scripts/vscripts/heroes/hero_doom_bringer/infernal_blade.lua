--[[Author: YOLOSPAGHETTI
	Date: February 8, 2016
	Checks if the orb is off cooldown]]
function CheckCooldown(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mana = ability:GetLevelSpecialValueFor("AbilityManaCost", ability:GetLevel() - 1)
	
	-- If orb is off cooldown, applies the particles and sound, and removes the necessary mana
	if ability:IsCooldownReady() then
		ability.off_cooldown = 1
		caster:SetMana(caster:GetMana() - mana)
		EmitSoundOn(keys.sound, caster)
		local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, caster) 
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 8, 2016
	Applies modifiers to the target]]
function ApplyModifiers(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	
	-- If the orb was off cooldown in CheckCooldown, we apply modifiers to the target and start the orb cooldown
	if ability.off_cooldown == 1 then
		-- Apply the modifiers
		ability:ApplyDataDrivenModifier(caster, target, "modifier_infernal_blade_damage", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_infernal_blade_stun", {})
		-- Start cooldown on the orb
		ability:StartCooldown(cooldown)
		ability.off_cooldown = 0
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 8, 2016
	Deals the damage per max health to the target]]
function DealDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local health_damage_pct = ability:GetLevelSpecialValueFor("health_damage_pct", ability:GetLevel() - 1) / 100
	local health = target:GetMaxHealth()
	
	ApplyDamage({victim = target, attacker = caster, damage = health * health_damage_pct, damage_type = ability:GetAbilityDamageType()})
end
