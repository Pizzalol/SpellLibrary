--[[
	Author: Noya
	Date: April 5, 2015
	Damages the target based on the mana spent
	TODO: Pray this damage takes place before the spell goes off
]]
function NetherWardZap( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local AbilityDamageType = ability:GetAbilityDamageType()

	local mana_spent
	if target.OldMana then
		mana_spent = target.OldMana
	end

	if mana_spent then
		local mana_multiplier = ability:GetLevelSpecialValueFor("mana_multiplier", ability:GetLevel() - 1 )
		local zap_damage = mana_spent * mana_multiplier

		ApplyDamage({ victim = target, attacker = caster, damage = zap_damage, damage_type = AbilityDamageType })

		-- TODO: Zap particle and sound
	else
		print("ERROR, no mana data")
	end
end

--[[
	Author: Noya
	Date: April 5, 2015
	"Nether Ward has 4 HP. Heroes can attack it for 1 damage, while non-hero units deal 0.25 damage."
	It actually has 16 in npc_units.txt, probably because 0.25 damage doesn't show in the UI.
]]
function NetherWardAttacked( event )
	local target = event.target -- the ward
	local attacker = event.attacker
	local damage = event.Damage 

	local attack_counter = target.attack_counter

	if attacker:IsRealHero() then
		attack_counter = target.attack_counter - 4
	else
		attack_counter = target.attack_counter - 1
	end

	-- Adjust the health of the ward
	-- TODO: Check if this should be /4, and if the Damage is still dealt
	target:SetHealth(attack_counter)
end

--[[
	Author: Noya
	Date: April 5, 2015
	Get a point at a distance in front of the caster
]]
function GetFrontPoint( event )
	local caster = event.caster
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = event.Distance
	
	local front_position = origin + fv * distance
	local result = {}
	table.insert(result, front_position)

	return result
end

-- Store all the targets mana and initialize the attack counter of the ward
function NetherWardStart( event )
	local target = event.target
	target.attack_counter = 16


	local targets = event.target_entities
	for _,hero in pairs(targets) do
		target.OldMana = target:GetMana()
	end
end

-- Continuously keeps track of all the targets mana
function NetherWardMana( event )
	local targets = event.target_entities

	for _,hero in pairs(targets) do
		target.OldMana = target:GetMana()
	end
end