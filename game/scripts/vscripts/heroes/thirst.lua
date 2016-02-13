--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Adds the thirst buff to the caster and vision debuff to the target if the target is below the required threshold]]
function AddThirst(keys)
	local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
	local sight_modifier = "modifier_thirst_debuff_datadriven"
	local buff_modifier = "modifier_thirst_buff"
	local buff_visual = "modifier_thirst_visual"
	local healthPercentage = target:GetHealth() / target:GetMaxHealth()
	local buff_threshold = ability:GetLevelSpecialValueFor( "buff_threshold_pct", ability:GetLevel() - 1 )/100
	local visibility_threshold = ability:GetLevelSpecialValueFor( "visibility_threshold_pct", ability:GetLevel() - 1 )/100
	
	-- Removes the 522 move speed cap
	if caster:HasModifier("modifier_bloodseeker_thirst") == false then
		caster:AddNewModifier(caster, nil, "modifier_bloodseeker_thirst", {})
	end
	
	-- Stacks of the thirst buff provided by our current target
	if target.stacks == nil then
		target.stacks = 0
	end
	
	-- The stacks on the buff currently
	local previous_stacks
	if caster:HasModifier(buff_modifier) then
		previous_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	else
		previous_stacks = 0
	end
	
	-- Target below 75% hp and alive
	if target:IsAlive() and healthPercentage <= buff_threshold then
		-- Target below 25% hp
		if healthPercentage < visibility_threshold then
			-- Apply visibility modifier (true sight)
			ability:ApplyDataDrivenModifier(caster, target, sight_modifier, {})
			-- Ensure the buff does not get stacks for missing hp below 25%
			healthPercentage = visibility_threshold
		end
		-- Apply the buff to the caster
		if caster:HasModifier(buff_modifier) == false then
			ability:ApplyDataDrivenModifier(caster, caster, buff_modifier, {})
			ability:ApplyDataDrivenModifier(caster, caster, buff_visual, {})
		end
		-- Adds the new stacks to the thirst buff
		local new_stacks = math.floor((buff_threshold - healthPercentage)*100)
		print("previous")
		print(previous_stacks)
		print("new_stacks")
		print(new_stacks)
		print("target")
		print(target.stacks)
		caster:SetModifierStackCount(buff_modifier, ability, new_stacks + previous_stacks - target.stacks)
		target.stacks = new_stacks
	else
		-- Remove all stacks the target provided to the thirst buff
		caster:SetModifierStackCount(buff_modifier, ability, previous_stacks - target.stacks)
		target.stacks = 0
		-- If no other targets are providing stacks to the buff, remove it
		if caster:GetModifierStackCount(buff_modifier, ability) == 0 then
			caster:RemoveModifierByName(buff_modifier)
			caster:RemoveModifierByName(buff_visual)
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Removes the thirst buff stacks from the caster and vision debuff from the target if the target is above the required threshold]]
function RemoveThirst(keys)
	local target = keys.unit -- Target
	local caster = keys.caster -- Hero
	local ability = keys.ability
	local sight_modifier = "modifier_thirst_debuff_datadriven"
	local buff_modifier = "modifier_thirst_buff"
	local buff_visual = "modifier_thirst_visual"
	local healthPercentage = target:GetHealth() / target:GetMaxHealth()
	local buff_threshold = ability:GetLevelSpecialValueFor( "buff_threshold_pct", ability:GetLevel() - 1 )/100
	local visibility_threshold = ability:GetLevelSpecialValueFor( "visibility_threshold_pct", ability:GetLevel() - 1 )/100
	
	-- Stacks of the thirst buff provided by our current target
	if target.stacks == nil then
		target.stacks = 0
	end
	
	-- The stacks on the buff currently
	local previous_stacks
	if caster:HasModifier(buff_modifier) then
		previous_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	else
		previous_stacks = 0
	end
	
	-- If target is above 25% hp, remove the true sight
	if healthPercentage >= visibility_threshold then
		if target:HasModifier(sight_modifier) then
			target:RemoveModifierByName(sight_modifier)
		end
	end
	
	-- Target is above 75% hp
	if healthPercentage > buff_threshold then
		if caster:HasModifier(buff_modifier) then
			-- Remove all stacks the target provided to the thirst buff
			caster:SetModifierStackCount(buff_modifier, ability, previous_stacks - target.stacks)
			target.stacks = 0
			-- If no other targets are providing stacks to the buff, remove it
			if caster:GetModifierStackCount(buff_modifier, ability) == 0 then
				caster:RemoveModifierByName(buff_modifier)
				caster:RemoveModifierByName(buff_visual)
			end
		end
	else
		-- Ensure the buff does not get stacks for missing hp below 25%
		if healthPercentage < visibility_threshold then
			healthPercentage = visibility_threshold
		end
		-- Adds the new stacks to the thirst buff
		local new_stacks =	math.floor((buff_threshold - healthPercentage)*100)
		print("previous")
		print(previous_stacks)
		print("new_stacks")
		print(new_stacks)
		print("target")
		print(target.stacks)
		caster:SetModifierStackCount(buff_modifier, ability, new_stacks + previous_stacks - target.stacks)
		target.stacks = new_stacks
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Gives a 10 unit radius circle of vision around the target for the caster's team]]
function GiveVision(keys)
	caster = keys.caster
	target = keys.target
	
	AddFOWViewer(caster:GetTeam(), target:GetAbsOrigin(), 10, 0.01, false)
end
