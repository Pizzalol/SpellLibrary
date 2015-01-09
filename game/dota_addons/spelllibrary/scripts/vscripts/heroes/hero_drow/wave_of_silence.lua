--[[
	CHANGELIST:
	09.01.2015 - Change the file into .lua extension
]]

--[[
	Author: kritth
	Date: 09.01.2015
	Knockback enemies in the line accordingly to the distance
]]
function modifier_wave_of_silence_knockback( keys )
	local vCaster = keys.caster:GetAbsOrigin()
	local vTarget = keys.target:GetAbsOrigin()
	local len = ( vTarget - vCaster ):Length2D()
	len = keys.distance - keys.distance * ( len / keys.range )
	local knockbackModifierTable =
	{
		should_stun = 0,
		knockback_duration = keys.duration,
		duration = keys.duration,
		knockback_distance = len,
		knockback_height = 0,
		center_x = keys.caster:GetAbsOrigin().x,
		center_y = keys.caster:GetAbsOrigin().y,
		center_z = keys.caster:GetAbsOrigin().z
	}
	keys.target:AddNewModifier( keys.caster, nil, "modifier_knockback", knockbackModifierTable )
end
