--[[Curse of the Silent Mana Drain part
	Author: chrislotix
	Date: 10.1.2015.]]

function ManaDrain( keys )

	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local mana_drain = ability:GetLevelSpecialValueFor("mana_damage", (ability:GetLevel() -1))

	target:ReduceMana(mana_drain)
	
end