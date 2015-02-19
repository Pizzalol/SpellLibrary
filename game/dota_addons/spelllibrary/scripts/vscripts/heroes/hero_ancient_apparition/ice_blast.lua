
function ice_blast_launch( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local dummy_modifier = keys.dummy_modifier

	-- Dummy
	local dummy = CreateUnitByName("npc_dummy_blank", target_point, false, caster, caster, caster:GetTeam())
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {})
end