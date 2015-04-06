--[[Author: Pizzalol
	Date: 05.04.2015.
	Checks what the target is and then decides what kind of teleport action to perform]]
function TestOfFaithTeleportTarget( keys )
	local caster = keys.caster
	local caster_team = caster:GetTeamNumber()
	local caster_location = caster:GetAbsOrigin()
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local teleport_delay = ability:GetLevelSpecialValueFor("hero_teleport_delay", ability_level) 
	local sound_tp_out = keys.sound_tp_out
	local sound_tp_in = keys.sound_tp_in
	local teleport_modifier = keys.teleport_modifier
	local teleport_particle = keys.teleport_particle

	-- If the target is a creep under the casters control then teleport it instantly to the specified point
	if not target:IsHero() and target:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
		-- Play the teleport particle
		local particle = ParticleManager:CreateParticle(teleport_particle, PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle) 

		-- Play the teleport sounds
		EmitSoundOn(sound_tp_out, target) 
		EmitSoundOn(sound_tp_in, target) 

		-- Specified point
		target:SetAbsOrigin(Vector(0,0,0))
		target:AddNewModifier(caster, nil, "modifier_phased", {duration = 0.03})
	-- If the target is the caster then find all the units under casters control and apply the teleport delay modifier	
	elseif target == caster then
		-- Targeting variables
		local target_teams = DOTA_UNIT_TARGET_TEAM_FRIENDLY
		local target_types = DOTA_UNIT_TARGET_BASIC
		local target_flags = DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED

		local units = FindUnitsInRadius(caster_team, caster_location, nil, 9000, target_teams, target_types, target_flags, FIND_CLOSEST, false)

		for _,unit in ipairs(units) do
			-- Check if the found unit is under the casters control
			if (unit:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and unit ~= caster) then
				ability:ApplyDataDrivenModifier(caster, unit, teleport_modifier, {Duration = teleport_delay})
			end
		end
	else
		-- If the target is not the caster of a creep controlled by the caster then apply the teleport delay
		ability:ApplyDataDrivenModifier(caster, target, teleport_modifier, {Duration = teleport_delay})
	end
end

function TestOfFaithStopSound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end

--[[Author: Pizzalol
	Date: 05.04.2015.
	Checks where the targeted unit needs to be teleported to]]
function TestOfFaithTeleport( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()

	-- If the target is a unit under the casters control then teleport it to the caster
	if not target:IsHero() and target:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
		target:SetAbsOrigin(caster_location + RandomVector(100)) 
	else
		-- Otherwise teleport it to a specific location
		target:SetAbsOrigin(Vector(0,0,0))
	end
	target:AddNewModifier(caster, nil, "modifier_phased", {Duration = 0.03})
end

--[[
	Author: Noya
	Used by: Pizzalol
	Date: 06.04.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end