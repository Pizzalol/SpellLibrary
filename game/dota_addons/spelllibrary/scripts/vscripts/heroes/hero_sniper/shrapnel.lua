--[[
	Author: kritth
	Date: 6.1.2015.
	Init: Create a timer to start charging charges
]]
function shrapnel_start_charge( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_shrapnel_stack_counter_datadriven"
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	charge_replenish_time = 5.0
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	caster.shrapnel_charges = 0
	caster.start_charge = true
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			-- Restore charge
			if caster.start_charge and caster.shrapnel_charges < maximum_charges then
				local next_charge = caster.shrapnel_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= 3 then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
				else
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
					caster.start_charge = false
				end
				caster:SetModifierStackCount( modifierName, caster, next_charge )
				caster.shrapnel_charges = next_charge
			end
			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.shrapnel_charges ~= maximum_charges then
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
	Main: Check/Reduce charge, spawn dummy and cast the actual ability
]]
function shrapnel_fire( keys )
	-- Reduce stack if more than 0 else refund mana
	if keys.caster.shrapnel_charges > 0 then
		-- variables
		local caster = keys.caster
		local target = keys.target_points[1]
		local ability = keys.ability
		local casterLoc = caster:GetAbsOrigin()
		local modifierName = "modifier_shrapnel_stack_counter_datadriven"
		local dummyModifierName = "modifier_shrapnel_dummy_datadriven"
		local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
		local dummy_duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) ) + 0.1
		local damage_delay = ability:GetLevelSpecialValueFor( "damage_delay", ( ability:GetLevel() - 1 ) ) + 0.1
		local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
		local launch_sound_name = "Hero_Sniper.ShrapnelShoot"
		
		charge_replenish_time = 5.0
		
		-- Deplete charge
		local next_charge = caster.shrapnel_charges - 1
		if caster.shrapnel_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.shrapnel_charges = next_charge
		
		-- Create particle at caster
		local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxLaunchIndex, 0, casterLoc )
		ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( casterLoc.x, casterLoc.y, 800 ) )
		ParticleManager:ReleaseParticleIndex( fxLaunchIndex )
		StartSoundEvent( launch_sound_name, caster )
		
		-- Create delay damage
		Timers:CreateTimer( damage_delay, function()
				-- create dummy to do damage and apply debuff modifier
				local dummy = CreateUnitByName( "npc_dummy_blank", target, false, caster, caster, caster:GetTeamNumber() )
				ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
				Timers:CreateTimer( dummy_duration, function()
						dummy:Destroy()
						return nil
					end
				)
				return nil
			end
		)
	else
		keys.ability:RefundManaCost()
	end
end
