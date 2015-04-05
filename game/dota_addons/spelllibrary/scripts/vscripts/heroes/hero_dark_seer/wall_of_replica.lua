--[[Author: Pizzalol, kritth
	Date: 04.04.2015.
	Create the dummy for sound and to keep track of other variables]]
function WallOfReplica( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Cosmetic variables
	local dummy_modifier = keys.dummy_modifier
	local wall_particle = keys.wall_particle
	local dummy_sound = keys.dummy_sound

	-- Ability variables
	local length = ability:GetLevelSpecialValueFor("length", ability_level) 
	local width = ability:GetLevelSpecialValueFor("width", ability_level)
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)

	-- Targeting variables
	local direction = (target_point - caster_location):Normalized()
	local rotation_point = target_point + direction * length/2
	local end_point_left = RotatePosition(target_point, QAngle(0,90,0), rotation_point)
	local end_point_right = RotatePosition(target_point, QAngle(0,-90,0), rotation_point)

	-- Create the wall dummy
	local dummy = CreateUnitByName("npc_dummy_blank", target_point, false, nil, nil, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {})

	-- Save the relevant data
	ability.wall_start_time = GameRules:GetGameTime()
	ability.wall_duration = duration
	ability.wall_level = ability_level
	dummy.wall_left = end_point_left
	dummy.wall_right = end_point_right
	dummy.wall_direction = (end_point_left - end_point_right):Normalized()
	dummy.wall_length = length
	dummy.wall_width = width
	ability.wall_table = {}

	-- Create the wall particle
	local particle = ParticleManager:CreateParticle(wall_particle, PATTACH_POINT_FOLLOW, dummy)
	ParticleManager:SetParticleControl(particle, 0, end_point_left) 
	ParticleManager:SetParticleControl(particle, 1, end_point_right)

	-- Set a timer to kill the sound and particle
	Timers:CreateTimer(duration,function()
		StopSoundOn(dummy_sound, dummy)
		dummy:RemoveSelf()
	end)
end

--[[Author: Pizzalol
	Date: 04.04.2015.
	The target is the dummy
	Shoots projectiles periodically to check if anyone passed the wall]]
function WallOfReplicaCheck( keys )
	local target = keys.target
	local ability = keys.ability

	local speed = 3000

	local projectile_table =
	{
		--EffectName = "",
		Ability = ability,
		vSpawnOrigin = target.wall_right,
		vVelocity = Vector( target.wall_direction.x * speed, target.wall_direction.y * speed, 0 ),
		fDistance = target.wall_length,
		fStartRadius = target.wall_width,
		fEndRadius = target.wall_width,
		Source = target,
		Caster = target,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO
	}

	ProjectileManager:CreateLinearProjectile(projectile_table)
end

--[[Author: Pizzalol
	Date: 04.04.2015.
	Checks if there is an alive illusion of the target, if there is not then create an illusion]]
function WallOfReplicaIllusionCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability.wall_level

	print(ability:entindex())

	local player = caster:GetPlayerOwnerID()
	local player_hero = PlayerResource:GetPlayer(player):GetAssignedHero()

	-- Ability variables
	local unit_name = target:GetUnitName()
	local illusion_origin = target_location + RandomVector(100)
	local illusion_duration = ability.wall_duration - (GameRules:GetGameTime() - ability.wall_start_time)
	local illusion_outgoing_damage = ability:GetLevelSpecialValueFor("replica_damage_outgoing", ability_level)
	local illusion_incoming_damage = ability:GetLevelSpecialValueFor("replica_damage_incoming", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)

	-- Check if the hit hero is a real hero
	if target:IsRealHero() then
		-- Check if the illusion of the target is alive
		if not IsValidEntity(ability.wall_table[target]) or not ability.wall_table[target]:IsAlive() then
			-- Create an illusion if its not
			local illusion = CreateUnitByName(unit_name, illusion_origin, true, player_hero, nil, caster:GetTeamNumber())
			illusion:SetPlayerID(player)
			illusion:SetControllableByPlayer(player, true)

			local target_level = target:GetLevel()
			for i = 1, target_level - 1 do
				illusion:HeroLevelUp(false)
			end

			illusion:SetAbilityPoints(0) 
			for ability_slot = 0, 15 do
				local target_ability = target:GetAbilityByIndex(ability_slot) 
				if target_ability then
					local target_ability_level = target_ability:GetLevel() 
					local target_ability_name = target_ability:GetAbilityName() 
					local illusion_ability = illusion:FindAbilityByName(target_ability_name) 
					illusion_ability:SetLevel(target_ability_level) 
				end
			end

			for item_slot = 0, 5 do
				local item = target:GetItemInSlot(item_slot) 
				if item then
					local item_name = item:GetName() 
					local new_item = CreateItem(item_name, illusion, illusion) 
					illusion:AddItem(new_item) 
				end
			end

			illusion:AddNewModifier(caster, ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})

			illusion:MakeIllusion() 
			ability.wall_table[target] = illusion -- Keep track of the illusion

			-- Deal damage for creating the illusion
			local damage_table = {}
			damage_table.attacker = player_hero
			damage_table.victim = target
			damage_table.ability = ability
			damage_table.damage_type = ability:GetAbilityDamageType() 
			damage_table.damage = damage

			ApplyDamage(damage_table)
		end
	end
end

function WallOfReplicaTest( keys )
	local caster = keys.caster

	print(caster:GetUnitName())
end