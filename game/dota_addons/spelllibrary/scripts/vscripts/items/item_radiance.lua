--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	A helper method that switches the keys.ability item to one with the inputted name.
================================================================================================================= ]]
function swap_to_item(keys, ItemName)
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item == nil then
			keys.caster:AddItem(CreateItem("item_dummy", keys.caster, keys.caster))
		end
	end
	
	keys.caster:RemoveItem(keys.ability)
	keys.caster:AddItem(CreateItem(ItemName, keys.caster, keys.caster))  --This should be put into the same slot that the removed item was in.
	
	for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_dummy_datadriven" then
				keys.caster:RemoveItem(current_item)
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	Called regularly while Radiance's aura is affecting a unit.  Damages them.
	Additional parameters: keys.AuraDamageInterval and keys.AuraDamagePerSecond
================================================================================================================= ]]
function modifier_item_radiance_datadriven_aura_on_interval_think(keys)
	local damage_to_deal = keys.AuraDamagePerSecond * keys.AuraDamageInterval   --This gives us the damage per interval.
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage_to_deal, damage_type = DAMAGE_TYPE_MAGICAL,})
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	Called when Radiance (active) is cast.  Swaps the item to Radiance (inactive).
================================================================================================================= ]]
function item_radiance_datadriven_on_spell_start(keys)
	swap_to_item(keys, "item_radiance_inactive_datadriven")
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	Called when Radiance (inactive) is cast.  Swaps the item to Radiance (active).
================================================================================================================= ]]
function item_radiance_inactive_datadriven_on_spell_start(keys)
	swap_to_item(keys, "item_radiance_datadriven")
end