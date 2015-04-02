--[[ ============================================================================================================
	Author: Rook
	Date: April 02, 2015
	Called when Invoke is cast.  Gives Invoker access to an ability depending on which reagents he has out.  
	Stores cooldown information for the removed invoked spell, if applicable.
	Additional parameters: keys.MaxInvokedSpells
================================================================================================================= ]]
function invoker_invoke_datadriven_on_spell_start(keys)
	keys.caster:EmitSound("Hero_Invoker.Invoke")

	--Initialization of the orb property storage, if not already done.
	if keys.caster.invoke_ability_cooldown_remaining == nil then
		keys.caster.invoke_ability_cooldown_remaining = {}
	end
	if keys.caster.invoke_ability_gametime_removed == nil then
		keys.caster.invoke_ability_gametime_removed = {}
	end
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end

	--Play the particle effect with the general color.
	local invoke_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	
	if keys.caster.invoked_orbs[1] ~= nil and keys.caster.invoked_orbs[2] ~= nil and keys.caster.invoked_orbs[3] ~= nil then  --A spell will be invoked only if three orbs have been summoned.
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
		
		if keys.MaxInvokedSpells ~= 0 then
			local ability_d = keys.caster:GetAbilityByIndex(3)
			local ability_d_name = ability_d:GetName()
			
			--Add the invoked spell depending on which orbs are in use.
			if num_quas_orbs == 3 then
				local spell_name_to_invoke = "invoker_cold_snap_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			elseif num_quas_orbs == 2 and num_wex_orbs == 1 then
				local spell_name_to_invoke = "invoker_ghost_walk_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			elseif num_quas_orbs == 2 and num_exort_orbs == 1 then
				local spell_name_to_invoke = "invoker_ice_wall_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			elseif num_wex_orbs == 3 then
				local spell_name_to_invoke = "invoker_emp_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			elseif num_wex_orbs == 2 and num_quas_orbs == 1 then
				local spell_name_to_invoke = "invoker_tornado_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			elseif num_wex_orbs == 2 and num_exort_orbs == 1 then
				local spell_name_to_invoke = "invoker_alacrity_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			elseif num_exort_orbs == 3 then
				local spell_name_to_invoke = "invoker_sun_strike_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			elseif num_exort_orbs == 2 and num_quas_orbs == 1 then
				local spell_name_to_invoke = "invoker_forge_spirit_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			elseif num_exort_orbs == 2 and num_wex_orbs == 1 then
				local spell_name_to_invoke = "invoker_chaos_meteor_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			elseif num_quas_orbs == 1 and num_wex_orbs == 1 and num_exort_orbs == 1 then
				local spell_name_to_invoke = "invoker_deafening_blast_datadriven"
				if ability_d_name ~= spell_name_to_invoke then  --Invoke does nothing if this spell was already the most recently invoked.
					invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
					keys.caster:AddAbility(spell_name_to_invoke)
					local newly_invoked_spell_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
					newly_invoked_spell_ability:SetLevel(1)
					invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
				end
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 02, 2015
	A helper function for when Invoke is cast and Invoker does not have the spell that he's attempting to invoke in
	slot D already.  Removes the old spell and shifts the D spell over to the F slot if 2 spells can be invoked at once.
	Cooldown information for the removed spell is stored.
	Additional parameters: keys.MaxInvokedSpells
================================================================================================================= ]]
function invoker_invoke_datadriven_on_spell_start_spell_removal_helper(keys)
	local ability_index_to_remove = 3
	if keys.MaxInvokedSpells == 2 then
		ability_index_to_remove = 4
	end
	
	local old_spell_invoked = keys.caster:GetAbilityByIndex(ability_index_to_remove)
	local old_spell_invoked_name = old_spell_invoked:GetName()
	
	--Update keys.caster.invoke_ability_cooldown_remaining[ability_name] of the ability to be removed, so cooldowns can be tracked.
	--We cannot just store the gametime because the ability's maximum cooldown may have changed due to leveling up Invoker's orbs
	--by the time the ability is reinvoked.  Therefore, keys.caster.invoke_ability_gametime_removed[ability_name] is also stored.
	keys.caster.invoke_ability_cooldown_remaining[old_spell_invoked_name] = old_spell_invoked:GetCooldownTimeRemaining()
	keys.caster.invoke_ability_gametime_removed[old_spell_invoked_name] = GameRules:GetGameTime() 
	
	keys.caster:RemoveAbility(old_spell_invoked_name)  --Remove the ability that is supposed to be entirely removed.
	
	if keys.MaxInvokedSpells == 2 then  --If Invoker can have two spells invoked simultaneously, shift the ability in the D slot over to the F slot.
		local ability_d = keys.caster:GetAbilityByIndex(3)
		local ability_d_name = ability_d:GetName()
		local ability_d_current_cooldown = ability_d:GetCooldownTimeRemaining()
		local ability_d_current_level = ability_d:GetLevel()
		
		keys.caster:RemoveAbility(ability_d_name)
		
		keys.caster:AddAbility("invoker_empty1_datadriven")
		keys.caster:AddAbility(ability_d_name)  --This will place the ability that was bound to D in the F slot.
		keys.caster:RemoveAbility("invoker_empty1_datadriven")
		
		local new_ability_f = keys.caster:FindAbilityByName(ability_d_name)
		new_ability_f:SetLevel(ability_d_current_level)
		new_ability_f:StartCooldown(ability_d_current_cooldown)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 02, 2015
	A helper function for when Invoke is cast and a new spell has been invoked.  Puts the newly invoked ability 
	on cooldown if it should still have a remaining cooldown from the last time it was invoked.
	Additional parameters: keys.MaxInvokedSpells
================================================================================================================= ]]
function invoker_invoke_datadriven_on_spell_start_cooldown_helper(keys)
	local new_spell_invoked = keys.caster:GetAbilityByIndex(3)
	
	if new_spell_invoked ~= nil then
		if new_spell_invoked:GetLevel() == 0 then
			new_spell_invoked:SetLevel(1)
		end
		
		local new_spell_invoked_name = new_spell_invoked:GetName()

		--Place the newly-invoked spell on cooldown if it should still be on cooldown from the last time it was cast.
		if keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] ~= nil and keys.caster.invoke_ability_gametime_removed[new_spell_invoked_name] ~= nil and keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] ~= 0 then
			local current_game_time = GameRules:GetGameTime()
			if keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] + keys.caster.invoke_ability_gametime_removed[new_spell_invoked_name] >= current_game_time then
				new_spell_invoked:StartCooldown(current_game_time - (keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] + keys.caster.invoke_ability_gametime_removed[new_spell_invoked_name]))
			else
				new_spell_invoked:EndCooldown()
			end
		else
			new_spell_invoked:EndCooldown()
		end
	end
end