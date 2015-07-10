--[[
	Author: Noya
	Date: 20.01.2015.
	Resets the Drunken Brawler Crit timer
]]
function DrunkenBrawlerCritReset( event )
	local caster = event.caster
	local ability = event.ability
	local last_proc = ability:GetLevelSpecialValueFor( "last_proc" , ability:GetLevel() - 1 )
	
	-- Keep track of the time of this attack
	caster.last_attack = GameRules:GetGameTime()

	-- Create a timer for this attack landed, after last_proc duration, check if this was the last attack and grant a crit
	Timers:CreateTimer(last_proc, function()
		if GameRules:GetGameTime() >= caster.last_attack + last_proc then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_drunken_brawler_guaranteed_crit", nil)
		end
	end)
end

-- Resets the Drunken Brawler Evasion timer
function DrunkenBrawlerDodgeReset( event )
	local caster = event.caster
	local ability = event.ability
	local last_proc = ability:GetLevelSpecialValueFor( "last_proc" , ability:GetLevel() - 1 )
	
	-- Keep track of the time of this attack
	caster.last_attacked = GameRules:GetGameTime()

	-- Create a timer for this attack taken or forced to dodge, after last_proc duration, check if this was the last time attacked and grant a dodge
	Timers:CreateTimer(last_proc, function() 
		if GameRules:GetGameTime() >= caster.last_attacked + last_proc then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_drunken_brawler_guaranteed_dodge", nil)
		end
	end)
end