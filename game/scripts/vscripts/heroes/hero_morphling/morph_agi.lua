--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling levels up his Morph (Agility) ability.  Levels Morph (Strength) to match the new level,
	if Morph (Strength) exists.
================================================================================================================= ]]
function morphling_morph_agi_datadriven_on_upgrade(keys)
	local morph_strength_ability = keys.caster:FindAbilityByName("morphling_morph_str_datadriven")
	local morph_agility_level = keys.ability:GetLevel()
	
	if morph_strength_ability ~= nil and morph_strength_ability:GetLevel() ~= morph_agility_level then
		morph_strength_ability:SetLevel(morph_agility_level)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling dies and has leveled Morph (Agility).  Untoggles Morph (Agility) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_agi_datadriven_on_owner_died(keys)
	if keys.ability:GetToggleState() == true then
		keys.ability:ToggleAbility()
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles on Morph (Agility).  Applies a modifier, starts a sound, and toggles off
	Morph (Strength) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_agi_datadriven_on_toggle_on(keys)
	local morph_strength_ability = keys.caster:FindAbilityByName("morphling_morph_str_datadriven")
	if morph_strength_ability ~= nil then
		if morph_strength_ability:GetToggleState() == true then
			morph_strength_ability:ToggleAbility()
		end
	end
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_morphling_morph_agi_datadriven_toggled_on", {duration = -1})
	keys.caster:EmitSound("Hero_Morphling.MorphAgility")
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles off Morph (Agility).  Removes a modifier and stops a sound.
================================================================================================================= ]]
function morphling_morph_agi_datadriven_on_toggle_off(keys)
	keys.caster:RemoveModifierByName("modifier_morphling_morph_agi_datadriven_toggled_on")
	keys.caster:StopSound("Hero_Morphling.MorphAgility")
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called at a regular interval while Morph (Agility) is toggled on.  Converts Strength into Agility, so long as
	Morphling has the required mana.
	Additional parameters: keys.PointsPerTick, keys.ManaCostPerSecond, and keys.ShiftRate
================================================================================================================= ]]
function modifier_morphling_morph_agi_datadriven_on_interval_think(keys)
	local mana_cost = keys.ManaCostPerSecond * keys.ShiftRate
	
	if keys.caster:IsRealHero() and keys.caster:GetMana() >= mana_cost then  --If Morphling has the required mana.
		if keys.caster:GetBaseStrength() >= keys.PointsPerTick then
			keys.caster:SpendMana(mana_cost, keys.ability)  --Mana is not spent if Agility has bottomed out.
			keys.caster:SetBaseStrength(keys.caster:GetBaseAgility() - keys.PointsPerTick)
			keys.caster:SetBaseAgility(keys.caster:GetBaseStrength() + keys.PointsPerTick)
			keys.caster:CalculateStatBonus()  --This is needed to update Morphling's maximum HP when his STR is changed, for example.
		end
	end
end