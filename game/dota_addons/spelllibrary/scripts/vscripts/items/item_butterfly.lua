--[[ ============================================================================================================
	Author: Rook
	Date: February 1, 2015
	Called when Butterfly is cast.  Removes the evasion from all Butterflies in the player's inventory and replaces
	it with a single instance of bonus movespeed.
================================================================================================================= ]]
function item_butterfly_datadriven_on_spell_start(keys)
	--Remove all evasion granted by Butterflies in the caster's inventory.
	while keys.caster:HasModifier("modifier_item_butterfly_datadriven_evasion") do
		keys.caster:RemoveModifierByName("modifier_item_butterfly_datadriven_evasion")
	end

	keys.caster:EmitSound("DOTA_Item.Butterfly")
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_butterfly_datadriven_movespeed", nil)
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 1, 2015
	Called when the movespeed active modifier expires.	Gives the caster has a stack of evasion for every 
	Butterfly in their inventory.
================================================================================================================= ]]
function modifier_item_butterfly_datadriven_movespeed_on_destroy(keys)
	if not keys.caster:HasModifier("modifier_item_butterfly_datadriven_movespeed") then
		--Reset all evasion granted by Butterflies in the caster's inventory before adding it back, just to be sure we end up with the right amount.
		while keys.caster:HasModifier("modifier_item_butterfly_datadriven_evasion") do
			keys.caster:RemoveModifierByName("modifier_item_butterfly_datadriven_evasion")
		end

		for i=0, 5, 1 do
			local current_item = keys.caster:GetItemInSlot(i)
			if current_item ~= nil then
				if current_item:GetName() == "item_butterfly_datadriven" then
					keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_butterfly_datadriven_evasion", {duration = -1})
				end
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 1, 2015
	Called when a Butterfly is acquired.  Adds an additional evasion modifier if Butterfly hasn't been cast recently.
================================================================================================================= ]]
function modifier_item_butterfly_datadriven_on_created(keys)
	if not keys.caster:HasModifier("modifier_item_butterfly_datadriven_movespeed") then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_butterfly_datadriven_evasion", {duration = -1})
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 1, 2015
	Called when a Butterfly is dropped, sold, etc..  Remove an evasion modifier if Butterfly hasn't been cast recently.
================================================================================================================= ]]
function modifier_item_butterfly_datadriven_on_destroy(keys)
	if not keys.caster:HasModifier("modifier_item_butterfly_datadriven_movespeed") then
		keys.caster:RemoveModifierByName("modifier_item_butterfly_datadriven_evasion")
	end
end