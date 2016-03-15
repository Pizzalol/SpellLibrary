--[[Author: YOLOSPAGHETTI
	Date: March 15, 2016
	Applies the burst damage on the necessary ticks]]
function DealBurst(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local burst_ticks = ability:GetLevelSpecialValueFor("burst_ticks", (ability:GetLevel() -1))
	local total_ticks = ability:GetLevelSpecialValueFor("duration_tooltip", (ability:GetLevel() -1))
	local tick_interval = total_ticks/burst_ticks
	
	-- Increments every tick
	if target.tick == nil then
		target.tick = 1
	else
		target.tick = target.tick + 1
	end
	
	-- Applies the damage-based burst damage on the required interval
	if target.tick%tick_interval == 0 then
		-- Play the sound on the victim.
		EmitSoundOn(keys.sound, target)
		-- Particle not attached properly
		--local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, target) 
		--ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
		
		local bonus_damage = ability:GetLevelSpecialValueFor("bonus_damage", (ability:GetLevel() -1))/100
		-- Applies burst damage based on the percentage of the target's current health from their initial health (during CheckHealth)
		local damage = (target.health - target:GetHealth()) * bonus_damage
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
		-- If we are on the last tick, stops the sound and resets the ticks
		if target.tick == total_ticks then
			StopSoundEvent(keys.sound2, target)
			target.tick = 0
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: March 15, 2016
	Checks the target's health as the debuff is applied to reference on every interval]]
function CheckHealth(keys)
	local target = keys.target
	
	EmitSoundOn(keys.sound, target)
	target.health = target:GetHealth()
end

--[[Author: YOLOSPAGHETTI
	Date: March 15, 2016
	Applies the debuff to the targets]]
function ApplyModifier(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local units = FindUnitsInRadius(caster:GetTeamNumber(), ability:GetCursorPosition(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
	local is_fail = true
	
	-- Applies the debuff to the targets in the area
	for i,unit in ipairs(units) do
		is_fail = false
		ability:ApplyDataDrivenModifier( caster, unit, "modifier_maledict_datadriven", {} )
	end
	
	-- If nobody is hit, plays the fail sound, otherwise plays the regular cast sound
	if is_fail == true then
		EmitSoundOn(keys.sound2, caster)
	else
		EmitSoundOn(keys.sound, caster)
	end
end
