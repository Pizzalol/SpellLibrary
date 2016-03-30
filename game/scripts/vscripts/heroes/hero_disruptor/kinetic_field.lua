LinkLuaModifier( "modifier_movespeed_cap_low", "libraries/modifiers/modifier_movespeed_cap_low.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Renders the formation and marker particles over the radius]]
function RenderParticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	
	-- Plays the formation sound
	EmitSoundOn(keys.sound, caster)
	
	ability.formation_particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.formation_particle, 0, point)
	ParticleManager:SetParticleControl(ability.formation_particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.formation_particle, 2, point)
	
	ability.marker_particle = ParticleManager:CreateParticle(keys.particle2, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.marker_particle, 0, point)
	ParticleManager:SetParticleControl(ability.marker_particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.marker_particle, 2, point)
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Checks if the target is facing against the field and applies an extreme slowing modifier if it is]]
function CheckPosition(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	
	-- Solves for the target's distance from the border of the field (negative is inside, positive is outside)
	local distance = (target:GetAbsOrigin() - ability.center):Length2D()
	local distance_from_border = distance - radius
	
	-- The target's angle in the world
	local target_angle = target:GetAnglesAsVector().y
	
	-- Solves for the target's angle in relation to the center of the circle in radians
	local origin_difference =  ability.center - target:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Converts the radians to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local angle_from_center = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	angle_from_center = angle_from_center + 180.0
	
	-- Checks if the target is inside the field, less than 20 units from the border, and facing it (within 90 degrees)
	if distance_from_border < 0 and math.abs(distance_from_border) <= 20 and (math.abs(target_angle - angle_from_center)<90 or math.abs(target_angle - angle_from_center)>270) then
		-- Removes the movespeed minimum
		if target:HasModifier("modifier_movespeed_cap_low") == false then
			target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {Duration = duration})
		end
		-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_kinetic_field_debuff",{})
	-- Checks if the target is outside the field, less than 30 units from the border, and facing it (within 90 degrees)
	elseif distance_from_border > 0 and math.abs(distance_from_border) <= 30 and (math.abs(target_angle - angle_from_center)>90) then
		-- Removes the movespeed minimum
		if target:HasModifier("modifier_movespeed_cap_low") == false then
			target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {Duration = duration})
		end
		-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_kinetic_field_debuff",{})
	else
		-- Removes the slowing debuffs, so the unit can move freely
		if target:HasModifier("modifier_kinetic_field_debuff") then
			target:RemoveModifierByName("modifier_kinetic_field_debuff")
			target:RemoveModifierByName("modifier_movespeed_cap_low")
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Ensures no units still have the slow modifiers after the field is gone]]
function RemoveModifiers(keys)
	local target = keys.target

	target:RemoveModifierByName("modifier_kinetic_field_debuff")
	target:RemoveModifierByName("modifier_movespeed_cap_low")
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Gives vision to the caster's team and renders the field particle]]
function GiveVision(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability:GetLevel() -1)
	local vision_duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	ability.center = target:GetAbsOrigin()
	
	AddFOWViewer(caster:GetTeam(), ability.center, vision_radius, vision_duration, false)
	
	ParticleManager:DestroyParticle(ability.formation_particle, true)
	ParticleManager:DestroyParticle(ability.marker_particle, true)
	
	ability.field_particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.field_particle, 0, ability.center)
	ParticleManager:SetParticleControl(ability.field_particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.field_particle, 2, ability.center)
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Destroys the field particle]]
function DestroyParticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	ParticleManager:DestroyParticle(ability.field_particle, true)
	-- Stops the field sound
	StopSoundEvent(keys.sound, caster)
end
