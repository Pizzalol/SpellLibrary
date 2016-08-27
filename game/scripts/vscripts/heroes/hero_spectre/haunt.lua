--[[Author: Nightborn
	Date: August 27, 2016
]]

function HauntCast(keys)

	local caster = keys.caster
	local target = keys.target
	local unit = caster:GetUnitName()

	local sound = keys.sound
	EmitSoundOn(sound, target)

	local ability = keys.ability
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local attackDelay = ability:GetLevelSpecialValueFor( "attack_delay", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

	local illusion = CreateUnitByName(unit, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetOwner(caster)

	illusion:SetForwardVector(target:GetAbsOrigin() - illusion:GetAbsOrigin())

	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			illusionAbility:SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Set the unit as an illusion
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

	--Apply the modifier for illusion: 400 movespeed and flying pathing
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_spectre_haunt_illusion_buff", {duration = duration})

	--Apply the modifier for illusion: No attack for the first second
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_spectre_haunt_illusion_debuff", {duration = attackDelay})

	illusion:MoveToNPC(target)

	-- 10 second delayed, run once using gametime (respect pauses)
	Timers:CreateTimer({
		endTime = attackDelay, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			-- Force Illusion to attack Target
			illusion:SetForceAttackTarget(target)
		end
	})

	caster.haunting = true

	-- 10 second delayed, run once using gametime (respect pauses)
	Timers:CreateTimer({
		endTime = duration, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			caster.haunting = false
		end
	})


end



function LevelUpReality (keys)

	local caster = keys.caster
	local ability_reality = caster:FindAbilityByName("spectre_reality_datadriven")
	if ability_reality ~= nil then
		ability_reality:SetLevel(1)
	end

	caster.haunting = false

end
