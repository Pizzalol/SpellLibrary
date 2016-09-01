modifier_spectre_dispersion_lua = class({})

function modifier_spectre_dispersion_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_spectre_dispersion_lua:OnTakeDamage (event)

	if event.unit == self:GetParent() then

		local caster = self:GetParent()
		local post_damage = event.damage
		local original_damage = event.original_damage
		local ability = self:GetAbility()
		local damage_reflect_pct = ( ability:GetLevelSpecialValueFor( "damage_reflection_pct", ability:GetLevel()-1 ) ) * 0.01

		--Ignore damage
		if caster:IsAlive() then
			caster:SetHealth(caster:GetHealth() + (post_damage * damage_reflect_pct) )
		end

		local max_radius = ability:GetSpecialValueFor("max_radius")
		local min_radius = ability:GetSpecialValueFor("min_radius")

		units = FindUnitsInRadius(
						caster:GetTeamNumber(),
                        caster:GetAbsOrigin(),
                        nil,
                        max_radius,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false
        )
		
		for _,unit in pairs(units) do

			if unit:GetTeam() ~= caster:GetTeam() then

				local vCaster = caster:GetAbsOrigin()
				local vUnit = unit:GetAbsOrigin()

				local reflect_damage = 0.0
				local particle_name = ""

				local distance = (vUnit - vCaster):Length2D()
				
				--Within 300 radius		
				if distance <= min_radius then
					reflect_damage = original_damage * damage_reflect_pct
					particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf"
				--Between 301 and 475 radius
				elseif distance <= (min_radius+175) then
					reflect_damage = original_damage * ( damage_reflect_pct * ( (distance-300) * 0.142857 ) * 0.01 )
					particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion_fallback_mid.vpcf"
				--Same formula as previous statement but different particle
				else
					reflect_damage = original_damage * ( damage_reflect_pct * ( (distance-300) * 0.142857 ) * 0.01 )
					particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion_b_fallback_low.vpcf"
				end

				--Create particle
				local particle = ParticleManager:CreateParticle( particle_name, PATTACH_POINT_FOLLOW, caster )
				ParticleManager:SetParticleControl(particle, 0, vCaster)
				ParticleManager:SetParticleControl(particle, 1, vUnit)
				ParticleManager:SetParticleControl(particle, 2, vCaster)

				local old_hp = unit:GetHealth()
				local new_hp = old_hp - reflect_damage

				if unit:IsAlive() then
					if new_hp < 1.000000 then
						unit:Kill(ability, caster)
					else
						unit:SetHealth(new_hp)
					end
				end

			end

		end

	end

end

function modifier_spectre_dispersion_lua:IsHidden()
	return true
end

function modifier_spectre_dispersion_lua:RemoveOnDeath()
	return false
end

function modifier_spectre_dispersion_lua:IsPurgable()
	return false
end
