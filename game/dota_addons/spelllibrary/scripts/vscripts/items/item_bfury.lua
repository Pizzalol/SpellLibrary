--[[ ============================================================================================================
	Author: Rook
	Date: February 2, 2015
	Called when a Battle Fury is acquired.  Grants the cleave modifier if the caster is a melee hero.
================================================================================================================= ]]
function modifier_item_bfury_datadriven_on_created(keys)
	if not keys.caster:IsRangedAttacker() then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_bfury_datadriven_cleave", {duration = -1})
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 2, 2015
	Called when a Battle Fury is removed from the caster's inventory.  Removes a cleave modifier if they are a melee hero.
================================================================================================================= ]]
function modifier_item_bfury_datadriven_on_destroy(keys)
	if not keys.caster:IsRangedAttacker() then
		keys.caster:RemoveModifierByName("modifier_item_bfury_datadriven_cleave")
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 2, 2015
	Called regularly while the caster has a Battle Fury in their inventory.  If the caster has switched from ranged
	to melee, give them cleave modifier(s).
================================================================================================================= ]]
function modifier_item_bfury_datadriven_on_interval_think(keys)
	if not keys.caster:IsRangedAttacker() and not keys.caster:HasModifier("modifier_item_bfury_datadriven_cleave") then
		for i=0, 5, 1 do
			local current_item = keys.caster:GetItemInSlot(i)
			if current_item ~= nil then
				if current_item:GetName() == "item_bfury_datadriven" then
					keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_bfury_datadriven_cleave", {duration = -1})
				end
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 2, 2015
	Called regularly while the caster has at least one cleave modifier from Battle Fury.  If the caster is no longer
	melee (which would be the case on, for example, Troll Warlord), remove the cleave modifiers from the caster.
================================================================================================================= ]]
function modifier_item_bfury_datadriven_cleave_on_interval_think(keys)
	if keys.caster:IsRangedAttacker() then
		while keys.caster:HasModifier("modifier_item_bfury_datadriven_cleave") do
			keys.caster:RemoveModifierByName("modifier_item_bfury_datadriven_cleave")
		end
	end
end