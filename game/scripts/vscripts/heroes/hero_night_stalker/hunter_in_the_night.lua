--[[Author: Pizzalol
	Date: 11.01.2015.
	Checks if it is night time to see if it should apply the night modifier
	If it is day then it removes it if the caster has the night modifier]]
function HunterInTheNight( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier

	if not GameRules:IsDaytime() then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	else
		if caster:HasModifier(modifier) then caster:RemoveModifierByName(modifier) end
	end
end