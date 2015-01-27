--[[ ============================================================================================================
	Author: Rook
	Date: January 25, 2015
	Called when Magic Stick is cast.  Restores health and mana to the caster.
	Additional parameters: keys.RestorePerCharge
================================================================================================================= ]]
function item_magic_stick_datadriven_on_spell_start(keys)
	keys.caster:EmitSound("DOTA_Item.MagicStick.Activate")
	
	local amount_to_restore = keys.ability:GetCurrentCharges() * keys.RestorePerCharge
	keys.caster:Heal(amount_to_restore, keys.caster)
	keys.caster:GiveMana(amount_to_restore)
	
	keys.ability:SetCurrentCharges(0)
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 25, 2015
	Called when an enemy hero that is affected by Magic Stick's hidden aura executes an ability.
	Increases the charges on the item if the ability procs Magic Stick and the affected unit is visible.
	Additional parameters: keys.MaxCharges
	Known Bugs: Because OnAbilityExecuted does not pass in information about the ability that was just executed,
	this code cannot use ProcsMagicStick() to determine if Magic Stick should gain a charge.  For now, every cast
	ability awards a charge.
================================================================================================================= ]]
function modifier_item_magic_stick_datadriven_aura_on_ability_executed(keys)
	if keys.caster:GetTeam() ~= keys.unit:GetTeam() and keys.caster:CanEntityBeSeenByMyTeam(keys.unit) then
		 --Search for a Magic Stick in the aura creator's inventory.  If there are multiple Magic Sticks in the player's inventory,
		 --the oldest one that's not full receives a charge.
		local oldest_unfilled_stick = nil
		
		for i=0, 5, 1 do
			local current_item = keys.caster:GetItemInSlot(i)
			if current_item ~= nil and current_item:GetName() == "item_magic_stick_datadriven" and current_item:GetCurrentCharges() < keys.MaxCharges then
				if oldest_unfilled_stick == nil or current_item:GetEntityIndex() < oldest_unfilled_stick:GetEntityIndex() then
					oldest_unfilled_stick = current_item
				end
			end
		end
		
		--Increment the Magic Wand's current charges by 1.
		if oldest_unfilled_stick ~= nil then
			oldest_unfilled_stick:SetCurrentCharges(oldest_unfilled_stick:GetCurrentCharges() + 1)
		end
	end
end