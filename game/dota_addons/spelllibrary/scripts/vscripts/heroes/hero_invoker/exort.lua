--[[ ============================================================================================================
	Author: Rook
	Date: April 02, 2015
	Called whenever Exort is cast.  Removes the third-to-most-recent orb on Invoker (if applicable) to make room for
	the newest orb, then adds the new orb.
	This function is general enough that it can be used for Quas, Wex, or Exort.
================================================================================================================= ]]
function invoker_replace_orb(keys, particle_filepath)
	--Initialization for storing the orb properties, if not already done.
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	if keys.caster.invoked_orbs_particle == nil then
		keys.caster.invoked_orbs_particle = {}
	end
	if keys.caster.invoked_orbs_particle_attach == nil then
		keys.caster.invoked_orbs_particle_attach = {}
		keys.caster.invoked_orbs_particle_attach[1] = "attach_orb1"
		keys.caster.invoked_orbs_particle_attach[2] = "attach_orb2"
		keys.caster.invoked_orbs_particle_attach[3] = "attach_orb3"
	end
	
	--Invoker can only have three orbs active at any time.  Each time an orb is activated, its hscript is
	--placed into keys.caster.invoked_orbs[3], the old [3] is moved into [2], and the old [2] is moved into [1].
	--Therefore, the oldest orb is located in [1], and the newest is located in [3].
	--Now, shift the ordered list of currently summoned orbs down, and add the newest orb to the queue.
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability
	
	--Remove the removed orb's particle effect.
	if keys.caster.invoked_orbs_particle[1] ~= nil then
		ParticleManager:DestroyParticle(keys.caster.invoked_orbs_particle[1], false)
		keys.caster.invoked_orbs_particle[1] = nil
	end
	
	--Shift the ordered list of currently summoned orb particle effects down, and create the new particle.
	keys.caster.invoked_orbs_particle[1] = keys.caster.invoked_orbs_particle[2]
	keys.caster.invoked_orbs_particle[2] = keys.caster.invoked_orbs_particle[3]
	keys.caster.invoked_orbs_particle[3] = ParticleManager:CreateParticle(particle_filepath, PATTACH_OVERHEAD_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(keys.caster.invoked_orbs_particle[3], 1, keys.caster, PATTACH_POINT_FOLLOW, keys.caster.invoked_orbs_particle_attach[1], keys.caster:GetAbsOrigin(), false)
	
	--Shift the ordered list of currently summoned orb particle effect attach locations down.
	local temp_attachment_point = keys.caster.invoked_orbs_particle_attach[1]
	keys.caster.invoked_orbs_particle_attach[1] = keys.caster.invoked_orbs_particle_attach[2]
	keys.caster.invoked_orbs_particle_attach[2] = keys.caster.invoked_orbs_particle_attach[3]
	keys.caster.invoked_orbs_particle_attach[3] = temp_attachment_point
	
	invoker_replace_orb_modifiers(keys)  --Remove and reapply the orb instance modifiers.
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 02, 2015
	Called when Exort is cast or upgraded.  Replaces the modifiers on the caster's modifier bar to
	ensure the correct order, which also has the effect of leveling the effects of any currently existing orbs.
	This function is general enough that it can be used for Quas, Wex, or Exort.
	Known bugs: The correct order of the orb modifiers on the modifier bar is not always maintained.  This is a
	    visual bug only and likely has to do with removing and reapplying modifiers on the same frame.
================================================================================================================= ]]
function invoker_replace_orb_modifiers(keys)
	--Initialization for storing the orb list, if not already done.
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end

	--Reapply all the orbs Invoker has out in order to benefit from the upgraded ability's level.  By reapplying all
	--three orb modifiers, they will maintain their order on the modifier bar (so long as all are removed before any
	--are reapplied, since ordering problems arise if there are two of the same type of orb otherwise).
	while keys.caster:HasModifier("modifier_invoker_quas_datadriven_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_quas_datadriven_instance")
	end
	while keys.caster:HasModifier("modifier_invoker_wex_datadriven_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_wex_datadriven_instance")
	end
	while keys.caster:HasModifier("modifier_invoker_exort_datadriven_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_exort_datadriven_instance")
	end

	--Reapply the orb modifiers in the correct order.
	for i=1, 3, 1 do
		if keys.caster.invoked_orbs[i] ~= nil then
			local orb_name = keys.caster.invoked_orbs[i]:GetName()
			if orb_name == "invoker_quas_datadriven" then
				local exort_ability = keys.caster:FindAbilityByName("invoker_quas_datadriven")
				if exort_ability ~= nil then
					exort_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_quas_datadriven_instance", nil)
				end
			elseif orb_name == "invoker_wex_datadriven" then
				local wex_ability = keys.caster:FindAbilityByName("invoker_wex_datadriven")
				if wex_ability ~= nil then
					wex_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_wex_datadriven_instance", nil)
				end
			elseif orb_name == "invoker_exort_datadriven" then
				local exort_ability = keys.caster:FindAbilityByName("invoker_exort_datadriven")
				if exort_ability ~= nil then
					exort_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_exort_datadriven_instance", nil)
				end
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 02, 2015
	Called when Exort is cast.
================================================================================================================= ]]
function invoker_exort_datadriven_on_spell_start(keys)
	invoker_replace_orb(keys, "particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf")
end