--[[Sanity Eclipse
	Author: chrislotix
	Date: 08.01.2015.
	]]


function SanityEclipseDamage( keys )
	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local od_int = caster:GetIntellect()
	local target_int = target:GetIntellect()
	local mana = target:GetMana()
	local dmg_multiplier = ability:GetLevelSpecialValueFor("damage_multiplier", (ability:GetLevel() -1))
	local threshold = ability:GetLevelSpecialValueFor("int_threshold", (ability:GetLevel() -1))

	

	local damage_table = {} 

	damage_table.attacker = caster
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.ability = ability
	damage_table.victim = target

	--if od's int is lower than targets int then keep do nothing and keep targets mana as it is
	if od_int < target_int then
		target:SetMana(mana)
		--if the int difference is below or equal to threshold, burn 75% current mana and apply int difference * damage_modifier in magic damage
		elseif 
			(od_int - target_int) < threshold or (od_int - target_int) == threshold then
		target:SetMana(mana*0.25)
		damage_table.damage = (od_int - target_int) * dmg_multiplier
		ApplyDamage(damage_table)
		--if the int difference is bigger than than threshold then deal damage
		elseif 	(od_int - target_int) > threshold then
			damage_table.damage = (od_int - target_int)	* dmg_multiplier
			ApplyDamage(damage_table)
	end
end


	







	


	
