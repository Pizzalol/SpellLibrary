--[[Author: Pizzalol
	Date: 02.01.2015.
	Triggers on death and grants bonus gold to the caster and friendly heroes around the target]]
function Track( keys )
	local caster = keys.caster
	local target = keys.target
	local targetLocation = target:GetAbsOrigin() 
	local ability = keys.ability
	local bonus_gold_self = ability:GetLevelSpecialValueFor("bonus_gold_self", (ability:GetLevel() - 1))
	local bonus_gold = ability:GetLevelSpecialValueFor("bonus_gold", (ability:GetLevel() - 1))
	local bonus_gold_radius = ability:GetLevelSpecialValueFor("bonus_gold_radius", (ability:GetLevel() - 1))

	-- Checks if the target is alive when the modifier is destroyed
	if not target:IsAlive() then

		-- Gives gold to the caster
		caster:ModifyGold(bonus_gold_self, true, 0)
		-- Finds all valid friendly heroes within the bonus gold radius
		local bonus_gold_targets = FindUnitsInRadius(caster:GetTeam() , targetLocation, nil, bonus_gold_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, 0, 0, false)

		-- Grants them gold but we must exclude the caster
		for i,v in ipairs(bonus_gold_targets) do
			if not (v == caster) then
				v:ModifyGold(bonus_gold, true, 0)
			end
		end
	end

	-- Remove the track aura from the target
	-- NOTE: Trying to do this in KV is not possible it seems
	target:RemoveModifierByName("modifier_track_aura_datadriven") 
end