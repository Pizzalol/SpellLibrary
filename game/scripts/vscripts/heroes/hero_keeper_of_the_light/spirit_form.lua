--[[Author: Noya
	Used by: Pizzalol
	Date: 25.01.2015.
	Swaps the abilities]]
function SwapAbilities( keys )
	local caster = keys.caster

	-- Swap sub_ability
	local sub_ability_name = keys.sub_ability_name
	local main_ability_name = keys.main_ability_name

	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
end

--[[
	Author: Noya,Pizzalol
	Date: 27.09.2015.
	Levels up the ability_name to the same level of the ability that runs this and only
	if the target has the specified modifier
]]
function LevelUpAbility( event )
	local caster = event.caster
	local modifier = event.modifier
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end

	-- Disable/Enable the ability depending if Spirit Form is active
	if caster:HasModifier(modifier) then
		ability_handle:SetActivated(true) 
	else
		ability_handle:SetActivated(false)
	end
end

--[[Enables the Spirit Form abilities]]
function SpiritFormStart( keys )
	local caster = keys.caster
	local spirit_form = keys.ability

	local illuminate = caster:FindAbilityByName(keys.illuminate)
	local spirit_form_illuminate = caster:FindAbilityByName(keys.spirit_form_illuminate)
	local recall = caster:FindAbilityByName(keys.recall)
	local blinding_light = caster:FindAbilityByName(keys.blinding_light)

	local illuminate_level = illuminate:GetLevel()

	spirit_form_illuminate:SetLevel(illuminate_level)
	recall:SetActivated(true)
	blinding_light:SetActivated(true)
end

--[[Disables the Spirit Form abilities]]
function SpiritFormEnd( keys )
	local caster = keys.caster

	local illuminate = caster:FindAbilityByName(keys.illuminate)
	local spirit_form_illuminate = caster:FindAbilityByName(keys.spirit_form_illuminate)
	local recall = caster:FindAbilityByName(keys.recall)
	local blinding_light = caster:FindAbilityByName(keys.blinding_light)

	local spirit_form_illuminate_level = spirit_form_illuminate:GetLevel()

	illuminate:SetLevel(spirit_form_illuminate_level)
	recall:SetActivated(false)
	blinding_light:SetActivated(false)

	if caster.spirit_form_illuminate_dummy and IsValidEntity(caster.spirit_form_illuminate_dummy) then
		caster.spirit_form_illuminate_dummy:RemoveModifierByName("modifier_spirit_form_illuminate_dummy_datadriven")
	end
end