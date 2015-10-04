--[[Author: kritth,Pizzalol
	Date: 18.01.2015.
	Keeps track of the current charges and replenishes them accordingly]]
function web_start_charge( keys )
	-- Initial variables to keep track of different max charge requirements
	local caster = keys.caster
	local ability = keys.ability
	caster.web_maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
	caster.web_maximum_webs = ability:GetLevelSpecialValueFor("count", (ability:GetLevel() - 1))

	-- Initialize the current web count and the web table
	if caster.web_current_webs == nil then caster.web_current_webs = 0 end
	if caster.web_table == nil then caster.web_table = {} end

	-- Only start charging at level 1
	if keys.ability:GetLevel() ~= 1 then return end

	-- Variables	
	local modifierName = keys.modifier_name --"modifier_web_stack_counter_datadriven"
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_restore_time", ( ability:GetLevel() - 1 ) )
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, ability, 0 )
	caster.web_charges = caster.web_maximum_charges
	caster.start_charge = false
	caster.web_cooldown = 0.0
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, ability, caster.web_maximum_charges )
	
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
				caster:SetModifierStackCount( modifierName, ability, next_charge )
				
				-- Update stack
				caster.web_charges = next_charge
			end
			
			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.web_charges ~= caster.web_maximum_charges then
				caster.start_charge = true
				-- On level up refresh the modifier
				ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
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
	Author: kritth,Pizzalol
	Date: 18.01.2015.
	Main: Check/Reduce charge, spawn dummy and do web logic
]]
function spin_web( keys )
	local caster = keys.caster
	-- Reduce stack if more than 0 else refund mana
	if caster.web_charges > 0 then
		-- Variables
		local target = keys.target_points[1]
		local ability = keys.ability
		local player = caster:GetPlayerID()

		-- Modifiers and dummy abilities/modifiers
		local stack_modifier = keys.stack_modifier
		local dummy_modifier = keys.dummy_modifier
		local dummy_ability = keys.dummy_ability

		-- AbilitySpecial variables
		local maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_restore_time", ( ability:GetLevel() - 1 ) )

		-- Dummy
		local dummy = CreateUnitByName("npc_dummy_unit", target, false, caster, caster, caster:GetTeam())
		ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {})
		dummy:SetControllableByPlayer(player, true)
		
		if dummy_ability ~= nil then
			dummy:AddAbility(dummy_ability)
			dummy_ability = dummy:FindAbilityByName(dummy_ability)
			dummy_ability:SetLevel(1)
		end

		-- Save the web dummy in a table and increase the count
		table.insert(caster.web_table, dummy)
		caster.web_current_webs = caster.web_current_webs + 1

		-- If the maximum web limit is reached then remove the first web dummy
		if caster.web_current_webs > caster.web_maximum_webs then
			caster.web_table[1]:RemoveSelf()
			table.remove(caster.web_table, 1)
			caster.web_current_webs = caster.web_current_webs - 1
		end
		
		-- Deplete charge
		local next_charge = caster.web_charges - 1
		if caster.web_charges == maximum_charges then
			caster:RemoveModifierByName( stack_modifier )
			ability:ApplyDataDrivenModifier( caster, caster, stack_modifier, { Duration = charge_replenish_time } )
			web_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( stack_modifier, ability, next_charge )
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

--[[Author: Pizzalol
	Date: 18.01.2015.
	Finds the dummy in the table and then removes it]]
function spin_web_destroy( keys )
	local caster = keys.caster
	local caster_owner = caster:GetOwner()

	for i = 1, #caster_owner.web_table do
		if caster_owner.web_table[i] == caster then
			caster_owner.web_table[i]:RemoveSelf()
			table.remove(caster_owner.web_table, i)
			caster_owner.web_current_webs = caster_owner.web_current_webs - 1
			return
		end
	end
end

--[[Author: Pizzalol
	Date: 18.01.2015.
	Acts as an aura, applying the aura modifiers to the valid targets]]
function spin_web_aura( keys )
	local ability = keys.ability
	local caster = keys.caster	
	local target = keys.target

	-- Owner variables
	local caster_owner = caster:GetPlayerOwner()
	local target_owner = target:GetPlayerOwner()

	-- Units
	local unit_spiderling = keys.unit_spiderling
	local unit_spiderite = keys.unit_spiderite
	local all_units = ability:GetLevelSpecialValueFor("all_units", (ability:GetLevel() - 1))

	-- Modifiers
	local aura_modifier = keys.aura_modifier
	local pathing_modifier = keys.pathing_modifier
	local pathing_fade_modifier = keys.pathing_fade_modifier
	local invis_modifier = keys.invis_modifier
	local invis_fade_modifier = keys.invis_fade_modifier

	-- Checking if it should apply the aura to all player controlled units
	if all_units == 1 then all_units = true else all_units = false end

	if all_units then
		if target_owner == caster_owner then
			-- Aura modifier
			ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {})
			-- If it doesnt have the fade pathing modifier or the pathing modifier then apply it
			if not target:HasModifier(pathing_fade_modifier) and not target:HasModifier(pathing_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, pathing_modifier, {}) 
			end

			-- If it doesnt have the fade invis modifier or the invis modifier then apply it
			if not target:HasModifier(invis_modifier) and not target:HasModifier(invis_fade_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, invis_modifier, {})
			end
		end
	else
		if target_owner == caster_owner and target == caster or target:GetName() == unit_spiderite or target:GetName() == unit_spiderling then
			-- Aura modifier
			ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {})
			-- If it doesnt have the fade pathing modifier or the pathing modifier then apply it
			if not target:HasModifier(pathing_fade_modifier) and not target:HasModifier(pathing_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, pathing_modifier, {}) 
			end

			-- If it doesnt have the fade invis modifier or the invis modifier then apply it
			if not target:HasModifier(invis_modifier) and not target:HasModifier(invis_fade_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, invis_modifier, {})
			end
		end
	end
end