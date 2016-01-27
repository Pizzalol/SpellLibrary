LinkLuaModifier("modifier_elder_dragon_form_model_lua", "heroes/hero_dragon_knight/modifiers/modifier_elder_dragon_form_model_lua.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: chirslotix,Pizzalol
	Date: 10.01.2015.
	Deals splash auto attack damage to nearby targets depending on distance]]
function Splash( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius_small = ability:GetLevelSpecialValueFor("splash_radius", 0)
	local radius_medium = ability:GetLevelSpecialValueFor("splash_radius", 1) 
	local radius_big = ability:GetLevelSpecialValueFor("splash_radius", 2) 
	local target_exists = false
	local splash_damage_small = ability:GetLevelSpecialValueFor("splash_damage_percent", 0) / 100
	local splash_damage_medium = ability:GetLevelSpecialValueFor("splash_damage_percent", 1) / 100
	local splash_damage_big = ability:GetLevelSpecialValueFor("splash_damage_percent", 2) / 100
	
	-- Finding the units for each radius
	local splash_radius_small = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin() , nil, radius_small , DOTA_UNIT_TARGET_TEAM_ENEMY	, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false) 
	local splash_radius_medium = FindUnitsInRadius(caster:GetTeam() , target:GetAbsOrigin() , nil, radius_medium, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local splash_radius_big = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin() , nil, radius_big, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

	-- Initializing the damage table
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
	damage_table.damage = caster:GetAttackDamage() * splash_damage_small


	--loop for doing the splash damage while ignoring the original target
	for i,v in ipairs(splash_radius_small) do
		if v ~= target then 
			damage_table.victim = v
			ApplyDamage(damage_table)
		end
	end
	--loop for doing the medium splash damage
	for i,v in ipairs(splash_radius_medium) do
		if v ~= target then
			--loop for checking if the found target is in the splash_radius_small
			for c,k in ipairs(splash_radius_small) do
				if v == k then
					target_exists = true
					break
				end
			end
			--if the target isn't in the splash_radius_small then do attack damage * splash_damage_medium
			if not target_exists then
				damage_table.damage = caster:GetAttackDamage() * splash_damage_medium
				damage_table.victim = v
				ApplyDamage(damage_table)
			--resets the target check	
			else
				target_exists = false
			end
		end
	end
	--loop for doing the damage if targets are found in the splash_damage_big but not in the splash_damage_medium
	for i,v in ipairs(splash_radius_big) do
		if v ~= target then
			--loop for checking if the found target is in the splash_radius_medium
			for c,k in ipairs(splash_radius_medium) do				
				if v == k then
					target_exists = true
					break
				end
			end
			if not target_exists then
				damage_table.damage = caster:GetAttackDamage() * splash_damage_big
				damage_table.victim = v
				ApplyDamage(damage_table)
			else
				target_exists = false
			end
		end
	end
end

--[[Author: Pizzalol
	Date: 27.01.2016.
	It transforms the caster into a different dragon depending on the ability level]]
function Transform( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()

	local duration = ability:GetLevelSpecialValueFor("duration",level - 1)
	local modifier_one = keys.modifier_one
	local modifier_two = keys.modifier_two
	local modifier_three = keys.modifier_three

	-- Deciding the transformation level
	local modifier
	if level == 1 then modifier = modifier_one
	elseif level == 2 then modifier = modifier_two
	else modifier = modifier_three end

	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
	caster:AddNewModifier(caster,ability,"modifier_elder_dragon_form_model_lua",{duration = duration})
end

--[[Author: Pizzalol,Noya
	Date: 27.01.2016.
	Swaps the auto attack projectile and the caster attack capability]]
function ModelSwapStart( keys )
	local caster = keys.caster
	local projectile_model = keys.projectile_model

	-- Saves the original attack capability
	caster.caster_attack = caster:GetAttackCapability()

	-- Sets the new projectile
	caster:SetRangedProjectileName(projectile_model)

	-- Sets the new attack type
	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

--[[Author: Pizzalol,Noya
	Date: 27.01.2016.
	Reverts back to the original attack type]]
function ModelSwapEnd( keys )
	local caster = keys.caster
	caster:SetAttackCapability(caster.caster_attack)
end