--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Applies a strong dispel to Ursa]]
function Purge(keys)
	local caster = keys.caster
	local ability = keys.ability
	local model_scale = ability:GetLevelSpecialValueFor( "model_scale", ability:GetLevel() - 1 )
	
	-- Strong Dispel
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = false
	caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
	
	-- Gives Ursa a red tint
	caster:SetRenderColor(255, 0, 0)
	
	-- Scales Ursa's model by 120%
	caster:SetModelScale(model_scale)
end

--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Applies the bonus fury swipe damage]]
function BonusDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local fury_swipes = caster:FindAbilityByName("ursa_fury_swipes_datadriven")
	local modifierName = "modifier_fury_swipes_target_datadriven"
	local damageType = fury_swipes:GetAbilityDamageType()
	
	local damage_multiplier = ability:GetLevelSpecialValueFor( "damage_multiplier", ability:GetLevel() - 1 )
	local damage_per_stack = fury_swipes:GetLevelSpecialValueFor( "damage_per_stack", ability:GetLevel() - 1 )

	-- Applies the fury swipes multiplier damage
	if target:HasModifier( modifierName ) then
		local current_stack = target:GetModifierStackCount( modifierName, fury_swipes )
		local ability_damage = current_stack * damage_multiplier
		
		-- Deal damage
		local damage_table = {
			victim = target,
			attacker = caster,
			damage = damage_per_stack * ability_damage,
			damage_type = damageType
		}
		ApplyDamage( damage_table )
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Changes Ursa back to his original color and size]]
function ChangeAppearance(keys)
	local caster = keys.caster
	
	caster:SetRenderColor(255, 255, 255)
	caster:SetModelScale(1)
end
