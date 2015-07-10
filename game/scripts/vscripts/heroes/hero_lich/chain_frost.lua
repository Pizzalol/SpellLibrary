--[[
	Author: Noya
	Date: 19.01.2015.
	Bounces a chain frost

	Bug: Currently fails to have 2 different chains bouncing at the same time, because the counter is on the ability instead of the cast.
]]
function ChainFrost( event )

	-- The chain frost is cast from the latest hit target to the first nearby enemy that isn't the same target
	local caster = event.caster
	local unit = event.target
	local targets = event.target_entities
	local ability = event.ability

	local jumps = ability:GetLevelSpecialValueFor( "jumps", ability:GetLevel() - 1 )
	local jump_range = ability:GetLevelSpecialValueFor( "jump_range", ability:GetLevel() - 1 )
	local jump_interval = ability:GetLevelSpecialValueFor( "jump_interval", ability:GetLevel() - 1 )

	local projectile_speed = ability:GetLevelSpecialValueFor( "projectile_speed", ability:GetLevel() - 1 )
	local vision_radius = ability:GetLevelSpecialValueFor( "vision_radius", ability:GetLevel() - 1 )

	local particle_name = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf"

	-- Initialize the chain counter, on 1 because the first cast
	if not ability.jump_counter then
		ability.jump_counter = 1
	end

	-- If there's still bounces to expend, find a new target
	if ability.jump_counter <= jumps then

		-- Emit the sound, Creep or Hero depending on the type of the enemy hit
		if unit:IsRealHero() then
			unit:EmitSound("Hero_Lich.ChainFrostImpact.Hero")
		else
			unit:EmitSound("Hero_Lich.ChainFrostImpact.Creep")
		end

		-- Go through the target_enties table, checking for the first one that isn't the same as the target
		local target_to_jump = nil
		for _,target in pairs(targets) do
			if target ~= unit and not target_to_jump then
				target_to_jump = target
			end
		end

		if target_to_jump then

			print("Bounce number "..ability.jump_counter)
			-- Create the next projectile
			local info = {
				Target = target_to_jump,
				Source = unit,
				Ability = ability,
				EffectName = particle_name,
				bDodgeable = false,
				bProvidesVision = true,
				iMoveSpeed = projectile_speed,
		        iVisionRadius = vision_radius,
		        iVisionTeamNumber = caster:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
			}
			ProjectileManager:CreateTrackingProjectile( info )

			-- Add one to the jump counter for this bounce
			ability.jump_counter = ability.jump_counter + 1
		else
			print("Can't find a target, End Chain")
			ability.jump_counter = nil
		end	
	else
		print("No more bounces left, End Chain")
		ability.jump_counter = nil
	end
end