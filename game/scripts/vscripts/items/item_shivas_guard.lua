--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Shiva's Guard is cast.  Emits a slowly increasing wave emanating from the caster that applies a
	debuff to enemies within its current radius.
	Additional parameters: keys.BlastFinalRadius, keys.BlastSpeedPerSecond, keys.BlastDamage, keys.BlastVisionRadius,
		and keys.BlastVisionDuration
	Known bugs:
		This implementation only supports one blast radiating outwards from the same unit at a time (the debuff 
			will be applied to units within the most recently emitted blast's radius).  This should only be an
			issue when Refresher Orb or Tinker's Rearm are involved.
		Blast damage is only dealt if the affected unit does not already have a blast debuff on them.  The duration
			is also not refreshed if the affected unit already has a blast debuff on them.  Once a function such as
			HasModifierByNameAndCaster() is exposed, this bug can be resolved (for now, it is only an issue when
			multiple players have a Shiva's Guard or when Shiva's Guard's cooldown gets refreshed.
		The particle effect does not seem to have 100% visual parity.
		The vision provided when Shiva's Guard is cast should be flying vision, not ground vision.
================================================================================================================= ]]
function item_shivas_guard_datadriven_on_spell_start(keys)
	local shivas_guard_particle = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControl(shivas_guard_particle, 1, Vector(keys.BlastFinalRadius, keys.BlastFinalRadius / keys.BlastSpeedPerSecond, keys.BlastSpeedPerSecond))
	
	keys.caster:EmitSound("DOTA_Item.ShivasGuard.Activate")
	keys.caster.shivas_guard_current_blast_radius = 0
	
	--Every .03 seconds, damage and apply a movement speed debuff to all units within the current radius of the blast (centered around the caster)
	--that do not already have the debuff.
	--Stop the timer when the blast has reached its maximum radius.
	Timers:CreateTimer({
		endTime = .03, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			keys.ability:CreateVisibilityNode(keys.caster:GetAbsOrigin(), keys.BlastVisionRadius, keys.BlastVisionDuration)  --Shiva's Guard's active provides 800 flying vision around the caster, which persists for 2 seconds.
		
			keys.caster.shivas_guard_current_blast_radius = keys.caster.shivas_guard_current_blast_radius + (keys.BlastSpeedPerSecond * .03)
			local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.caster.shivas_guard_current_blast_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			for i, individual_unit in ipairs(nearby_enemy_units) do
				if not individual_unit:HasModifier("modifier_item_shivas_guard_datadriven_blast_debuff") then
					ApplyDamage({victim = individual_unit, attacker = keys.caster, damage = keys.BlastDamage, damage_type = DAMAGE_TYPE_MAGICAL,})
					
					--This impact particle effect should radiate away from the caster of Shiva's Guard.
					local shivas_guard_impact_particle = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
					local target_point = individual_unit:GetAbsOrigin()
					local caster_point = individual_unit:GetAbsOrigin()
					ParticleManager:SetParticleControl(shivas_guard_impact_particle, 1, target_point + (target_point - caster_point) * 30)
					
					keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_item_shivas_guard_datadriven_blast_debuff", nil)
				end
			end
			
			if keys.caster.shivas_guard_current_blast_radius < keys.BlastFinalRadius then  --If the blast should still be expanding.
				return .03
			else  --The blast has reached or exceeded its intended final radius.
				keys.caster.shivas_guard_current_blast_radius = 0
				return nil
			end
		end
	})
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when the debuff aura modifier is created and regularly while it is on an enemy unit.  Since the debuff aura
	modifier should only be visible if the enemy team has vision over its emitter, check to see if this is the case and
	add or remove a visible aura accordingly.
================================================================================================================= ]]
function modifier_item_shivas_guard_datadriven_enemy_aura_on_interval_think(keys)
	local is_emitter_visible = keys.target:CanEntityBeSeenByMyTeam(keys.caster)
	
	if is_emitter_visible and not keys.target:HasModifier("modifier_item_shivas_guard_datadriven_enemy_aura_visible") then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_shivas_guard_datadriven_enemy_aura_visible", {duration = -1})
	elseif not is_emitter_visible and keys.target:HasModifier("modifier_item_shivas_guard_datadriven_enemy_aura_visible") then
		keys.target:RemoveModifierByNameAndCaster("modifier_item_shivas_guard_datadriven_enemy_aura_visible", keys.caster)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when the debuff aura modifier is removed.  Removes the associated visible modifier, if applicable.
================================================================================================================= ]]
function modifier_item_shivas_guard_datadriven_enemy_aura_on_destroy(keys)
	keys.target:RemoveModifierByNameAndCaster("modifier_item_shivas_guard_datadriven_enemy_aura_visible", keys.caster)
end