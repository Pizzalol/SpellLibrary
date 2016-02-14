--[[Author: YOLOSPAGHETTI
	Date: February 7, 2016
	Adds time dilation duration to cooldown of all target's abilities currently on cooldown and applies debuff]]
function CooldownFreeze(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	ability.time_cast = Time()
	
	local cooldown_time = ability:GetLevelSpecialValueFor("duration", ability_level)
	local move_speed_slow = ability:GetLevelSpecialValueFor("move_speed_slow", ability_level)/100
	local attack_speed_slow = ability:GetLevelSpecialValueFor("attack_speed_slow", ability_level)
	local frozen_abilities = 0
	
	-- Adds spell duration to cooldowns of all of the target's abilities currently on cooldown
	for i=0, 16 do
		if target:GetAbilityByIndex(i) ~= null then
			local cd = target:GetAbilityByIndex(i):GetCooldownTimeRemaining()
			if cd > 0 then
				frozen_abilities = frozen_abilities + 1
				target:GetAbilityByIndex(i):StartCooldown(cd + cooldown_time)
			end
		end
	end
	
	-- Gives the target instances of the debuff based on their frozen abilities
	if frozen_abilities > 0 then
		for i=0, frozen_abilities do
			ability:ApplyDataDrivenModifier( caster, target, "modifier_time_dilation_slow", { Duration = cooldown_time } )
		end
	end
	
	-- Adds stacks to the aesthetic modifier
	target:SetModifierStackCount("modifier_time_dilation_cooldown_freeze", caster, frozen_abilities)
end

--[[Author: YOLOSPAGHETTI
	Date: February 7, 2016
	Adds remaining time dilation duration to cooldown of the ability the target cast and applies debuff]]
function SlowCooldown(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local cooldown_time = ability:GetLevelSpecialValueFor("duration", ability_level)
	local time_left = cooldown_time - (Time() - ability.time_cast)
	local stacks = 0
	local is_ability = 0
	
	-- Gets stacks of the aesthetic modifier
	if target:HasModifier("modifier_time_dilation_slow") then
		stacks = target:GetModifierStackCount("modifier_time_dilation_cooldown_freeze", caster)
	end
	
	-- Finds the ability that caused the event trigger by checking if the cooldown is equal to the full cooldown
	for i=0, 15 do
		if target:GetAbilityByIndex(i) ~= null then
			local cd = target:GetAbilityByIndex(i):GetCooldownTimeRemaining()
			local full_cd = target:GetAbilityByIndex(i):GetCooldown(target:GetAbilityByIndex(i):GetLevel()-1)
			-- There is a delay after the ability cast event and before the ability goes on cooldown
			-- If the ability is on cooldown, not already frozen, and the cooldown is within a small buffer of the full cooldown
			-- We add the remaining time dilation duration to it
			if cd > 0 and  full_cd - cd > 0 and full_cd - cd < 0.04 then
				is_ability = 1
				target:GetAbilityByIndex(i):StartCooldown(cd + time_left)
			end
		end
	end
	
	-- If an ability was frozen, we add one instance of the debuff to the target and add a stack to the aesthetic modifier
	if is_ability == 1 then
		ability:ApplyDataDrivenModifier( caster, target, "modifier_time_dilation_slow", { Duration = time_left } )
		target:SetModifierStackCount("modifier_time_dilation_cooldown_freeze", caster, stacks + 1)
	end
end
