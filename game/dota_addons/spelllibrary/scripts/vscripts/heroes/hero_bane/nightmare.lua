function NightmareDamage( keys )
	
	local target = keys.target

	--Obtains target's current health and reduces if by 20 x (Nightmare Duration)
	target:SetHealth(target:GetHealth() -20)
	

	--need to apply damage if the damage turns out to be lethal (denying etc)

end

function NightmareBreak( keys )
	
	local target = keys.target
	local attacker = keys.attacker -- need to test local attacker(works) and local caster(not needed)
	local ability = keys.ability

	if target:HasModifier("modifier_nightmare_datadriven") then

		print(target:HasModifier("modifier_nightmare_aura_datadriven"))
	
		target:RemoveModifierByName("modifier_nightmare_aura_datadriven") 
		target:RemoveModifierByName("modifier_nightmare_datadriven")
		attacker:RemoveModifierByName("modifier_nightmare_aura_datadriven")		 
		--break works!! the aura's duration persists even if its removed (or its not getting removed at all?)
		ability:ApplyDataDrivenModifier(target, attacker, "modifier_nightmare_datadriven", {}) --Old:value(target,attacker)
		--transfer works properly if two targets are from the same team
		ability:ApplyDataDrivenModifier(attacker, target, "modifier_nightmare_aura_datadriven", {})
		target:Stop()
		attacker:Stop()
		--transfer doesnt work from original caster to target


	end
end


--[[TO DO:
1.Breaking the nightmare with OnAttackStart - DONE!
2.Transfering the debuff OnAttackStart to the attacker
3.Fix the transfer between enemy targets

]]


