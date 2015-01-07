function RestoreMana( keys )
	
	local target = keys.unit
	local ability = keys.ability
	local restore_amount = ability:GetLevelSpecialValueFor("restore_amount", (ability:GetLevel() -1))
	local max_mana = target:GetMaxMana() * restore_amount / 100 
	local new_mana = target:GetMana() + max_mana

	print("test")
	print(max_mana)

	--target:GiveMana(max_mana)
	--target:RestoreMana(max_mana)

	if new_mana > target:GetMaxMana() then
		target:SetMana(target:GetMaxMana())
	else
		target:SetMana(new_mana)
	end
end

