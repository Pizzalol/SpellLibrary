--[[
	Author: kritth
	Date: 09.01.2015
	Initialize the spot
]]
function x_marks_the_spot_init( keys )
  -- Variables
	local caster = keys.caster
	local target = keys.target
	local targetLoc = keys.target:GetAbsOrigin()
	local x_marks_return_name = "kunkka_return_datadriven"
	
	-- Set variables
	caster.x_marks_target = target
	caster.x_marks_origin = targetLoc
	
	-- Swap ability
	caster:SwapAbilities( keys.ability:GetAbilityName(), x_marks_return_name, false, true )
end

--[[
	Author: kritth
	Date: 09.01.2015
	Force return as a part of Return ability
]]
function x_marks_the_spot_force_return( keys )
	local caster = keys.caster
	local modifierName = "modifier_x_marks_the_spot_debuff_datadriven"
	caster.x_marks_target:RemoveModifierByName( modifierName )
end

--[[
	Author: kritth
	Date: 09.01.2015
	Return to spot
]]
function x_marks_the_spot_return( keys )
  -- Variables
	local caster = keys.caster
	local x_marks = "kunkka_x_marks_the_spot_datadriven"
	local x_marks_return = "kunkka_return_datadriven"
	local modifierName = "modifier_x_marks_the_spot_debuff_datadriven"
	
	-- Check if there is target unit
	if caster.x_marks_target ~= nil and caster.x_marks_origin ~= nil then
		FindClearSpaceForUnit( caster.x_marks_target, caster.x_marks_origin, true )
		caster.x_marks_target = nil
		caster.x_marks_origin = nil
	end
	
	-- Swap ability
	caster:SwapAbilities( x_marks, x_marks_return, true, false )
	x_marks_start_cooldown( keys )
end

--[[
	Author: kritth
	Date: 09.01.2015
	Start cooldown of the ability
]]
function x_marks_start_cooldown( keys )
  -- Name of both abilities
	local x_marks = "kunkka_x_marks_the_spot_datadriven"
	local x_marks_return = "kunkka_return_datadriven"

  -- Loop to reset cooldown
	for i = 0, keys.caster:GetAbilityCount() - 1 do
		local currentAbility = keys.caster:GetAbilityByIndex( i )
		if currentAbility ~= nil and ( currentAbility:GetAbilityName() == x_marks or currentAbility:GetAbilityName() == x_marks_return ) then
			currentAbility:EndCooldown()
			currentAbility:StartCooldown( currentAbility:GetCooldown( currentAbility:GetLevel() - 1 ) )
		end
	end
end

--[[
	Author: kritth
	Date: 09.01.2015
	Level up both skills at the same time
]]
function x_marks_the_spot_level_up( keys )
  -- Variable for sub ability
	local x_marks_return_name = "kunkka_return_datadriven"

  -- loop to find the ability
	for i = 0, keys.caster:GetAbilityCount() do
		local currentAbility = keys.caster:GetAbilityByIndex( i )
		if currentAbility ~= nil and currentAbility:GetAbilityName() == x_marks_return_name then
			if currentAbility:GetLevel() ~= keys.ability:GetLevel() then
				currentAbility:SetLevel( keys.ability:GetLevel() )
			end
			break
		end
	end
end

--[[
	Author: Noya
	Date: 16.01.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
	local caster = event.caster
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
end
