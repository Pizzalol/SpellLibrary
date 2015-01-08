--[[Sanity Eclipse
	Author: chrislotix
	Date: 08.01.2015.
	NOTE: Need to fix the mana burn when the target has more int than the caster]]


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
	damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	damage_table.ability = ability
	damage_table.victim = target

	--if the int difference is below or equal to threshold, burn 75% current mana and apply int difference * damage_modifier in magic damage
	if (od_int - target_int) < threshold or (od_int - target_int) == threshold then
		target:SetMana(mana*0.25)
		damage_table.damage = (od_int - target_int) * dmg_multiplier
		ApplyDamage(damage_table)
		--if the int difference is bigger than than threshold then deal damage
		elseif (od_int - target_int) > threshold then
			damage_table.damage = (od_int - target_int)	* dmg_multiplier
			ApplyDamage(damage_table)
		end


	print("ebin")

end


	--od info
	--if od_int - target_int > threshold = deal damage
	--if od_int - target_int == threshold = deal damage
	--if od_int - target_int < threshold = mana burn + deal damage done
	--if od_int < target_int == do nothing







	


	
