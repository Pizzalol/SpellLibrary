--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called when EMP is cast.
	Additional parameters: keys.Delay, keys.AreaOfEffect, keys.DamagePerManaPct, and keys.ManaGainPerManaPct
================================================================================================================= ]]
function invoker_emp_datadriven_on_spell_start(keys)
	local target_point = keys.target_points[1]

	--The amount of mana to burn depends on Wex.
	local wex_ability = keys.caster:FindAbilityByName("invoker_wex_datadriven")
	
	if wex_ability ~= nil then		
		local wex_level = wex_ability:GetLevel()		
		local mana_to_burn = keys.ability:GetLevelSpecialValueFor("mana_burned", wex_level - 1)
		
		--Create a dummy unit that will provide sound and particles.
		local emp_dummy_unit = CreateUnitByName("npc_dummy_unit", target_point, false, nil, nil, keys.caster:GetTeam())
		emp_dummy_unit:AddAbility("invoker_emp_datadriven")
		local emp_unit_ability = emp_dummy_unit:FindAbilityByName("invoker_emp_datadriven")
		if emp_unit_ability ~= nil then
			emp_unit_ability:SetLevel(1)
			emp_unit_ability:ApplyDataDrivenModifier(emp_dummy_unit, emp_dummy_unit, "modifier_invoker_emp_datadriven_unit_ability", {duration = -1})
		end
		
		keys.caster:EmitSound("Hero_Invoker.EMP.Cast")
		emp_dummy_unit:EmitSound("Hero_Invoker.EMP.Charge")  --Emit a sound that will follow the EMP.
		
		local emp_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_emp.vpcf", PATTACH_ABSORIGIN_FOLLOW, emp_dummy_unit)
		
		--Explode the EMP after the delay has passed.
		Timers:CreateTimer({
			endTime = keys.Delay,
			callback = function()
				ParticleManager:DestroyParticle(emp_effect, false)
				local emp_explosion_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_emp_explode.vpcf",  PATTACH_ABSORIGIN, emp_dummy_unit)
				
				emp_dummy_unit:EmitSound("Hero_Invoker.EMP.Discharge")
				
				local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), emp_dummy_unit:GetAbsOrigin(), nil, keys.AreaOfEffect, DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MANA_ONLY, FIND_ANY_ORDER, false)

				for i, individual_unit in ipairs(nearby_enemy_units) do
					--Burn an amount of mana dependent on Exort or the current mana the target has, whichever is lesser.
					local individual_unit_mana_to_burn = individual_unit:GetMana()
					if mana_to_burn < individual_unit_mana_to_burn then
						individual_unit_mana_to_burn = mana_to_burn
					end
					
					individual_unit:ReduceMana(individual_unit_mana_to_burn)
					ApplyDamage({victim = individual_unit, attacker = keys.caster, damage = individual_unit_mana_to_burn * (keys.DamagePerManaPct / 100), damage_type = DAMAGE_TYPE_PURE,})
					
					--Restore some of the burnt mana to Invoker if the affected unit is a real hero.
					if individual_unit:IsRealHero() then
						keys.caster:GiveMana(individual_unit_mana_to_burn * (keys.ManaGainPerManaPct / 100))
					end
				end
				
				--Remove the dummy unit once the explosion sound has stopped.
				Timers:CreateTimer({
					endTime = 4,
					callback = function()
						emp_dummy_unit:RemoveSelf()  --Note that this does cause a small dust cloud to appear in the dummy unit's location.
					end
				})
			end
		})
	end
end