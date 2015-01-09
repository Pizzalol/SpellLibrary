
function Chronosphere( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))

	local dummy_modifier = keys.caster_aura
	local dummy = CreateUnitByName("npc_dummy_blank", target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})

	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {})

	Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end

-- on aura created run this
-- on aura destroy remove this
function ChronosphereFriendly( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_modifier = keys.target_modifier

	if target:GetPlayerOwner() == caster:GetPlayerOwner() then
		ability:ApplyDataDrivenModifier(caster, target, target_modifier, {})
	end
end