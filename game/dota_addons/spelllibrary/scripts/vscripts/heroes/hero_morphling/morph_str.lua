--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling levels up his Morph (Strength) ability.  Levels Morph (Agility) to match the new level,
	if Morph (Agility) exists.
================================================================================================================= ]]
function morphling_morph_str_datadriven_on_upgrade(keys)
	local morph_agility_ability = keys.caster:FindAbilityByName("morphling_morph_agi_datadriven")
	local morph_strength_level = keys.ability:GetLevel()
	
	if morph_agility_ability ~= nil and morph_agility_ability:GetLevel() ~= morph_strength_level then
		morph_agility_ability:SetLevel(morph_strength_level)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling dies and has leveled Morph (Strength).  Untoggles Morph (Strength) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_str_datadriven_on_owner_died(keys)
	if keys.ability:GetToggleState() == true then
		keys.ability:ToggleAbility()
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles on Morph (Strength).  Applies a modifier, starts a sound, and toggles off
	Morph (Agility) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_str_datadriven_on_toggle_on(keys)
	local morph_agility_ability = keys.caster:FindAbilityByName("morphling_morph_agi_datadriven")
	if morph_agility_ability ~= nil then
		if morph_agility_ability:GetToggleState() == true then
			morph_agility_ability:ToggleAbility()
		end
	end
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_morphling_morph_str_datadriven_toggled_on", {duration = -1})
	keys.caster:EmitSound("Hero_Morphling.MorphStrengh")  --Sic.
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles off Morph (Strength).  Removes a modifier and stops a sound.
================================================================================================================= ]]
function morphling_morph_str_datadriven_on_toggle_off(keys)
	keys.caster:RemoveModifierByName("modifier_morphling_morph_str_datadriven_toggled_on")
	keys.caster:StopSound("Hero_Morphling.MorphStrengh")  --Sic.
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called at a regular interval while Morph (Strength) is toggled on.  Converts Agility into Strength, so long as
	Morphling has the required mana.
	Additional parameters: keys.PointsPerTick, keys.ManaCostPerSecond, and keys.ShiftRate
================================================================================================================= ]]
function modifier_morphling_morph_str_datadriven_on_interval_think(keys)
	local mana_cost = keys.ManaCostPerSecond * keys.ShiftRate
	
	if keys.caster:IsRealHero() and keys.caster:GetMana() >= mana_cost then  --If Morphling has the required mana.
		if keys.caster:GetBaseAgility() >= keys.PointsPerTick then
			keys.caster:SpendMana(mana_cost, keys.ability)  --Mana is not spent if Strength has bottomed out.
			keys.caster:SetBaseAgility(keys.caster:GetBaseAgility() - keys.PointsPerTick)
			keys.caster:SetBaseStrength(keys.caster:GetBaseStrength() + keys.PointsPerTick)
			keys.caster:CalculateStatBonus()  --This is needed to update Morphling's maximum HP when his STR is changed, for example.
		end
	end
end