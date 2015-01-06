--[[
	Author: kritth
	Date: 5.1.2015.
	Register the target and order to attack
]]
function focusfire_register( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster.focusfire_target = keys.target
	
	-- Apply buff
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_focusfire_attackspeed_buff_datadriven", {} )
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_focusfire_damage_debuff_datadriven", {} )
	
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
function focusfire_on_attack_start( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target ~= caster.focusfire_target then
		caster:RemoveModifierByName( "modifier_focusfire_attackspeed_buff_datadriven" )
	else
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_focusfire_attackspeed_buff_datadriven", {} )
	end
end

--[[
	Author: kritth
	Date: 5.1.2015.
	Add/Remove damage debuff modifier when attack has already landed
]]
function focusfire_on_attack_landed( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target ~= caster.focusfire_target then
		caster:RemoveModifierByName( "modifier_focusfire_damage_debuff_datadriven" )
	else
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_focusfire_damage_debuff_datadriven", {} )
	end
end
