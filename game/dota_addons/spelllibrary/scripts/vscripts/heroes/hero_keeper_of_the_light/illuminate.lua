
--[[Author: Pizzalol/Noya
	Date: 24.01.2015.
	Initializes the Illuminate and swaps the abilities]]
function IlluminateStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster.illuminate_position = caster:GetAbsOrigin()
	caster.illuminate_vision_position = caster.illuminate_position
	caster.illuminate_direction = caster:GetForwardVector()

	-- Swap sub_ability
	local sub_ability_name = keys.sub_ability_name
	local main_ability_name = ability:GetAbilityName()

	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
end

--[[Author: Pizzalol
	Date: 24.01.2015.
	Creates vision fields every tick interval on the set positions]]
function IlluminateVisionFields( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Vision variables
	local channel_vision_radius = ability:GetLevelSpecialValueFor("channel_vision_radius", (ability:GetLevel() - 1))
	local channel_vision_duration = ability:GetLevelSpecialValueFor("channel_vision_duration", (ability:GetLevel() - 1))
	local channel_vision_step = ability:GetLevelSpecialValueFor("channel_vision_step", (ability:GetLevel() - 1))

	-- Calculating the position
	caster.illuminate_vision_position = caster.illuminate_vision_position + caster.illuminate_direction * channel_vision_step

	ability:CreateVisibilityNode(caster.illuminate_vision_position, channel_vision_radius, channel_vision_duration)
end

--[[Author: Pizzalol
	Date: 24.01.2015.
	Calculates the channel time according to the modifiers on the caster, removes the modifiers afterwards
	Calculates the damage according to the channel time
	Creates a projectile based on the casters starting channeling position]]
function IlluminateEnd( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Ability variables
	caster.illuminate_channel_time = 0
	caster.illuminate_damage = 0
	local modifier_channel_count = keys.modifier_channel_count
	local channel_count_interval = ability:GetLevelSpecialValueFor("channel_count_interval", (ability:GetLevel() - 1))
	local damage_per_second = ability:GetLevelSpecialValueFor("damage_per_second", (ability:GetLevel() - 1))

	-- Projectile variables
	local projectile_name = keys.projectile_name
	local projectile_speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	local projectile_distance = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() - 1))
	local projectile_radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))


	-- Calculating the Illuminate channel time and damage
	local modifier_count = caster:GetModifierCount()

	for i = 0, modifier_count do
		if caster:GetModifierNameByIndex(i) == modifier_channel_count then
			caster.illuminate_channel_time = caster.illuminate_channel_time + 1
		end
	end

	caster.illuminate_channel_time = caster.illuminate_channel_time * channel_count_interval
	caster.illuminate_damage = caster.illuminate_channel_time * damage_per_second

	-- Removing all the modifiers we used to calculate the channel time
	for i = 0, modifier_count do
		if caster:GetModifierNameByIndex(i) == modifier_channel_count then
			caster:RemoveModifierByName(modifier_channel_count)
		end
	end

	-- Create projectile
	local projectileTable =
	{
		EffectName = projectile_name,
		Ability = ability,
		vSpawnOrigin = caster.illuminate_position,
		vVelocity = caster.illuminate_direction * projectile_speed,
		fDistance = projectile_distance,
		fStartRadius = projectile_radius,
		fEndRadius = projectile_radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = true,
		iUnitTargetTeam = ability:GetAbilityTargetTeam(),
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = ability:GetAbilityTargetType()
	}
	caster.illuminate_projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
end

--[[Author: Pizzalol
	Date: 24.01.2015.
	Deals damage according to the channel time]]
function IlluminateProjectileHit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = caster.illuminate_damage

	ApplyDamage(damage_table)
end

--[[Author: Noya
	Used by: Pizzalol
	Date: 24.01.2015.
	Swaps the abilities back]]
function IlluminateSwapEnd( keys )
	local caster = keys.caster
	local main_ability = keys.ability

	-- Swap the sub_ability back to normal
	local main_ability_name = main_ability:GetAbilityName()
	local sub_ability_name = keys.sub_ability_name

	caster:SwapAbilities(main_ability_name, sub_ability_name, true, false)
end

--[[Author: Pizzalol
	Date: 24.01.2015.
	Stops the ability channel]]
function IlluminateStop( keys )
	local caster = keys.caster

	caster:Stop()
end

--[[
	Author: Noya
	Used by: Pizzalol
	Date: 24.01.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end