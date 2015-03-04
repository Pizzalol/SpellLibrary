
--[[
	Author: Noya, Pizzalol
	Date: 04.03.2015.
	After taking damage, checks the mana of the caster and prevents as many damage as possible.

	Note: This is post-reduction, because there's currently no easy way to get pre-mitigation damage.
]]
function ManaShield( event )
	local caster = event.caster
	local ability = event.ability
	local damage_per_mana = ability:GetLevelSpecialValueFor("damage_per_mana", ability:GetLevel() - 1 )
	local absorption_percent = ability:GetLevelSpecialValueFor("absorption_tooltip", ability:GetLevel() - 1 ) * 0.01
	local damage = event.Damage * absorption_percent
	local not_reduced_damage = event.Damage - damage

	local caster_mana = caster:GetMana()
	local mana_needed = damage / damage_per_mana

	-- Check if the not reduced damage kills the caster
	local oldHealth = caster.OldHealth - not_reduced_damage

	-- If it doesnt then do the HP calculation
	if oldHealth >= 1 then
		print("Damage taken "..damage.." | Mana needed: "..mana_needed.." | Current Mana: "..caster_mana)

		-- If the caster has enough mana, fully heal for the damage done
		if mana_needed <= caster_mana then
			caster:SpendMana(mana_needed, ability)
			caster:SetHealth(oldHealth)
			
			-- Impact particle based on damage absorbed
			local particleName = "particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(mana_needed,0,0))
		else
			local newHealth = oldHealth - damage
			mana_needed =
			caster:SpendMana(mana_needed, ability)
			caster:SetHealth(newHealth)
		end
	end	
end

-- Keeps track of the targets health
function ManaShieldHealth( event )
	local caster = event.caster

	caster.OldHealth = caster:GetHealth()
end