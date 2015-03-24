
function LandMinesPlant( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	caster.land_mine_count = caster.land_mine_count or 0
	caster.land_mine_table = caster.land_mine_table or {}

	local modifier_land_mine = keys.modifier_land_mine
	local modifier_tracker = keys.modifier_tracker

	local land_mine = CreateUnitByName("npc_dota_techies_land_mine", target_point, false, nil, nil, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, land_mine, modifier_land_mine, {})

	caster.land_mine_count = caster.land_mine_count + 1
	table.insert(caster.land_mine_table, land_mine)
end