--[[Author: Pizzalol
	Date: 27.09.2015.
	Creates spirits and sets their stats according to Quas and Exort levels]]
function ForgeSpirit( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin() 
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local quas_level = caster:FindAbilityByName("invoker_quas_datadriven"):GetLevel() - 1
	local exort_level = caster:FindAbilityByName("invoker_exort_datadriven"):GetLevel() - 1

	-- Ability variables
	local spirit_damage = ability:GetLevelSpecialValueFor("spirit_damage", exort_level) 
	local spirit_hp = ability:GetLevelSpecialValueFor("spirit_hp", exort_level) 
	local spirit_armor = ability:GetLevelSpecialValueFor("spirit_armor", exort_level) 
	local spirit_attack_range = ability:GetLevelSpecialValueFor("spirit_attack_range", quas_level) 
	local spirit_mana = ability:GetLevelSpecialValueFor("spirit_mana", quas_level) 
	local spirit_duration = ability:GetLevelSpecialValueFor("spirit_duration", quas_level) 
	local spirit_count_quas = ability:GetLevelSpecialValueFor("spirit_count", quas_level)
	local spirit_count_exort = ability:GetLevelSpecialValueFor("spirit_count", exort_level)

	-- Modifiers
	local positive_armor = keys.positive_armor
	local negative_armor = keys.negative_armor
	local attack_range = keys.attack_range

	-- Calculate the number of spirits
	local spirit_count
	if spirit_count_quas < spirit_count_exort then
		spirit_count = spirit_count_quas
	else
		spirit_count = spirit_count_exort
	end

	-- Spirit cleanup
	-- Initialize the unit table to keep track of the spirits
	if not ability.forged_spirits then
		ability.forged_spirits = {}
	end

	-- Kill the old spirits
	for k,v in pairs(ability.forged_spirits) do
		if v and IsValidEntity(v) then 
			v:ForceKill(false)
		end
	end

	-- Start a clean unit table
	ability.forged_spirits = {}

	-- Create new spirits
	for i=1,spirit_count do
		local forged_spirit = CreateUnitByName("npc_dota_invoker_forged_spirit", caster_location + RandomVector(100), true, caster, caster, caster:GetTeamNumber())
		forged_spirit:SetControllableByPlayer(player, true)
		forged_spirit:AddNewModifier(caster, ability, "modifier_phased", {duration = 0.03})

		-- Remove the base ability and add datadriven molten strike
		forged_spirit:RemoveAbility("forged_spirit_melting_strike")
		forged_spirit:AddAbility("forged_spirit_melting_strike_datadriven") 
		forged_spirit:FindAbilityByName("forged_spirit_melting_strike_datadriven"):SetLevel(1)

		-- Set the damage
		forged_spirit:SetBaseDamageMin(spirit_damage) 
		forged_spirit:SetBaseDamageMax(spirit_damage)

		-- Set the health and mana
		--forged_spirit:SetManaGain(0)
		--forged_spirit:CreatureLevelUp(1)
		forged_spirit:SetBaseMaxHealth(spirit_hp)

		-- Set the armor
		-- Check if we have to add or reduce armor and then apply the positive or negative modifier
		local armor = spirit_armor - forged_spirit:GetPhysicalArmorBaseValue() 
		if armor > 0 then
			ability:ApplyDataDrivenModifier(caster, forged_spirit, positive_armor, {}) 
			forged_spirit:SetModifierStackCount(positive_armor, ability, armor)
		elseif armor < 0 then
			ability:ApplyDataDrivenModifier(caster, forged_spirit, negative_armor, {})
			forged_spirit:SetModifierStackCount(negative_armor, ability, armor * -1)
		end

		-- Set the attack range
		ability:ApplyDataDrivenModifier(caster, forged_spirit, attack_range, {}) 
		forged_spirit:SetModifierStackCount(attack_range, ability, spirit_attack_range)

		-- Set the spirit duration
		forged_spirit:AddNewModifier(caster, ability, "modifier_kill", {duration = spirit_duration})

		-- Track the spirit
		table.insert(ability.forged_spirits, forged_spirit)
	end
end