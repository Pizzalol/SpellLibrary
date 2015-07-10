particle_names = {base = "particles/units/heroes/hero_luna/luna_base_attack.vpcf"}
projectile_speeds = {base = 900}

--[[
	author: jacklarnes
	email: christucket@gmail.com
	reddit: /u/jacklarnes
	Date: 03.04.2015.

	Much help from Noya and BMD
]]

--[[
	possible concerns that i haven't tested:
	  attacking your allied hero (from spells like WW ultimate)
	  i think if you try to deny an allied creep (or hero) it'll bounce to further allied units... 
	    not sure if desired results, fairly easy to "fix" though, just change the team number of the dummy unit to always be the enemy of the hero
]]



-- this finds the units particle infomation, if they're melee then it'll just use lunas default glaives
-- the results are stored in partile_names and projectile_speeds so it doesn't have to reload the KV file each time
function findProjectileInfo(class_name)
	if particle_names[class_name] ~= nil then
		return particle_names[class_name], projectile_speeds[class_name]
	end

	kv_heroes = LoadKeyValues("scripts/npc/npc_heroes.txt")
	kv_hero = kv_heroes[class_name]

	if kv_hero["ProjectileModel"] ~= nil and kv_hero["ProjectileModel"] ~= "" then
		particle_names[class_name] = kv_hero["ProjectileModel"]
		projectile_speeds[class_name] = kv_hero["ProjectileSpeed"]
	else
		particle_names[class_name] = particle_names["base"]
		projectile_speeds[class_name] = projectile_speeds["base"]
	end

	return particle_names[class_name], projectile_speeds[class_name]
end


function moon_glaive_start_create_dummy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local dummy = CreateUnitByName( "npc_dummy_blank", target:GetAbsOrigin(), false, caster, caster, target:GetTeamNumber() )
	dummy:AddAbility("luna_moon_glaive_dummy_datadriven")
	dummy:FindAbilityByName("luna_moon_glaive_dummy_datadriven"):ApplyDataDrivenModifier( caster, dummy, "modifier_moon_glaive_dummy_unit", {} )
end



function moon_glaive_dummy_created( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- if it's first bounce then we need to initialize the ability variables since we're dealing with a dummy unit
	-- else we apply damage to the target since it'll be the second bounce
	local first = false
	if caster:GetOwner():GetClassname() == "player" then
		local unit_ability = caster:FindAbilityByName("luna_moon_glaive_datadriven")

		ability.damage = caster:GetAverageTrueAttackDamage()
		ability.bounceTable = {}
		ability.bounceCount = 1
		ability.maxBounces = unit_ability:GetLevelSpecialValueFor("bounces", unit_ability:GetLevel() - 1)
		ability.bounceRange = unit_ability:GetLevelSpecialValueFor("range", unit_ability:GetLevel() - 1)
		ability.dmgMultiplier = unit_ability:GetLevelSpecialValueFor("damage_reduction_percent", unit_ability:GetLevel() - 1) / 100

		ability.particle_name, ability.projectile_speed = findProjectileInfo(caster:GetClassname())
		first = true
	else
		local damageTable = {
						victim = ability.projectileTo,
						attacker = caster:GetOwner(),
						damage = ability.damage * (1 - ability.dmgMultiplier),
						damage_type = DAMAGE_TYPE_PHYSICAL} -- change to physical
		ApplyDamage(damageTable)

		ability.damage = ability.damage * (1 - ability.dmgMultiplier)
	end

	if ability.bounceCount > ability.maxBounces then
		killDummy(caster, target)
		return
	end

	local unitsNearTarget = FindUnitsInRadius(target:GetTeamNumber(),
                            target:GetAbsOrigin(),
                            nil,
                            ability.bounceRange,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_MECHANICAL + DOTA_UNIT_TARGET_BUILDING,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_CLOSEST,
                            false)

	local lastTarget = ability.projectileFrom

	ability.projectileFrom = nil
	ability.projectileTo = nil

	-- find closest target, the first unit is always the projectileFrom
	-- the projectileTo will be with closest unit that wasn't the last unit (unless no others exist)
	-- this logic is a bit different from the base luna
	for k,v in pairs(unitsNearTarget) do
		if ability.projectileFrom == nil then
			ability.projectileFrom = v
		else
			ability.projectileTo = v
			if v ~= lastTarget then
				ability.projectileTo = v
				break
			end
		end
	end

	if ability.projectileTo == nil then
		killDummy(caster, target)
		return
	end

	-- increment the bounceTable which keeps track of which targets have been hit, i currently
	-- don't use it but if someone wants to go back and fix the bounce logic then it's here
	ability.bounceTable[ability.projectileTo] = ((ability.bounceTable[ability.projectileTo] or 0) + 1)
	ability.bounceCount = ability.bounceCount + 1

    local info = {
        Target = ability.projectileTo,
        Source = ability.projectileFrom,
        EffectName = ability.particle_name,
        Ability = ability,
        bDodgeable = false,
        bProvidesVision = true,
        iMoveSpeed = ability.projectile_speed,
        iVisionRadius = 0,
        iVisionTeamNumber = target:GetTeamNumber(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile( info )
end

function killDummy(caster, target)
	if caster:GetClassname() == "npc_dota_base_additive" then
		caster:RemoveSelf()
	elseif target:GetClassname() == "npc_dota_base_additive" then
		target:RemoveSelf()
	end
end