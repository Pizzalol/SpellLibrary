--[[Author: Pizzalol
	Date: 26.01.2015.
	Saves the killer of the aura carrier]]
function CommandAuraDeath( keys )
	local caster = keys.caster
	local attacker = keys.attacker

	caster.command_aura_target = attacker
end

--[[Author: Pizzalol
	Date: 26.01.2015.
	Removes the negative aura from the killer on caster respawn]]
function CommandAuraRespawn( keys )
	local caster = keys.caster
	local modifier = keys.modifier

	caster.command_aura_target:RemoveModifierByName(modifier)
end