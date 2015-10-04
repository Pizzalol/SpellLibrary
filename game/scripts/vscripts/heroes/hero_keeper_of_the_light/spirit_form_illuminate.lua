
--[[Author: Pizzalol
	Date: 25.01.2015.
	Initializes the dummy unit, channeling time and all the necessary positions and modifiers]]
function SpiritFormIlluminateInitialize( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()
	local ability_name = ability:GetAbilityName()

	local caster_location = caster:GetAbsOrigin()
	local player = caster:GetPlayerID()
	local caster_direction = caster:GetForwardVector()

	local dummy_modifier = keys.dummy_modifier

	local max_channel_time = ability:GetLevelSpecialValueFor("max_channel_time", (ability:GetLevel() - 1)) + 0.03 -- Apply it for 1 frame longer than the duration

	caster.spirit_form_illuminate_dummy = CreateUnitByName("npc_dummy_unit", caster_location, false, caster, caster, caster:GetTeam())
	caster.spirit_form_illuminate_dummy:SetForwardVector(caster_direction)
	caster.spirit_form_illuminate_dummy.spirit_form_illuminate_vision_position = caster_location
	caster.spirit_form_illuminate_dummy.spirit_form_illuminate_position = caster_location
	caster.spirit_form_illuminate_dummy.spirit_form_illuminate_direction = caster_direction
	caster.spirit_form_illuminate_dummy.spirit_form_illuminate_start_time = GameRules:GetGameTime()
	ability:ApplyDataDrivenModifier(caster, caster.spirit_form_illuminate_dummy, dummy_modifier, {duration = max_channel_time})
end

--[[
	Author: Noya
	Used by: Pizzalol
	Date: 25.01.2015.
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

--[[Author: Pizzalol
	Date: 25.01.2015.
	Creates vision fields every tick interval on the set positions]]
function SpiritFormIlluminateVisionFields( keys )
	local target = keys.target
	local ability = keys.ability

	-- Vision variables
	local channel_vision_radius = ability:GetLevelSpecialValueFor("channel_vision_radius", (ability:GetLevel() - 1))
	local channel_vision_duration = ability:GetLevelSpecialValueFor("channel_vision_duration", (ability:GetLevel() - 1))
	local channel_vision_step = ability:GetLevelSpecialValueFor("channel_vision_step", (ability:GetLevel() - 1))

	-- Calculating the position
	target.spirit_form_illuminate_vision_position = target.spirit_form_illuminate_vision_position + target.spirit_form_illuminate_direction * channel_vision_step

	ability:CreateVisibilityNode(target.spirit_form_illuminate_vision_position, channel_vision_radius, channel_vision_duration)
end

--[[Author: Pizzalol
	Date: 25.01.2015.
	Calculates the channel time according to the modifiers on the dummy unit
	Calculates the damage according to the channel time
	Creates a projectile based on the casters starting channeling position]]
function SpiritFormIlluminateEnd( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- Ability variables
	caster.spirit_form_illuminate_damage = 0
	local damage_per_second = ability:GetLevelSpecialValueFor("damage_per_second", (ability:GetLevel() - 1))

	-- Projectile variables
	local projectile_name = keys.projectile_name
	local projectile_speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	local projectile_distance = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() - 1))
	local projectile_radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))

	-- Calculating the Illuminate channel time and damage
	caster.spirit_form_illuminate_channel_time = GameRules:GetGameTime() - caster.spirit_form_illuminate_dummy.spirit_form_illuminate_start_time
	caster.spirit_form_illuminate_damage = caster.spirit_form_illuminate_channel_time * damage_per_second

	-- Create projectile
	local projectileTable =
	{
		EffectName = projectile_name,
		Ability = ability,
		vSpawnOrigin = target.spirit_form_illuminate_position,
		vVelocity = target.spirit_form_illuminate_direction * projectile_speed,
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
	caster.spirit_form_illuminate_projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )

	-- Kill the dummy
	Timers:CreateTimer(0.03, function()
		target:RemoveSelf()
	end)
end

--[[Author: Pizzalol
	Date: 25.01.2015.
	Deals damage according to the channel time]]
function SpiritFormIlluminateProjectileHit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = caster.spirit_form_illuminate_damage

	ApplyDamage(damage_table)
end

--[[Author: Noya
	Used by: Pizzalol
	Date: 25.01.2015.
	Swaps the abilities]]
function SwapAbilities( keys )
	local caster = keys.caster

	-- Swap sub_ability
	local sub_ability_name = keys.sub_ability_name
	local main_ability_name = keys.main_ability_name

	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
end

--[[Author: Pizzalol
	Date: 25.01.2015.
	Stops the dummy channeling]]
function SpiritFormIlluminateStop( keys )
	local caster = keys.caster
	local ability = keys.ability

	local dummy_modifier = keys.dummy_modifier

	caster.spirit_form_illuminate_dummy:RemoveModifierByName(dummy_modifier)
end