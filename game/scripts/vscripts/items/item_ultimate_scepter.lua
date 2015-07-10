--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when Aghanim's Scepter is purchased or picked up.  Applies the stock Aghanim's Scepter modifier, which
	is used internally to upgrade spells and such.
================================================================================================================= ]]
function modifier_item_ultimate_scepter_datadriven_on_created(keys)
	if not keys.caster:HasModifier("modifier_item_ultimate_scepter") then
		keys.caster:AddNewModifier(keys.caster, nil, "modifier_item_ultimate_scepter", {duration = -1})
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when Aghanim's Scepter is sold or dropped.  Removes the stock Aghanim's Scepter modifier if no other 
	Aghanim's Scepters exist in the player's inventory.
================================================================================================================= ]]
function modifier_item_ultimate_scepter_datadriven_on_destroy(keys)
	local num_scepters_in_inventory = 0

	for i=0, 5, 1 do  --Search for Aghanim's Scepters in the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			local item_name = current_item:GetName()
			
			if item_name == "item_ultimate_scepter_datadriven" then
				num_scepters_in_inventory = num_scepters_in_inventory + 1
			end
		end
	end

	--Remove the stock Aghanim's Scepter modifier if the player no longer has a scepter in their inventory.
	if num_scepters_in_inventory == 0 and keys.caster:HasModifier("modifier_item_ultimate_scepter") then
		keys.caster:RemoveModifierByName("modifier_item_ultimate_scepter")
	end
end