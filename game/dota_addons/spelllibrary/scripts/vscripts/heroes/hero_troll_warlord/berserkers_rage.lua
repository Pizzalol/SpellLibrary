--[[Author: Pizzalol
	Date: 14.03.2015.
	Checks the latest attack state and target to determine if a bash should be applied]]
function BerserkersRageBash( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local bash_duration = ability:GetLevelSpecialValueFor("bash_duration", ability_level) 
	local bash_damage = ability:GetLevelSpecialValueFor("bash_damage", ability_level)
	local sound = keys.sound

	-- Check the latest attack state and target to prevent ranged bashes
	if caster.berserkers_rage_attack == DOTA_UNIT_CAP_MELEE_ATTACK and caster.berserkers_rage_target == target then
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = bash_damage

		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = bash_duration})
		EmitSoundOn(sound, target)
		ApplyDamage(damage_table)
	end
end

--[[Author: Pizzalol
	Date: 14.03.2015.
	Swaps the attack capability of the caster]]
function BerserkersRageAttackCapability( keys )
	local caster = keys.caster

	if caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
		caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	else
		caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK) 
	end
end

--[[Author: Pizzalol
	Date: 14.03.2015.
	Keep track of the attacked target and the current attack state]]
function BerserkersRageTrack( keys )
	local caster = keys.caster
	local target = keys.target
	caster.berserkers_rage_attack = caster:GetAttackCapability()
	caster.berserkers_rage_target = target
end

--[[Author: Noya
	Used by: Pizzalol
	Date: 14.03.2015.
	Swaps the abilities]]
function SwapAbilities( keys )
	local caster = keys.caster

	-- Swap sub_ability
	local sub_ability_name = keys.sub_ability_name
	local main_ability_name = keys.main_ability_name

	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
end