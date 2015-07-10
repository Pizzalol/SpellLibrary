--[[Author: Pizzalol
	Date: 20.01.2015.
	Initializes the starting position of the target and does the initial mana check]]
function ManaLeakInit( keys )
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local target_mana = target:GetMana()
	local ability = keys.ability

	print(target_mana)
	-- Extra variables
	local sound = keys.sound
	local modifier = keys.modifier
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() - 1))

	-- Initial mana check
	if target_mana <= 0 then
		target:RemoveModifierByName(modifier)
		target:AddNewModifier(caster, nil, "modifier_stunned", {duration = stun_duration})
		EmitSoundOn(sound, target)
	end

	-- Setting the starting position
	target.position = target_location
end

--[[Author: Pizzalol
	Date: 20.01.2015.
	Compares the new and previous position on each check
	Checks if the target moved more than the leash range, if it didnt then it drains mana
	and checks if the mana is empty, if true then it applies the stun]]
function ManaLeak( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- Variables
	local target_max_mana = target:GetMaxMana()
	local target_current_mana = target:GetMana()
	-- How much of the mana pool is reduced per 100 units
	local mana_pct_per_100 = ability:GetLevelSpecialValueFor("mana_leak_pct", (ability:GetLevel() - 1)) / 100
	-- How much of the mana pool is lost per 1 unit
	local mana_pct = mana_pct_per_100 / 100
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() - 1))
	-- The limit until which we consider draining mana, if the change is greater than this then dont do anything
	local leash_range_check = ability:GetLevelSpecialValueFor("leash_range_check", (ability:GetLevel() - 1))

	-- Extra variables
	local sound = keys.sound
	local modifier = keys.modifier

	-- Calculations
	local old_position = target.position
	local new_position = target:GetAbsOrigin()
	local distance = (new_position - old_position):Length2D()
	-- Calculating the mana loss
	local mana_reduction = target_max_mana * distance * mana_pct

	-- Checks if the distance is greater than the leash, if not then it reduces mana and
	-- checks if the target still has mana, if not then it stuns the target and plays the corresponding sound
	if distance < leash_range_check and distance ~= 0 then
		target:ReduceMana(mana_reduction)
		if target_current_mana <= mana_reduction then
			target:RemoveModifierByName(modifier)
			target:AddNewModifier(caster, nil, "modifier_stunned", {duration = stun_duration})
			EmitSoundOn(sound, target)
		end
	end

	-- Saves the new position for the next check
	target.position = new_position
end