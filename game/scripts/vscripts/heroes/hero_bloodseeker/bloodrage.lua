--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Heals the hero with bloodrage if they kill a unit, and heals their attacker if they are killed]]
function HealKiller(keys)
	local caster = keys.caster
	local target = keys.unit
	local attacker = keys.attacker
	local ability = keys.ability
	local health_bonus_pct = ability:GetLevelSpecialValueFor("health_bonus_pct", (ability:GetLevel() -1))/100
	
	if caster:IsAlive() then
		local target_health = target:GetMaxHealth()
		local heal = target_health * health_bonus_pct
		
		caster:Heal(heal, caster)
	else
		local caster_health = caster:GetMaxHealth()
		local heal = caster_health * health_bonus_pct
		
		attacker:Heal(heal, caster)
	end
end
