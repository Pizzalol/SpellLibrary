--[[Author: kritth
	Used by: Pizzalol
	Date: 6.01.2015.
	If you level up while having max charges then there will be a visual bug on the modifier for the duration of recharge time]]
function web_start_charge( keys )
	-- Initial variables to keep track of different max charge requirements
	local caster = keys.caster
	local ability = keys.ability
	caster.web_maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
	-- Only start charging at level 1
	if keys.ability:GetLevel() ~= 1 then return end

	-- Variables	
	local modifierName = keys.modifier_name --"modifier_web_stack_counter_datadriven"
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_restore_time", ( ability:GetLevel() - 1 ) )
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	caster.web_charges = caster.web_maximum_charges
	caster.start_charge = false
	caster.web_cooldown = 0.0
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, caster, caster.web_maximum_charges )
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			-- Restore charge
			if caster.start_charge and caster.web_charges < caster.web_maximum_charges then
				-- Calculate stacks
				local next_charge = caster.web_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= caster.web_maximum_charges then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
					web_start_cooldown( caster, charge_replenish_time )
				else
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
					caster.start_charge = false
				end
				caster:SetModifierStackCount( modifierName, caster, next_charge )
				
				-- Update stack
				caster.web_charges = next_charge
			end
			
			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.web_charges ~= caster.web_maximum_charges then
				caster.start_charge = true
				return charge_replenish_time
			else
				return 0.5
			end
		end
	)
end




--[[
	Author: kritth
	Used by: Pizzalol
	Date: 6.1.2015.
	Helper: Create timer to track cooldown
]]
function web_start_cooldown( caster, charge_replenish_time )
	caster.web_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.web_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.web_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end

--[[
	Author: kritth/Pizzalol
	Date: 16.1.2015.
	Main: Check/Reduce charge, spawn dummy and cast the actual ability
]]
function spin_web( keys )
	local caster = keys.caster
	-- Reduce stack if more than 0 else refund mana
	if caster.web_charges > 0 then
		-- variables
		--local caster = keys.caster
		local target = keys.target_points[1]
		local ability = keys.ability
		--local casterLoc = caster:GetAbsOrigin()
		local stack_modifier = keys.stack_modifier
		local dummy_modifier = keys.dummy_modifier
		local maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_restore_time", ( ability:GetLevel() - 1 ) )
		local max_webs = ability:GetLevelSpecialValueFor("count", (ability:GetLevel() - 1))

		-- Dummy
		local dummy = CreateUnitByName("npc_dummy_blank", target, false, caster, caster, caster:GetTeam())
		ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {})
		
		-- Deplete charge
		local next_charge = caster.web_charges - 1
		if caster.web_charges == maximum_charges then
			caster:RemoveModifierByName( stack_modifier )
			ability:ApplyDataDrivenModifier( caster, caster, stack_modifier, { Duration = charge_replenish_time } )
			web_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( stack_modifier, caster, next_charge )
		caster.web_charges = next_charge
		
		-- Check if stack is 0, display ability cooldown
		if caster.web_charges == 0 then
			-- Start Cooldown from caster.web_cooldown
			ability:StartCooldown( caster.web_cooldown )
		else
			ability:EndCooldown()
		end
	else
		keys.ability:RefundManaCost()
	end
end

function spin_web_aura( keys )
	local ability = keys.ability
	local caster = keys.caster	
	local target = keys.target

	-- Owner variables
	local caster_owner = caster:GetPlayerOwner()
	local target_owner = target:GetPlayerOwner()

	-- Ability variables
	local unit_spiderling = keys.unit_spiderling
	local unit_spiderite = keys.unit_spiderite
	local all_units = ability:GetLevelSpecialValueFor("all_units", (ability:GetLevel() - 1))

	-- Modifiers
	local aura_modifier = keys.aura_modifier
	local pathing_modifier = keys.pathing_modifier
	local pathing_fade_modifier = keys.pathing_fade_modifier
	--print("Running aura")


	if all_units == 1 then all_units = true else all_units = false end

	if all_units then
		if target_owner == caster_owner then
			ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {})
			-- add if not has fade modifier or invis modifier then add path modifier
			if not target:HasModifier(pathing_fade_modifier) and not target:HasModifier(pathing_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, pathing_modifier, {}) 
			end
		end
	else
		if target_owner == caster_owner and target == caster or target == unit_spiderite or target == unit_spiderling then
			ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {})
			if not target:HasModifier(pathing_fade_modifier) and not target:HasModifier(pathing_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, pathing_modifier, {}) 
			end
		end
	end
end