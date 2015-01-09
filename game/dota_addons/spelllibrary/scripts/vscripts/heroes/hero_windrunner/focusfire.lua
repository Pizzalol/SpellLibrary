--[[
	CHANGE LIST:
	09.01.2015 - Standizard the variables, remove unnecessary funcion
]]

--[[
	Author: kritth
	Date: 5.1.2015.
	Register the target and order to attack
]]
function focusfire_register( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local modifierAttackSpeed = "modifier_focusfire_attackspeed_buff_datadriven"
	local modifierDamageDebuff = "modifier_focusfire_damage_debuff_datadriven"
	
	-- Set target
	caster.focusfire_target = keys.target
	
	-- Apply buff
	ability:ApplyDataDrivenModifier( caster, caster, modifierAttackSpeed, {} )
	ability:ApplyDataDrivenModifier( caster, caster, modifierDamageDebuff, {} )
	
	-- Order to attack immediately
	local order =
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = keys.target:entindex()
	}
	ExecuteOrderFromTable( order )
end

--[[
	Author: kritth
	Date: 5.1.2015.
	Add/Remove damage debuff modifier when attack start 
]]
function focusfire_on_attack_landed( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierToRemove = "modifier_focusfire_attackspeed_buff_datadriven"
	
	-- Check if it hit the specified target
	if target ~= caster.focusfire_target then
		caster:RemoveModifierByName( modifierToRemove )
	else
		ability:ApplyDataDrivenModifier( caster, caster, modifierToRemove, {} )
	end
end
