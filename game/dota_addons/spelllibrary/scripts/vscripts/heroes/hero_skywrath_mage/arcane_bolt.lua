--[[
	CHANGELIST:
	09.01.2015 - Standized variables
]]

--[[
	Author: kritth
	Date: 8.1.2015.
	Initialize linked list for multiple instances of damage
]]
function arcane_bolt_init( keys )
	local caster = keys.caster
	local intelligence = keys.caster:GetIntellect()
	if caster.arcane_bolt_list_head == nil then
		caster.arcane_bolt_list_tail = {}
		caster.arcane_bolt_list_head = { next = caster.arcane_bolt_list_tail, value = intelligence }
	else
		local tmp = {}
		caster.arcane_bolt_list_tail.next = tmp
		caster.arcane_bolt_list_tail.value = intelligence
		caster.arcane_bolt_list_tail = tmp
	end
end

--[[
	Author: kritth
	Date: 09.01.2015
	Calculating the damage for arcane bolt
]]
function arcane_bolt_hit( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor( "bolt_vision", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
	local base_damage = ability:GetLevelSpecialValueFor( "bolt_damage", ability:GetLevel() - 1 )
	local multiplier = ability:GetLevelSpecialValueFor( "int_multiplier", ability:GetLevel() - 1 )
	local intelligence = math.max( 0, caster.arcane_bolt_list_head.value )
	local damageType = ability:GetAbilityDamageType() -- DAMAGE_TYPE_MAGICAL
	
	-- Update linked head node
	if caster.arcane_bolt_list_head ~= caster.arcane_bolt_list_tail then
		caster.arcane_bolt_list_head = caster.arcane_bolt_list_head.next
	else
		caster.arcane_bolt_list_head = nil
	end
	
	-- Deal damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = base_damage + intelligence * multiplier,
		damage_type = damageType,
	}
	ApplyDamage( damageTable )
	
	-- Provide visibility
	ability:CreateVisibilityNode( target:GetAbsOrigin(), radius, duration )
end
