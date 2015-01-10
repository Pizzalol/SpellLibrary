--[[
	Author: kritth
	Date: 10.01.2015.
	Burn mana and damage enemies with the same amount
]]
function mana_burn_function( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local current_mana = target:GetMana()
	local current_int = target:GetIntellect()
	local multiplier = keys.ability:GetLevelSpecialValueFor( "float_multiplier", keys.ability:GetLevel() - 1 )
	local number_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf"
	local burn_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf"
	local damageType = keys.ability:GetAbilityDamageType()
	
	-- Calculation
	local mana_to_burn = math.min( current_mana, current_int * multiplier )
	local life_time = 2.0
	local digits = string.len( math.floor( mana_to_burn ) ) + 1
	
	-- Fail check
	if target:IsMagicImmune() then
		mana_to_burn = 0
	end
	
	-- Apply effect of ability
	target:ReduceMana( mana_to_burn )
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = mana_to_burn,
		damage_type = damageType
	}
	ApplyDamage( damageTable )
	
	-- Show VFX
	local numberIndex = ParticleManager:CreateParticle( number_particle_name, PATTACH_OVERHEAD_FOLLOW, target )
	ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
    ParticleManager:SetParticleControl( numberIndex, 2, Vector( life_time, digits, 0 ) )
	local burnIndex = ParticleManager:CreateParticle( burn_particle_name, PATTACH_ABSORIGIN, target )
	
	-- Create timer to properly destroy particles
	Timers:CreateTimer( life_time, function()
			ParticleManager:DestroyParticle( numberIndex, false )
			ParticleManager:DestroyParticle( burnIndex, false)
			return nil
		end
	)
end
