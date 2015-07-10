--[[Author: Pizzalol, Rook
	Date: 12.04.2015.
	Invokes a new spell depending on the orb combination]]
function Invoke( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	caster.invoked_orbs = caster.invoked_orbs or {}
	local max_invoked_spells = ability:GetLevelSpecialValueFor("max_invoked_spells", ability_level)
	local invoker_empty1 = "invoker_empty1_datadriven"
	local invoker_empty2 = "invoker_empty2_datadriven"
	local invoker_slot1 = caster:GetAbilityByIndex(3):GetAbilityName() -- First invoked spell
	local spell_to_be_invoked

	--Play the particle effect with the general color.
	local invoke_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)

	-- If we have 3 invoked orbs then do the Invoke logic
	if caster.invoked_orbs[1] and caster.invoked_orbs[2] and caster.invoked_orbs[3] then
		--The Invoke particle effect changes color depending on which orbs are out.
		local quas_particle_effect_color = Vector(0, 153, 204)
		local wex_particle_effect_color = Vector(204, 0, 153)
		local exort_particle_effect_color = Vector(255, 102, 0)
		
		local num_quas_orbs = 0
		local num_wex_orbs = 0
		local num_exort_orbs = 0
		for i=1, 3, 1 do
			if keys.caster.invoked_orbs[i]:GetName() == "invoker_quas_datadriven" then
				num_quas_orbs = num_quas_orbs + 1
			elseif keys.caster.invoked_orbs[i]:GetName() == "invoker_wex_datadriven" then
				num_wex_orbs = num_wex_orbs + 1
			elseif keys.caster.invoked_orbs[i]:GetName() == "invoker_exort_datadriven" then
				num_exort_orbs = num_exort_orbs + 1
			end
		end
		
		--Set the Invoke particle effect's color depending on which orbs are invoked.
		ParticleManager:SetParticleControl(invoke_particle_effect, 2, ((quas_particle_effect_color * num_quas_orbs) + (wex_particle_effect_color * num_wex_orbs) + (exort_particle_effect_color * num_exort_orbs)) / 3)

		-- Determine the invoked spell depending on which orbs are in use.
		if num_quas_orbs == 3 then
			spell_to_be_invoked = "invoker_cold_snap_datadriven"
		elseif num_quas_orbs == 2 and num_wex_orbs == 1 then
			spell_to_be_invoked = "invoker_ghost_walk_datadriven"
		elseif num_quas_orbs == 2 and num_exort_orbs == 1 then
			spell_to_be_invoked = "invoker_ice_wall_datadriven"
		elseif num_wex_orbs == 3 then
			spell_to_be_invoked = "invoker_emp_datadriven"
		elseif num_wex_orbs == 2 and num_quas_orbs == 1 then
			spell_to_be_invoked = "invoker_tornado_datadriven"
		elseif num_wex_orbs == 2 and num_exort_orbs == 1 then
			spell_to_be_invoked = "invoker_alacrity_datadriven"
		elseif num_exort_orbs == 3 then
			spell_to_be_invoked = "invoker_sun_strike_datadriven"
		elseif num_exort_orbs == 2 and num_quas_orbs == 1 then
			spell_to_be_invoked = "invoker_forge_spirit_datadriven"
		elseif num_exort_orbs == 2 and num_wex_orbs == 1 then
			spell_to_be_invoked = "invoker_chaos_meteor_datadriven"
		elseif num_quas_orbs == 1 and num_wex_orbs == 1 and num_exort_orbs == 1 then
			spell_to_be_invoked = "invoker_deafening_blast_datadriven"
		end

		-- If its only 1 max invoke spell then just swap abilities in the same slot
		if max_invoked_spells == 1 and invoker_slot1 ~= spell_to_be_invoked then
			caster:SwapAbilities(invoker_slot1, spell_to_be_invoked, false, true)
			caster:FindAbilityByName(spell_to_be_invoked):SetLevel(1)
		-- Otherwise reset the slots and then place the abilities in the proper slots
		elseif max_invoked_spells == 2 and invoker_slot1 ~= spell_to_be_invoked then
			if invoker_slot1 ~= invoker_empty1 then
				caster:SwapAbilities(invoker_empty1, invoker_slot1, true, false) 
			end

			local invoker_slot2 = caster:GetAbilityByIndex(4):GetAbilityName() -- Second invoked spell

			if invoker_slot2 ~= invoker_empty2 then
				caster:SwapAbilities(invoker_empty2, invoker_slot2, true, false) 
			end

			caster:SwapAbilities(spell_to_be_invoked, invoker_empty1, true, false) 
			caster:SwapAbilities(invoker_slot1, invoker_empty2, true, false)
			caster:FindAbilityByName(spell_to_be_invoked):SetLevel(1)
		end
	end
end