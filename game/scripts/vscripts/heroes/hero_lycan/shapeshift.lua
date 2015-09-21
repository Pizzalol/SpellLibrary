--[[Author: Pizzalol
	Date: 24.03.2015.
	Applies the haste modifier if the target is owned by the caster]]
function ShapeshiftHaste( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local modifier = keys.modifier
	local duration = ability:GetLevelSpecialValueFor("aura_interval", ability_level)
	local caster_owner = caster:GetPlayerOwner() 
	local target_owner = target:GetPlayerOwner() 

	-- If they are the same then apply the modifier
	if caster_owner == target_owner then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {Duration = duration})
		-- We apply the bloodseeker thirst modifier to remove the movement speed limit
		target:AddNewModifier(caster, nil, "modifier_bloodseeker_thirst", {Duration = duration})
	end
end

--[[Author: Pizzalol/Noya
	Date: 12.01.2015.
	Swaps the caster model]]
function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model

	-- Saves the original model
	if caster.caster_model == nil then
		caster.caster_model = caster:GetModelName()
	end

	-- Sets the new model and projectile
	caster:SetOriginalModel(model)
end

--[[Author: Pizzalol/Noya
	Date: 12.01.2015.
	Reverts back to the original model]]
function ModelSwapEnd( keys )
	local caster = keys.caster

	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
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