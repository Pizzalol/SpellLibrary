--[[ ============================================================================================================
	Author: Rook
	Date: January 25, 2015
	Called when Healing Salve is cast.  Reduces the charges on the item by one.
================================================================================================================= ]]
function item_flask_datadriven_on_spell_start(keys)
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
	Called regularly while Healing Salve's effect is on a unit.  Restores their health.
	Additional parameters: keys.RegenInterval, keys.BuffDuration, keys.TotalHealthRegen
================================================================================================================= ]]
function modifier_item_flask_datadriven_active_on_interval_think(keys)
	keys.target:Heal(keys.TotalHealthRegen / (keys.BuffDuration / keys.RegenInterval), keys.caster)
end