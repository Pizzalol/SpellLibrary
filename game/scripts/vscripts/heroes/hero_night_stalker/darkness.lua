--[[Author:Pizzalol
	Date: 11.01.2015.
	Makes it night time for the duration of Darkness]]
--[[daytime 0-2 min is 0.25-0.49
	daytime 2-4 min is 0.50-0.74
	night 0-2 min is 0.75-0.99
	night 2-4 min is 0.00-0.24

	1 second ~ 0.0020833333]]
function Darkness( keys )
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))

	-- Time variables
	local time_flow = 0.0020833333
	local time_elapsed = 0
	-- Calculating what time of the day will it be after Darkness ends
	local start_time_of_day = GameRules:GetTimeOfDay()
	local end_time_of_day = start_time_of_day + duration * time_flow

	if end_time_of_day >= 1 then end_time_of_day = end_time_of_day - 1 end

	-- Setting it to the middle of the night
	GameRules:SetTimeOfDay(0)

	-- Using a timer to keep the time as middle of the night and once Darkness is over, normal day resumes
	Timers:CreateTimer(1, function()
		if time_elapsed < duration then
			GameRules:SetTimeOfDay(0)
			time_elapsed = time_elapsed + 1
			return 1
		else
			GameRules:SetTimeOfDay(end_time_of_day)
			return nil
		end
	end)
end

--[[Author: Pizzalol
	Date: 11.01.2015.
	Saves the original vision of the target and then reduces it]]
function ReduceVision( keys )
	local target = keys.target
	local ability = keys.ability
	local blind_percentage = ability:GetLevelSpecialValueFor("blind_percentage", (ability:GetLevel() - 1)) / -100

	target.original_vision = target:GetBaseNightTimeVisionRange()

	target:SetNightTimeVisionRange(target.original_vision * (1 - blind_percentage))
end

--[[Author: Pizzalol
	Date: 11.01.2015.
	Reverts the vision back to what it was]]
function RevertVision( keys )
	local target = keys.target

	target:SetNightTimeVisionRange(target.original_vision)
end