--[[Astral Imprisonment stop loop sound and show the model again
	Author: chrislotix
	Date: 6.1.2015.]]
function AstralImprisonmentEnd( keys )

	local sound_name = "Hero_ObsidianDestroyer.AstralImprisonment"
	local target = keys.target

	--Stops the loop sound when the modifier ends

	StopSoundEvent(sound_name, target)

	target:RemoveNoDraw()	
end

--[[Author: Pizzalol
	Date: 27.04.2015.
	Hides the model for the duration of Astral Imprisonment]]
function AstralImprisonmentStart( keys )
	local target = keys.target

	target:AddNoDraw()
end