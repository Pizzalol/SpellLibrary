arrowTable = arrowTable or {}

--[[Author: Pizzalol
	Date: 04.01.2015.
	Initializes the caster location for the arrow stun and damage calculation]]
function LaunchArrow( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()

	arrowTable[caster] = arrowTable[caster] or {}

	arrowTable[caster].location = caster_location
end

--[[Author: Pizzalol
	Date: 04.01.2015.
	Changed: 06.01.2015.
	Calculates the distance traveled by the arrow, then applies damage and stun according to calculations
	Provides vision of the area upon impact]]
function ArrowHit( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_damage = ability:GetAbilityDamage()

	-- Vision
	local vision_radius = ability:GetLevelSpecialValueFor("arrow_vision", (ability:GetLevel() - 1))
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", (ability:GetLevel() - 1))
	ability:CreateVisibilityNode(target_location, vision_radius, vision_duration)

	-- Initializing the damage table
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.ability = ability	

	-- Arrow
	local arrow_max_stunrange = ability:GetLevelSpecialValueFor("arrow_max_stunrange", (ability:GetLevel() - 1))
	local arrow_max_damagerange = ability:GetLevelSpecialValueFor("arrow_max_damagerange", (ability:GetLevel() - 1))
	local arrow_min_stun = ability:GetLevelSpecialValueFor("arrow_min_stun", (ability:GetLevel() - 1))
	local arrow_max_stun = ability:GetLevelSpecialValueFor("arrow_max_stun", (ability:GetLevel() - 1))
	local arrow_bonus_damage = ability:GetLevelSpecialValueFor("arrow_bonus_damage", (ability:GetLevel() - 1))

	-- Stun and damage per distance
	local stun_per_30 = arrow_max_stun/(arrow_max_stunrange*0.033)
	local damage_per_30 = arrow_bonus_damage/(arrow_max_damagerange*0.033)

	local arrow_stun_duration
	local arrow_damage
	local distance = (target_location - arrowTable[caster].location):Length2D()

	-- Stun
	if distance < arrow_max_stunrange then
		arrow_stun_duration = distance*0.033*stun_per_30 + arrow_min_stun
	else
		arrow_stun_duration = arrow_max_stun
	end

	-- Damage
	if distance < arrow_max_damagerange then
		arrow_damage = distance*0.033*damage_per_30 + ability_damage
	else
		arrow_damage = ability_damage + arrow_bonus_damage
	end

	target:AddNewModifier(caster, nil, "modifier_stunned", {duration = arrow_stun_duration})
	damage_table.damage = arrow_damage
	ApplyDamage(damage_table)
end