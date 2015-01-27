--[[ ============================================================================================================
	Author: Rook
	Date: January 25, 2015
	Called when Clarity is cast.  Reduces the charges on the item by one.
================================================================================================================= ]]
function item_clarity_datadriven_on_spell_start(keys)
	--Reduce the charges left on the item by 1.  Remove the item if there are no charges left.
	local new_charges = keys.ability:GetCurrentCharges() - 1
	if new_charges <= 0 then
		keys.caster:RemoveItem(keys.ability)
	else  --new_charges > 0 
		keys.ability:SetCurrentCharges(new_charges)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 25, 2015
	Called regularly while Clarity's effect is on a unit.  Restores their mana.
	Additional parameters: keys.RegenInterval, keys.BuffDuration, keys.TotalManaRegen
================================================================================================================= ]]
function modifier_item_clarity_datadriven_active_on_interval_think(keys)
	keys.target:GiveMana(keys.TotalManaRegen / (keys.BuffDuration / keys.RegenInterval))
end