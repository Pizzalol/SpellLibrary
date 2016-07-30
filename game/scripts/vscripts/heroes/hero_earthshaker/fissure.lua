LinkLuaModifier( "modifier_movespeed_cap_low", "libraries/modifiers/modifier_movespeed_cap_low.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: YOLOSPAGHETTI
	Date: July 30, 2016
	Renders the fissure particle and applies all the instant aoe effects around the fissure]]
function CreateFissure(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local fissure_range = ability:GetLevelSpecialValueFor("fissure_range", (ability:GetLevel() -1))
	local fissure_radius = ability:GetLevelSpecialValueFor("fissure_radius", (ability:GetLevel() -1))
	local fissure_duration = ability:GetLevelSpecialValueFor("fissure_duration", (ability:GetLevel() -1))
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() -1))
	local width = ability:GetLevelSpecialValueFor("width", (ability:GetLevel() -1))
	local offset = ability:GetLevelSpecialValueFor("offset", (ability:GetLevel() -1))
	
	-- Position and direction variables
	local direction = caster:GetForwardVector()
	local startPos = caster:GetAbsOrigin() + direction * offset
	local endPos = caster:GetAbsOrigin() + direction * fissure_range
	
	-- Renders the fissure particle in a line
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, startPos)
	ParticleManager:SetParticleControl(particle, 1, endPos)
	ParticleManager:SetParticleControl(particle, 2, Vector(fissure_duration, 0, 0 ))
	
	-- Units to be moved by the fissure
	local units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, width, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
	
	-- Loops through targets
	for i,unit in ipairs(units) do
		-- Does not move the caster
		if unit ~= caster then
			-- The target's distance and direction from the front of the fissure
			local target_vector_distance = unit:GetAbsOrigin() - startPos
			local target_distance = (target_vector_distance):Length2D()
			local target_direction = (target_vector_distance):Normalized()
		
			-- Get the target's angle in relation to the front of the fissure
			local target_angle_radian = math.atan2(target_direction.y, target_direction.x)
			
			-- Gets the direction of the fissure in the world
			local fissure_angle_radian = math.atan2(direction.y, direction.x)
		
			-- Gets the distance from the front of the fissure to the point on the fissure perpendicular to the target
			local perpen_distance = math.abs(math.cos(fissure_angle_radian - target_angle_radian)) * target_distance
			
			-- Gets the position of the the perpendicular point
			local perpen_position = startPos + perpen_distance * direction
		
			-- Gets the distance and direction the target will move
			local motion_vector_distance = unit:GetAbsOrigin() - perpen_position
			local motion_distance = width
			local motion_direction = (motion_vector_distance):Normalized()
		
			-- Moves the target
			unit:SetAbsOrigin(unit:GetAbsOrigin() + motion_distance * motion_direction)
		end
	end
	
	-- Units to be stunned and damaged by the fissure
	units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, fissure_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
	
	-- Loops through the targets
	for j,unit in ipairs(units) do
		-- Applies the stun modifier to the target
		unit:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
		-- Applies the damage to the target
		ApplyDamage({victim = unit, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
	end
	
	ability.startPos = startPos
	ability.endPos = endPos
	ability.direction = direction
end




--[[Author: YOLOSPAGHETTI
	Date: July 30, 2016
	Checks if the target is facing against the fissure and applies an extreme slowing modifier if it is]]
function CheckPosition(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("fissure_range", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("fissure_duration", ability:GetLevel() -1)
	local width = ability:GetLevelSpecialValueFor("width", ability:GetLevel() -1)
	
	-- Gets the direction variable
	local direction = ability.direction
	
	-- Sets a buffer around the front and the back of the fissure
	local startPos = ability.startPos - direction * 20
	local endPos = ability.endPos + direction * 20
	
	-- Units within range of the fissure block
	local units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, width + 20, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
	
	-- Loops through the targets
	for i,unit in ipairs(units) do
		-- Ensures calculations are only done once per unit
		if target == unit then
			-- The target's distance and direction from the front of the fissure
			local target_vector_distance = target:GetAbsOrigin() - ability.startPos
			local target_distance = (target_vector_distance):Length2D()
			local target_direction = (target_vector_distance):Normalized()
	
			-- Get the target's angle in relation to the front of the fissure
			local target_angle_radian = math.atan2(target_direction.y, target_direction.x)
			
			-- Converts to degrees (0-360)
			local target_angle_from_fissure = math.deg(target_angle_radian) + 180
		
			-- Get's the direction of the fissure in the world
			local fissure_angle_radian = math.atan2(direction.y, direction.x)
			
			-- Converts to degrees (0-360)
			local fissure_angle = math.deg(fissure_angle_radian) + 180
			
			-- Gets the distance from the front of the fissure to the point on the fissure perpendicular to the target
			local perpen_distance = math.abs(math.sin(fissure_angle_radian - target_angle_radian)) * target_distance
	
			-- The angle the target's facing in the world
			local target_angle = target:GetAnglesAsVector().y
			
			-- Checks if the target is on the right of the fissure (from the front perspective), less than 20 units from it, and facing it (within 90 degrees)
			if (target_angle_from_fissure - fissure_angle) < 0 and perpen_distance <= width + 20 and ((target_angle - fissure_angle < 0 and target_angle - fissure_angle > -180) or (target_angle - fissure_angle > 180)) then
				-- Removes the movespeed minimum
				if target:HasModifier("modifier_movespeed_cap_low") == false then
					target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {Duration = duration})
				end
				-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
				ability:ApplyDataDrivenModifier(caster, target, "modifier_fissure_block",{})
			-- Checks if the target is on the left of the fissure, less than 20 units from it, and facing it (within 90 degrees)
			elseif (target_angle_from_fissure - fissure_angle) > 0 and perpen_distance <= width + 20 and ((target_angle - fissure_angle > 0 and target_angle - fissure_angle < 180) or (target_angle - fissure_angle < -180)) then
				-- Removes the movespeed minimum
				if target:HasModifier("modifier_movespeed_cap_low") == false then
					target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {Duration = duration})
				end
				-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
				ability:ApplyDataDrivenModifier(caster, target, "modifier_fissure_block",{})
			else
				-- Removes the slowing debuffs, so the unit can move freely
				if target:HasModifier("modifier_fissure_block") then
					target:RemoveModifierByName("modifier_fissure_block")
					target:RemoveModifierByName("modifier_movespeed_cap_low")
				end
			end
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: July 30, 2016
	Ensures no units still have the slow modifiers when the fissure is gone]]
function RemoveModifiers(keys)
	local target = keys.target

	target:RemoveModifierByName("modifier_fissure_block")
	target:RemoveModifierByName("modifier_movespeed_cap_low")
end
