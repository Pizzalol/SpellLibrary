--[[Author: Pizzalol
	Date: 14.02.2016.
	Keeps track of the casters health]]
function BacktrackHealth( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability.caster_hp_old = ability.caster_hp_old or caster:GetMaxHealth()
	ability.caster_hp = ability.caster_hp or caster:GetMaxHealth()

	ability.caster_hp_old = ability.caster_hp
	ability.caster_hp = caster:GetHealth()
end

--[[Author: Pizzalol
	Date: 14.02.2016.
	Negates incoming damage]]
function BacktrackHeal( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SetHealth(ability.caster_hp_old)
end