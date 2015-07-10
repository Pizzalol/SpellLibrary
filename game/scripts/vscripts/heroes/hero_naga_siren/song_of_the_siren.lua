--[[
	Author: Ractidous
	Date: 25.01.2015.
	Swaps with the sub ability and plays a sound that can be stopped.
]]
function StartSinging( event )
	local caster = event.caster
	local ability = event.ability

	-- Swap sub_ability
	local sub_ability_name = event.sub_ability_name
	local main_ability_name = ability:GetAbilityName()

	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )

	-- Make cooldown
	sub_ability = caster:FindAbilityByName( sub_ability_name )
	local cooldown = sub_ability:GetCooldown( sub_ability:GetLevel() - 1 )

	sub_ability:EndCooldown()
	sub_ability:StartCooldown( cooldown )

	-- Play the song, which will be stopped when the sub ability fires
	caster:EmitSound( "Hero_NagaSiren.SongOfTheSiren" )
end


--[[
	Author: Ractidous
	Date: 25.01.2015.
	Stops the sound and swaps the abilities back to the original state.
]]
function CancelSinging( event )
	local caster = event.caster

	-- Stops the song
	caster:StopSound( "Hero_NagaSiren.SongOfTheSiren" )

	-- Plays the cancel sound
	caster:EmitSound( "Hero_NagaSiren.SongOfTheSiren.Cancel" )
end


--[[
	Author: Ractidous
	Date: 25.01.2015.
	Swap the abilities back to the original state.
]]
function EndSinging( event )
	local caster = event.caster
	local ability = event.ability

	-- Swap the sub_ability back to normal
	local main_ability_name = ability:GetAbilityName()
	local sub_ability_name = event.sub_ability_name

	caster:SwapAbilities( main_ability_name, sub_ability_name, true, false )
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