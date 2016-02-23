LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Applies the speed buff to the caster]]
function ApplyBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
	local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
	
	-- Checks if the ability is off cooldown and if the caster is attacking a target
	if target ~= null and ability:IsCooldownReady() then
		-- Checks if the target is an enemy
		if caster:GetTeam() ~= target:GetTeam() then
			local target_origin = target:GetAbsOrigin()
			local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
			ability.target = target
			-- Checks if the caster is in range of the target
			if distance >= min_distance and distance <= max_distance then
				-- Removes the 522 move speed cap
				caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
				-- Apply the speed buff
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_buff", {})
				-- Start cooldown on the passive
				ability:StartCooldown(cooldown)
			-- If the caster is too far from the target, we continuously check his distance until the attack command is canceled
			elseif distance >= max_distance then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_check_distance", {})
			end
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Checks if the caster is in range of the target]]
function DistanceCheck(keys)
	local caster = keys.caster
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
	local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
	
	-- Checks if the caster is still attacking the same target
	if caster:GetAggroTarget() == ability.target then
		local target_origin = ability.target:GetAbsOrigin()
		local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
		-- Checks if the caster is in range of the target
		if distance >= min_distance and distance <= max_distance then
			-- Removes the 522 move speed cap
			caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
			-- Apply the speed buff
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_buff", {})
			-- Start cooldown on the passive
			ability:StartCooldown(cooldown)
			caster:RemoveModifierByName("modifier_check_distance")
		end
	else
		caster:RemoveModifierByName("modifier_check_distance")
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Removes the speed buff if the attack command is canceled]]
function RemoveBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if target == null or target ~= ability.target then
		caster:RemoveModifierByName("modifier_speed_buff")
	end
end
