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
	Used by: Pizzalol
	Date: 24.03.2015.
	Hides all dem hats
	]]
function HideWearables( event )
	local hero = event.caster
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	print("Hiding Wearables")

	--hero:AddNoDraw() -- Doesn't work on classname dota_item_wearable
	hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
	hero.hiddenWearables = {} -- Keep every wearable handle in a table, as its way better to iterate than in the MovePeer system
	
	local model = hero:FirstMoveChild()

	while model ~= nil do
		if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
			local modelName = model:GetModelName()
			if string.find(modelName, "invisiblebox") == nil then
				-- Add the original model name to revert later
				table.insert(hero.wearableNames,modelName)
				print("Hidden "..modelName.."")
				-- Set model invisible
				model:SetModel("models/development/invisiblebox.vmdl")
				table.insert(hero.hiddenWearables,model)
			end
		end

		model = model:NextMovePeer()
		if model ~= nil then
			print("Next Peer:" .. model:GetModelName())
		end
	end
end

--[[Author: Noya
	Used by: Pizzalol
	Date: 24.03.2015.
	Shows the hidden hero wearables
	]]
function ShowWearables( event )
	local hero = event.caster
	print("Showing Wearables on ".. hero:GetModelName())
	-- Iterate on both tables to set each item back to their original modelName
	for i,v in ipairs(hero.hiddenWearables) do
		for index,modelName in ipairs(hero.wearableNames) do
			if i==index then
				print("Changed "..v:GetModelName().. " back to "..modelName)
				v:SetModel(modelName)
			end
		end
	end
end