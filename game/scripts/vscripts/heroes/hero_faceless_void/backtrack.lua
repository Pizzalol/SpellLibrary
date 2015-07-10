
healthTable = healthTable or {}

--[[Author: Pizzalol
	Date: 06.01.2015.
	Keeps track of the casters health]]
function BacktrackHealth( keys )
	local caster = keys.caster

	healthTable[caster] = healthTable[caster] or {}

	if healthTable[caster].old == nil or healthTable[caster].new == nil then
		healthTable[caster].old = caster:GetMaxHealth()
		healthTable[caster].new = caster:GetMaxHealth()
	end

	healthTable[caster].old = healthTable[caster].new
	healthTable[caster].new = caster:GetHealth()
end

--[[Author: Pizzalol
	Date: 06.01.2015.
	Negates incoming damage]]
function BacktrackHeal( keys )
	local caster = keys.caster

	caster:SetHealth(healthTable[caster].old)
end