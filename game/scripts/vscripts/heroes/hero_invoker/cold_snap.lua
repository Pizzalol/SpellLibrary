--[[Author: Pizzalol
	Date: 13.04.2015.
	Applies the initial stun and modifier depending on Quas level]]
function ColdSnapStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local quas_level = caster:FindAbilityByName("invoker_quas_datadriven"):GetLevel() - 1

	local duration = ability:GetLevelSpecialValueFor("duration", quas_level) 
	local freeze_duration = ability:GetLevelSpecialValueFor("freeze_duration", quas_level) 
	local freeze_cooldown = ability:GetLevelSpecialValueFor("freeze_cooldown", quas_level) 
	local freeze_damage = ability:GetLevelSpecialValueFor("freeze_damage", quas_level)
	local cooldown_modifier = keys.cooldown_modifier
	local stun_modifier = keys.stun_modifier
	local cold_snap_modifier = keys.cold_snap_modifier

	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType() 
	damage_table.damage = freeze_damage

	ability:ApplyDataDrivenModifier(caster, target, cold_snap_modifier, {Duration = duration}) 
	ability:ApplyDataDrivenModifier(caster, target, stun_modifier, {Duration = freeze_duration}) 
	ability:ApplyDataDrivenModifier(caster, target, cooldown_modifier, {Duration = freeze_cooldown}) 

	ApplyDamage(damage_table)
end

--[[Author: Pizzalol
	Date: 13.04.2015.
	If the damage taken is enough to trigger the Cold Snap then stun and deal damage depending on the Quas level]]
function ColdSnapDamage( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local quas_level = caster:FindAbilityByName("invoker_quas_datadriven"):GetLevel() - 1

	local damage_taken = keys.DamageTaken
	local freeze_duration = ability:GetLevelSpecialValueFor("freeze_duration", quas_level) 
	local freeze_cooldown = ability:GetLevelSpecialValueFor("freeze_cooldown", quas_level) 
	local freeze_damage = ability:GetLevelSpecialValueFor("freeze_damage", quas_level)
	local damage_trigger = ability:GetLevelSpecialValueFor("damage_trigger", quas_level)
	local cooldown_modifier = keys.cooldown_modifier
	local stun_modifier = keys.stun_modifier

	if damage_taken >= damage_trigger and not target:HasModifier(cooldown_modifier) then
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = freeze_damage

		ability:ApplyDataDrivenModifier(caster, target, stun_modifier, {Duration = freeze_duration}) 
		ability:ApplyDataDrivenModifier(caster, target, cooldown_modifier, {Duration = freeze_cooldown})

		ApplyDamage(damage_table)
	end
end