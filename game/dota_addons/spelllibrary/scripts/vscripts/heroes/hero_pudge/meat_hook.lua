hookTable = hookTable or {}

--[[Author: Pizzalol
	Date: 02.01.2015.
	Upon hitting a unit it checks if its a friendly unit or an enemy one and then pulls it back]]
function RetractMeatHook( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilityDamage() 
	local hookSpeed = keys.speed * 0.03
	local casterLocation = caster:GetAbsOrigin()
	local targetLocation = target:GetAbsOrigin() 
	local distance = (targetLocation - casterLocation):Length2D()
	local meat_hook_modifier = keys.meat_hook_modifier
	local sound_extend = keys.sound_extend
	local sound_retract = keys.sound_retract
	local sound_retract_stop = keys.sound_retract_stop

	StopSoundEvent(sound_extend, caster)

	if target:GetTeam() ~= caster:GetTeam() then
		local damageTable = {}
		damageTable.attacker = caster
		damageTable.victim = target
		damageTable.damage_type = DAMAGE_TYPE_PURE
		damageTable.ability = ability
		damageTable.damage = damage

		ApplyDamage(damageTable)
	end

	hookTable[caster].bHitUnit = true
	

	Timers:CreateTimer(0, function()
		targetLocation = casterLocation + (targetLocation - casterLocation):Normalized() * (distance - hookSpeed)
		target:SetAbsOrigin(targetLocation)

		distance = (targetLocation - casterLocation):Length2D()

		if distance > 100 then
			return 0.03
		else
			FindClearSpaceForUnit(target, targetLocation, false)
			target:RemoveModifierByName(meat_hook_modifier)
			hookTable[caster].bHitUnit = false
			StopSoundEvent(sound_retract, caster)
			EmitSoundOn(sound_retract_stop, caster)
		end

		end)
end

-- creates a dummy, saves it , moves it along, if it reaches the end and the endcheck variable
-- is false then it deletes the dummy otherwise it moves it back
function LaunchMeatHook( keys )
	local caster = keys.caster
	local ability = keys.ability
	local casterLocation = caster:GetAbsOrigin()
	local dummyLocation = casterLocation
	local dummy = CreateUnitByName("npc_dummy_blank", dummyLocation, false, caster, caster, caster:GetTeam())
	local targetPoint = keys.target_points[1]
	local hookSpeed = keys.speed * 0.03
	local model = keys.model_name
	local dummyModifier = "modifier_meat_hook_dummy_datadriven"
	local travel_distance = ability:GetLevelSpecialValueFor("hook_distance", (ability:GetLevel() - 1))
	local distance_traveled = 0
	local chain_particle = "particles/units/heroes/hero_pudge/pudge_meathook_chain.vpcf"
	local sound_extend = keys.sound_extend

	local particle = ParticleManager:CreateParticle(chain_particle, PATTACH_RENDERORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, 5, "attach_attack1", casterLocation, false)
	ParticleManager:SetParticleControlEnt(particle, 6, dummy, 5, "attach_hitloc", dummyLocation, false)

	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, dummy, dummyModifier, {}) 

	local direction = (targetPoint - casterLocation):Normalized()
	dummy:SetForwardVector(direction)

	dummyLocation = dummyLocation + Vector(0,0,125)

	hookTable[caster] = hookTable[caster] or {}
	hookTable[caster].dummy = dummy
	hookTable[caster].bHitUnit = false

	Timers:CreateTimer(0.03, function()
		dummyLocation = dummyLocation + direction * hookSpeed
		dummy:SetAbsOrigin(dummyLocation)
		distance_traveled = distance_traveled + hookSpeed

		if distance_traveled < travel_distance and not hookTable[caster].bHitUnit then
			--print("HELLO I AM TRUE")
			return 0.03
		else
			Timers:CreateTimer(0,function()
				distance_traveled = distance_traveled - hookSpeed
				dummyLocation = casterLocation + Vector(0,0,125) + direction * distance_traveled
				dummy:SetAbsOrigin(dummyLocation)

				if distance_traveled > 100 then
					return 0.03
				else
					StopSoundEvent(sound_extend, caster)
					ParticleManager:DestroyParticle(particle, true)
					dummy:RemoveSelf()

				end
				end)
		end

		end)

	

end