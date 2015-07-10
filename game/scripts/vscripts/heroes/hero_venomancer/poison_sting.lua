--[[ ============================================================================================================
	Author: Rook
	Date: June 6, 2015
	Called when one of Venomancer's autoattacks applies a Poison Sting debuff to a unit.  Removes the movement slow
	from any of Venomancer's Plague Wards for the duration of the debuff.
================================================================================================================= ]]
function modifier_poison_sting_debuff_datadriven_on_created(keys)
	if keys.target:HasModifier("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed") then
		keys.target:SetModifierStackCount("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed", nil, 0)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: June 6, 2015
	Called when a Poison Sting debuff created by one of Venomancer's autoattacks is removed.  Reapplies the movement
	slow from any of Venomancer's Plague Wards, if such a modifier exists on the target.
	Known bugs:
		The stack count of the movement speed modifier is hardcoded.  Once we become able to determine the caster of
		a modifier, we can use the movement speed slow from the current level of Poison Sting.
================================================================================================================= ]]
function modifier_poison_sting_debuff_datadriven_on_destroy(keys)
	if keys.target:HasModifier("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed") then
		keys.target:SetModifierStackCount("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed", nil, 11)
		
		--Once we become able to determine the caster of a modifier, we can modify the code below to determine the correct
		--the movement speed slow from the current level of Poison Sting.
		--[[local poison_sting_ability = keys.attacker.venomancer_plague_ward_parent:FindAbilityByName("venomancer_poison_sting_datadriven")
		if poison_sting_ability == nil then
			poison_sting_ability = keys.attacker.venomancer_plague_ward_parent:FindAbilityByName("venomancer_poison_sting")
		end
	
		if poison_sting_ability ~= nil then
			local poison_sting_level = poison_sting_ability:GetLevel()
			
			if poison_sting_level > 0 then
				
				keys.target:SetModifierStackCount("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed", nil, math.abs(poison_sting_ability:GetLevelSpecialValueFor("movement_speed", poison_sting_level - 1)))
			end
		end]]
	end
end