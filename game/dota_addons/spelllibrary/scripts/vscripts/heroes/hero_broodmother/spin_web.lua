--[[Author: kritth
	Used by: Pizzalol
	Date: 16.01.2015.]]
function web_start_charge( keys )
	-- Only start charging at level 1
	if keys.ability:GetLevel() ~= 1 then return end

	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = keys.modifier_name --"modifier_web_stack_counter_datadriven"
	local maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_restore_time", ( ability:GetLevel() - 1 ) )
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	caster.web_charges = maximum_charges
	caster.start_charge = false
	caster.web_cooldown = 0.0
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, caster, maximum_charges )
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			-- Restore charge
			if caster.start_charge and caster.web_charges < maximum_charges then
				-- Calculate stacks
				local next_charge = caster.web_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= 3 then
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
			if caster.web_charges ~= maximum_charges then
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
	Author: kritth
	Date: 6.1.2015.
	Main: Check/Reduce charge, spawn dummy and cast the actual ability
]]
function web_fire( keys )
	local caster = keys.caster
	-- Reduce stack if more than 0 else refund mana
	if caster.web_charges > 0 then
		-- variables
		--[[local caster = keys.caster
		local target = keys.target_points[1]
		local ability = keys.ability
		local casterLoc = caster:GetAbsOrigin()
		local modifierName = "modifier_web_stack_counter_datadriven"
		local dummyModifierName = "modifier_web_dummy_datadriven"
		local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
		local dummy_duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) ) + 0.1
		local damage_delay = ability:GetLevelSpecialValueFor( "damage_delay", ( ability:GetLevel() - 1 ) ) + 0.1
		local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_web_launch.vpcf"
		local launch_sound_name = "Hero_Sniper.webShoot"
		
		-- Deplete charge
		local next_charge = caster.web_charges - 1
		if caster.web_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
			web_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.web_charges = next_charge
		
		-- Check if stack is 0, display ability cooldown
		if caster.web_charges == 0 then
			-- Start Cooldown from caster.web_cooldown
			ability:StartCooldown( caster.web_cooldown )
		else
			ability:EndCooldown()
		end
		
		-- Create particle at caster
		local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxLaunchIndex, 0, casterLoc )
		ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( casterLoc.x, casterLoc.y, 800 ) )
		StartSoundEvent( launch_sound_name, caster )
		
		-- Deal damage
		web_damage( caster, ability, target, damage_delay, dummyModifierName, dummy_duration )]]

		-- Deplete charge
		local next_charge = caster.web_charges - 1
		if caster.web_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
			web_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.web_charges = next_charge
	else
		keys.ability:RefundManaCost()
	end
end