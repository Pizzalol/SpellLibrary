
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

--[[Author: Pizzalol
	Date: 06.01.2015.
	Checks if the attack would have been lethal
	If yes then it removes the backtrack modifier and applies damage]]
function BacktrackLethal( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local incoming_damage = keys.incoming_damage
	local modifier = keys.modifier_name

	if incoming_damage >= healthTable[caster].old then
		caster:RemoveModifierByName(modifier)

		local damage_table = {}

		damage_table.attacker = attacker
		damage_table.victim = caster
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.damage = incoming_damage

		ApplyDamage(damage_table)

		-- For some odd cases where the target would be still alive after taking lethal damage
		Timers:CreateTimer(0.01, function() 
			if target:IsAlive() then
				caster:ApplyDataDrivenModifier(caster, caster, modifier, {})
			end
		end)
	end
end