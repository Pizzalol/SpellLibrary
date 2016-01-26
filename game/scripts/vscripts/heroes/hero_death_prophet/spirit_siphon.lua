--[[Author: Pizzalol
	Date: 26.01.2016.
	Checks if the target is being siphoned from already]]
function SpiritSiphonCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local modifier = keys.modifier

	-- Stop the caster from casting if the target has the modifier already
	if target:HasModifier(modifier) then
		caster:Interrupt()
	end
end

--[[Author: Pizzalol
	Date: 26.01.2016.
	Checks for leash range, deals damage to the target and heals the caster]]
function SpiritSiphon( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier

	local think_interval = ability:GetLevelSpecialValueFor("think_interval",ability_level)
	local base_damage = ability:GetLevelSpecialValueFor("damage",ability_level)
	local pct_damage = ability:GetLevelSpecialValueFor("damage_pct",ability_level)
	local buffer = ability:GetLevelSpecialValueFor("siphon_buffer",ability_level)
	local leash_range = ability:GetCastRange() + buffer

	-- If the leash range is broken then remove the modifier, otherwise deal damage to the target and heal the caster
	if (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() < leash_range then
		local tDamage_table = {}
		tDamage_table.attacker = caster
		tDamage_table.victim = target
		tDamage_table.damage = (base_damage + target:GetMaxHealth() * pct_damage / 100)*think_interval
		tDamage_table.damage_type = ability:GetAbilityDamageType()

		ApplyDamage(tDamage_table)
		caster:Heal(tDamage_table.damage,caster)
	else
		target:RemoveModifierByName(modifier)
	end
end

--[[Author: Pizzalol
	Date: 26.01.2016.
	Applies the siphon modifier to the target if there are charges available]]
function SpiritSiphonCast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ability_level = ability:GetLevel() - 1

	local modifier = keys.modifier
	local stack_modifier = keys.stack_modifier
	local sound = keys.sound
	local duration = ability:GetLevelSpecialValueFor("haunt_duration",ability_level)

	if caster.siphon_charges > 0 then
		ability:ApplyDataDrivenModifier(caster,target,modifier,{duration = duration})
		EmitSoundOn(sound,caster)

		local maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ability_level )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_restore_time", ability_level )

		-- Deplete charge
		local next_charge = caster.siphon_charges - 1
		if caster.siphon_charges == maximum_charges then
			caster:RemoveModifierByName( stack_modifier )
			ability:ApplyDataDrivenModifier( caster, caster, stack_modifier, { Duration = charge_replenish_time } )
			siphon_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( stack_modifier, ability, next_charge )
		caster.siphon_charges = next_charge
		
		-- Check if stack is 0, display ability cooldown
		if caster.siphon_charges == 0 then
			-- Start Cooldown from caster.siphon_cooldown
			ability:StartCooldown( caster.siphon_cooldown )
		else
			ability:EndCooldown()
		end
	else
		ability:RefundManaCost()
	end
end

--[[Author: kritth,Pizzalol
	Date: 18.01.2015.
	Keeps track of the current charges and replenishes them accordingly]]
function siphon_start_charge( keys )
	-- Initial variables to keep track of different max charge requirements
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	caster.siphon_maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability_level ) )

	-- Only start charging at level 1
	if keys.ability:GetLevel() ~= 1 then return end

	-- Variables	
	local modifierName = keys.modifier_name --"modifier_spirit_siphon_counter_datadriven"
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_restore_time", ( ability_level ) )
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, ability, 0 )
	caster.siphon_charges = caster.siphon_maximum_charges
	caster.start_charge = false
	caster.siphon_cooldown = 0.0
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, ability, caster.siphon_maximum_charges )
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			-- Restore charge
			if caster.start_charge and caster.siphon_charges < caster.siphon_maximum_charges then
				-- Calculate stacks
				local next_charge = caster.siphon_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= caster.siphon_maximum_charges then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
					siphon_start_cooldown( caster, charge_replenish_time )
				else
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
					caster.start_charge = false
				end
				caster:SetModifierStackCount( modifierName, ability, next_charge )
				
				-- Update stack
				caster.siphon_charges = next_charge
			end
			
			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.siphon_charges ~= caster.siphon_maximum_charges then
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
function siphon_start_cooldown( caster, charge_replenish_time )
	caster.siphon_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.siphon_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.siphon_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end