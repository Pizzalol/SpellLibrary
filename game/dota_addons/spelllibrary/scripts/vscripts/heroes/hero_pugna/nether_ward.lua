--[[
	Author: Noya
	Date: April 5, 2015
	Damages the target based on the mana spent
]]
function NetherWardZap( event )
	local caster = event.caster
	local target = event.unit -- The unit that spent mana
	local ability = event.ability
	local ward = ability.nether_ward -- Keep track of the ward to attach the particle
	local AbilityDamageType = ability:GetAbilityDamageType()

	local mana_spent
	if target.OldMana then
		mana_spent = target.OldMana - target:GetMana()
	end

	if mana_spent and mana_spent > 0 then
		local mana_multiplier = ability:GetLevelSpecialValueFor("mana_multiplier", ability:GetLevel() - 1 )
		local zap_damage = mana_spent * mana_multiplier

		ApplyDamage({ victim = target, attacker = caster, damage = zap_damage, damage_type = AbilityDamageType })
		print("Dealt "..zap_damage.." = "..mana_spent.." * "..mana_multiplier)

		local attackName = "particles/units/heroes/hero_pugna/pugna_ward_attack.vpcf" -- There are some light/medium/heavy unused versions
		local attack = ParticleManager:CreateParticle(attackName, PATTACH_ABSORIGIN_FOLLOW, ward)
		ParticleManager:SetParticleControl(attack, 1, target:GetAbsOrigin())

		target:EmitSound("Hero_Pugna.NetherWard.Target")
		caster:EmitSound("Hero_Pugna.NetherWard.Attack")
	end
end

--[[
	Author: Noya
	Date: April 5, 2015
	"Nether Ward has 4 HP. Heroes can attack it for 1 damage, while non-hero units deal 0.25 damage."
]]
function NetherWardAttacked( event )
	local target = event.unit -- the ward
	local attacker = event.attacker
	local damage = event.Damage
	local ability = event.ability
	local hero_attack_damage = ability:GetLevelSpecialValueFor("hero_attack_damage", ability:GetLevel() - 1 )

	print(target:GetEntityIndex(), target.attack_counter)

	if attacker:IsRealHero() then
		target.attack_counter = target.attack_counter - hero_attack_damage
	else
		target.attack_counter = target.attack_counter - 1
	end

	-- Adjust the health of the ward
	-- TODO: Check if this should be /4, and if the Damage is still dealt
	target:SetHealth(target.attack_counter)
	print("SetHealth of "..target:GetUnitName().." at "..target.attack_counter)
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
	local ability = event.ability
	local attacks_to_destroy = ability:GetLevelSpecialValueFor("attacks_to_destroy", ability:GetLevel() - 1 )
	target.attack_counter = attacks_to_destroy

	-- This is needed to attach the particle attack. Should be a table if we were dealing with possible multiple wards
	ability.nether_ward = target

	print(target:GetEntityIndex(),target.attack_counter)

	local targets = event.target_entities
	for _,hero in pairs(targets) do
		target.OldMana = target:GetMana()
	end
end

-- Continuously keeps track of all the targets mana
function NetherWardMana( event )
	local targets = event.target_entities

	for _,hero in pairs(targets) do
		hero.OldMana = hero:GetMana()
	end
end