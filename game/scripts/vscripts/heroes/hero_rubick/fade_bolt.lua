--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Finds the next unit to jump to and deals the damage]]
function BoltJump(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() -1))
	local jump_damage_reduction_pct = ability:GetLevelSpecialValueFor("jump_damage_reduction_pct", (ability:GetLevel() -1))/100
	local jump_delay = ability:GetLevelSpecialValueFor("jump_delay", (ability:GetLevel() -1))
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	
	-- Applies the attack damage debuff
	if target:IsHero() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_fade_bolt_debuff_hero", {})
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_fade_bolt_debuff_creep", {})
	end
	
	-- Removes the hidden modifier
	target:RemoveModifierByName("modifier_fade_bolt_datadriven")
	
	-- Waits on the jump delay
	Timers:CreateTimer(jump_delay,
    function()
		-- Finds the current instance of the ability by ensuring both current targets are the same
		local current
		for i=0,ability.instance do
			if ability.target[i] ~= nil then
				if ability.target[i] == target then
					current = i
				end
			end
		end
	
		-- Adds a global array to the target, so we can check later if it has already been hit in this instance
		if target.hit == nil then
			target.hit = {}
		end
		-- Sets it to true for this instance
		target.hit[current] = true
	
		-- Increments our jump count for this instance
		ability.jump_count[current] = ability.jump_count[current] + 1
	
		-- Finds units in the radius to jump to
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		local closest = radius
		local new_target
		for i,unit in ipairs(units) do
			-- Positioning and distance variables
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = target:GetAbsOrigin() - unit_location
			local distance = (vector_distance):Length2D()
			-- Checks if the unit is closer than the closest checked so far
			if distance < closest then
				-- If the unit has not been hit yet, we set its distance as the new closest distance and it as the new target
				if unit.hit == nil then
					new_target = unit
					closest = distance
				elseif unit.hit[current] == nil then
					new_target = unit
					closest = distance
				end
			end
		end
		-- Checks if there is a new target
		if new_target ~= nil then
			-- Creates the particle between the new target and the last target
			local bolt = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, target)
			ParticleManager:SetParticleControl(bolt,0,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))   
			ParticleManager:SetParticleControl(bolt,1,Vector(new_target:GetAbsOrigin().x,new_target:GetAbsOrigin().y,new_target:GetAbsOrigin().z + new_target:GetBoundingMaxs().z ))
			-- Sets the new target as the current target for this instance
			ability.target[current] = new_target
			
			-- Reduces the spell's damage based on its number of jumps
			damage = damage - (damage * jump_damage_reduction_pct * ability.jump_count[current])
	
			-- Applies damage to the new target
			ApplyDamage({victim = new_target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
			
			-- Applies the modifer to the new target, which runs this function on it
			ability:ApplyDataDrivenModifier(caster, new_target, "modifier_fade_bolt_datadriven", {})
		else
			-- If there are no new targets, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil
		end
	end)
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Keeps track of all instances of the spell (since more than one can be active at once)]]
function NewInstance(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() -1))
	
	-- Keeps track of the total number of instances of the ability (increments on cast)
	if ability.instance == nil then
		ability.instance = 0
		ability.jump_count = {}
		ability.target = {}
	else
		ability.instance = ability.instance + 1
	end
	
	-- Sets the number of jumps for this instance (to be incremented later)
	ability.jump_count[ability.instance] = 0
	-- Sets the first target as the current target for this instance
	ability.target[ability.instance] = target
	
	-- Creates the particle between the caster and the first target
	local bolt = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(bolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))   
    ParticleManager:SetParticleControl(bolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	
	-- Applies damage to the first target
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end
