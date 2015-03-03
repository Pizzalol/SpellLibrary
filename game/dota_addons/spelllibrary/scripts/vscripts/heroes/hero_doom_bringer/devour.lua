
function Devour( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local target_hp = target:GetHealth()
	local health_per_second = ability:GetLevelSpecialValueFor("health_per_second", ability_level)
	local modifier = keys.modifier
	local modifier_duration = target_hp/health_per_second

	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = modifier_duration})
	target:Kill(ability, caster)
end

function DevourGold( keys )
	local target = keys.target
	local player = PlayerResource:GetPlayer( target:GetPlayerID() )
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local bonus_gold = ability:GetLevelSpecialValueFor("bonus_gold", ability_level)

	if target:IsAlive() then
		target:ModifyGold(bonus_gold, false, 0)
		-- Message Particle, has a bunch of options
		-- Similar format to the popup library by soldiercrabs: http://www.reddit.com/r/Dota2Modding/comments/2fh49i/floating_damage_numbers_and_damage_block_gold/
		local symbol = 0 -- "+" presymbol
		local color = Vector(255, 200, 33) -- Gold
		local lifetime = 2
		local digits = string.len(bonus_gold) + 1
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
		local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, target, player )
		ParticleManager:SetParticleControl(particle, 1, Vector(symbol, bonus_gold, symbol))
	    ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
	    ParticleManager:SetParticleControl(particle, 3, color)

	    EmitSoundOn("sounds/ui/coins.vsnd", target)
	end
end