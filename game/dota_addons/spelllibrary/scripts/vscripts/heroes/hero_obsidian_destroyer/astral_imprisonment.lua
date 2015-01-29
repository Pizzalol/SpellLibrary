--[[Astral Imprisonment stop loop sound
	Author: chrislotix
	Date: 6.1.2015.]]
function AstralImprisonmentStopSound( keys )

	local sound_name = "Hero_ObsidianDestroyer.AstralImprisonment"
	local target = keys.target

	--Stops the loop sound when the modifier ends

	StopSoundEvent(sound_name, target)
	
end

--[[Swaps the model with the given model
	Author: Pizzalol
	Date: 29.01.2015.]]
function SwapModelStart( keys )
	local target = keys.target
	local model = keys.model

	if target.target_model == nil then
		target.target_model = target:GetModelName()
	end

	target:SetOriginalModel(model)
end

--[[Reverts the model to the original
	Author: Pizzalol
	Date: 29.01.2015.]]
function SwapModelEnd( keys )
	local target = keys.target

	-- Checking for errors
	if target.target_model ~= nil then
		target:SetModel(target.target_model)
		target:SetOriginalModel(target.target_model)
	end
end

--[[Author: Noya
	Used by: Pizzalol
	Date: 29.01.2015.
	Hides all dem hats
]]
function HideWearables( event )
	local hero = event.target
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
	Date: 29.01.2015.
	Shows the hidden hero wearables
]]
function ShowWearables( event )
	local hero = event.target
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