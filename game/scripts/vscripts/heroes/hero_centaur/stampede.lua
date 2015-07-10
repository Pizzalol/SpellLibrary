--[[
	Author: Noya
	Date: 9.1.2015.
	Does damage and slow the unit, checks to damage only once per spell usage.
]]
function Stampede( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local damage = ability:GetLevelSpecialValueFor( "base_damage" , ability:GetLevel() - 1  )
	local casterSTR = caster:GetStrength()
	local strength_damage = ability:GetLevelSpecialValueFor( "strength_damage" , ability:GetLevel() - 1  )
	local damageType = ability:GetAbilityDamageType()
	local total_damage = damage + ( casterSTR * strength_damage )
	local hit = false

	-- Ignore the target if its already on the table
	local targetsHit = event.ability.TargetsHit
	for k,v in pairs(targetsHit) do
		if v == target then
			hit = true
		end
	end

	if not hit then
		-- Damage
		ApplyDamage({ victim = target, attacker = caster, damage = total_damage, damage_type = damageType })

		-- Modifier
		ability:ApplyDataDrivenModifier( caster, target, "modifier_stampede_debuff", nil)

		-- Add to the targets hit by this cast
		table.insert(event.ability.TargetsHit, target)
	end

end

-- Emits the global sound and initializes a table to keep track of the units hit
function StampedeStart( event )
	EmitGlobalSound("Hero_Centaur.Stampede.Cast")

	event.ability.TargetsHit = {}
end