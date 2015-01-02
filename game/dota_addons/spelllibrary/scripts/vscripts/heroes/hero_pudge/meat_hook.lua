--[[Author: Pizzalol
	Date: 02.01.2015.
	Upon hitting a unit it checks if its a friendly unit or an enemy one and then pulls it back]]
function MeatHook( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilityDamage() 
	local hookSpeed = keys.speed * 0.03
	local casterLocation = caster:GetAbsOrigin()
	local targetLocation = target:GetAbsOrigin() 
	local distance = (targetLocation - casterLocation):Length2D()

	if target:GetTeam() ~= caster:GetTeam() then
		local damageTable = {}
		damageTable.attacker = caster
		damageTable.victim = target
		damageTable.damage_type = DAMAGE_TYPE_PURE
		damageTable.ability = ability
		damageTable.damage = damage

		ApplyDamage(damageTable)
	end
	

	Timers:CreateTimer(0, function()
		targetLocation = casterLocation + (targetLocation - casterLocation):Normalized() * (distance - hookSpeed)
		target:SetAbsOrigin(targetLocation)

		distance = (targetLocation - casterLocation):Length2D()

		if distance > 100 then
			return 0.03
		else
			FindClearSpaceForUnit(target, targetLocation, false)
		end

		end)



	
end