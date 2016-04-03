--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Applies the damage absorb and bonus damage modifiers to the caster]]
function ApplyModifiers(keys)
	local caster = keys.caster
	local ability = keys.ability
	local stacks = ability:GetLevelSpecialValueFor( "instances", ability:GetLevel() - 1 )
	
	-- Applies the damage absorb buff
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_damage_absorb", {})
	-- Applies the bonus damage buff
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_damage", {})
	-- Shows the current stacks of bonus damage
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_damage_visual", {})
	caster:SetModifierStackCount("modifier_damage_absorb", ability, stacks)
	caster:SetModifierStackCount("modifier_bonus_damage_visual", ability, stacks)
	
	-- Attaches the particle to the caster
	ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(ability.particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 3, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
end

--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Removes a damage absorb stack]]
function RemoveDamageAbsorbStack(keys)
	local caster = keys.caster
	local ability = keys. ability
	local modifier = "modifier_damage_absorb"
	local damage_threshold = ability:GetLevelSpecialValueFor( "damage_threshold", ability:GetLevel() - 1 )
	local damage = keys.damage
	local stacks = caster:GetModifierStackCount(modifier, ability)
	
	-- Ensures the caster is affected by the modifier
	if caster:HasModifier(modifier) then
		-- Ensures the damage surpasses the threshold
		if damage >= damage_threshold then
			-- Replaces the health the caster lost when taking damage
			caster:SetHealth(caster:GetHealth() + damage)
		
			-- Removes a stack from the damage absorb modifier
			caster:SetModifierStackCount(modifier, ability, stacks - 1)
			stacks = caster:GetModifierStackCount(modifier, ability)
	
			-- If all stacks are gone, we remove the modifier
			if stacks == 0 then
				caster:RemoveModifierByName(modifier)
			end
		
			-- Play the absorb sound on the caster
			EmitSoundOn(keys.sound, caster)
		end
	else
		-- Destroys the damage absorb particle when the modifier is destroyed
		ParticleManager:DestroyParticle(ability.particle, true)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Removes a bonus damage stack]]
function RemoveBonusDamageStack(keys)
	local caster  = keys.caster
	local ability = keys. ability
	local modifier = "modifier_bonus_damage_visual"
	local stacks = caster:GetModifierStackCount(modifier, ability)
	
	-- Removes a stack from the bonus damage modifier
	caster:SetModifierStackCount(modifier, ability, stacks - 1)
	stacks = caster:GetModifierStackCount(modifier, ability)
	
	-- If all stacks are gone we remove both modifiers
	if stacks == 0 then
		caster:RemoveModifierByName(modifier)
		caster:RemoveModifierByName("modifier_bonus_damage")
	end
end
