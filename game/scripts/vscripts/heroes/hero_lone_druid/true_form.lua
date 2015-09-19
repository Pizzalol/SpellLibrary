--[[
	Author: Noya
	Date: 15.01.2015.
	Swaps caster model and ability, gives a short period of invulnerability
]]
function TrueFormStart( event )
	local caster = event.caster
	local model = event.model
	local ability = event.ability

	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	caster.caster_attack = caster:GetAttackCapability()

	-- Sets the new model
	caster:SetOriginalModel(model)

	-- Swap sub_ability
	local sub_ability_name = event.sub_ability_name
	local main_ability_name = ability:GetAbilityName()

	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
	print("Swapped "..main_ability_name.." with " ..sub_ability_name)

end

-- Reverts back to the original model and attack type, swaps abilities, removes modifier passed
function TrueFormEnd( event )
	local caster = event.caster
	local ability = event.ability
	local modifier = event.remove_modifier_name

	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)

	-- Swap the sub_ability back to normal
	local main_ability_name = event.main_ability_name
	local sub_ability_name = ability:GetAbilityName()

	caster:SwapAbilities(sub_ability_name, main_ability_name, false, true)
	print("Swapped "..sub_ability_name.." with " ..main_ability_name)

	-- Remove modifier
	caster:RemoveModifierByName(modifier)
end


--[[Author: Noya
	Date: 09.08.2015.
	Hides all dem hats
]]
function HideWearables( event )
	local hero = event.caster
	local ability = event.ability

	hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(hero.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( event )
	local hero = event.caster

	for i,v in pairs(hero.hiddenWearables) do
		v:RemoveEffects(EF_NODRAW)
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