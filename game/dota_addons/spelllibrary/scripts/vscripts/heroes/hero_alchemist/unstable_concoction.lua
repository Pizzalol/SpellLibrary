--[[
	Author: Noya
	Date: 10.1.2015.
	Tracks when the first ability is cast, swaps with the sub ability and plays a sound that can be stopped later
]]
function StartBrewing( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	ability.brew_start = GameRules:GetGameTime()

	-- Swap sub-ability	
	local subAbility = caster:FindAbilityByName("alchemist_unstable_concoction_throw_datadriven")

	caster:SwapAbilities(ability:GetAbilityName(), subAbility:GetAbilityName(), false, true)
	subAbility:SetHidden(false)	
	ability:SetHidden(true)

	-- Play the sound, which will be stopped when the sub ability fires
	caster:EmitSound("Hero_Alchemist.UnstableConcoction.Fuse")

end	

--[[
	Author: Noya
	Date: 10.1.2015.
	Updates the numeric particle every 0.5 think interval
]]
function UpdateTimerParticle( event )

	local caster = event.caster
	local ability = event.ability
	local brew_explosion = ability:GetLevelSpecialValueFor( "brew_explosion", ability:GetLevel() - 1 )

	-- Show the particle to all allies
	local allHeroes = HeroList:GetAllHeroes()
	local particleName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"
	local preSymbol = 0 -- Empty
	local digits = 2 -- "5.0" takes 2 digits
	local number = GameRules:GetGameTime() - ability.brew_start - brew_explosion - 0.1 --the minus .1 is needed because think interval comes a frame earlier

	-- Get the integer. Add a bit because the think interval isn't a perfect 0.5 timer
	local integer = math.floor(math.abs(number))

	-- Round the decimal number to .0 or .5
	local decimal = (number * 10) % 10

	print(number,integer,decimal)
	if decimal > 5 then 
		decimal = 1 -- ".0"
	else 
		decimal = 8 -- ".5"
	end	

	for k, v in pairs( allHeroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_OVERHEAD_FOLLOW, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
			
			ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( particle, 1, Vector( preSymbol, integer, decimal) )
			ParticleManager:SetParticleControl( particle, 2, Vector( digits, 0, 0) )

		end
	end

end

--[[
	Author: Noya
	Date: 10.1.2015.
	When the sub-ability is cast, stops the sound, the particle thinker and sets the time charged
	Also swaps the abilities back to the original state
]]
function EndBrewing( event )

	local caster = event.caster

	-- Stops the charging sound
	caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")

	-- Swap the sub-ability back to normal
	local subAbility = event.ability
	local ability = caster:FindAbilityByName("alchemist_unstable_concoction_datadriven")

	caster:SwapAbilities(ability:GetAbilityName(), subAbility:GetAbilityName(), false, true)
	subAbility:SetHidden(true)	
	ability:SetHidden(false)

	print("Swapped "..ability:GetAbilityName().." with " ..subAbility:GetAbilityName())

	-- Set how much time the spell charged
	ability.time_charged = GameRules:GetGameTime() - ability.brew_start
	print("Charged stun for " .. ability.time_charged .. " seconds")

	-- Remove the brewing modifier
	caster:RemoveModifierByName("modifier_unstable_concoction_brewing")

end	

--[[
	Author: Noya
	Date: 10.1.2015.
	When the projectile hits a unit, checks the charged duration stored in the main ability handle
	Final stun duration and damage are based on the how much the spell was charged, with min and max values
]]
function ConcoctionHit( event )
	print("Projectile Hit Target")

	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local damage
	local brew_time = ability:GetLevelSpecialValueFor( "brew_time", ability:GetLevel() - 1 )
	local mainAbility = caster:FindAbilityByName("alchemist_unstable_concoction_datadriven")
	local mainAbilityDamageType = mainAbility:GetAbilityDamageType()
	local min_stun = ability:GetLevelSpecialValueFor( "min_stun", ability:GetLevel() - 1 )
	local max_stun = ability:GetLevelSpecialValueFor( "max_stun", ability:GetLevel() - 1 )
	local min_damage = ability:GetLevelSpecialValueFor( "min_damage", ability:GetLevel() - 1 )
	local max_damage = ability:GetLevelSpecialValueFor( "max_damage", ability:GetLevel() - 1 )

	-- Check the time charged to set the duration
	local charged_duration = mainAbility.time_charged
	if charged_duration >= brew_time then
		charged_duration = brew_time
	end

	-- How much of the possible charge time was charged
	local charged_percent = charged_duration / brew_time

	-- Set the stun duration and damage
	local stun_duration = min_stun
	local damage = min_damage
	if charged_duration > min_stun then
		stun_duration = max_stun * charged_percent
		damage = max_damage * charged_percent
	end

	-- Apply the stun with the variable duration
	ability:ApplyDataDrivenModifier(caster, target, "modifier_unstable_concoction_stun", { duration = stun_duration})

	-- Do the damage in AoE
	local radius = ability:GetLevelSpecialValueFor( "midair_explosion_radius", ability:GetLevel() - 1 )
	local heroes_around = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, 
											DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 
											DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _,unit in pairs(heroes_around) do
		ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = mainAbilityDamageType }) 
	end
	

end	

--[[
	Author: Noya
	Date: 10.1.2015.
	Levels up the sub ability after the main ability was upgraded
]]
function UnstableConcoctionLevelUp( event )
	print("Leveled Up the Ability")

	local caster = event.caster
	local ability = event.ability
	local abilityName = ability:GetAbilityName()
	local abilityLevel = ability:GetLevel()
	local subAbilityName = "alchemist_unstable_concoction_throw_datadriven"
	local subAbility = caster:FindAbilityByName(subAbilityName)	
	local subAbilityLevel = subAbility:GetLevel()

	-- Check to not enter a level up loop
	if subAbilityLevel ~= abilityLevel then
		subAbility:SetLevel(abilityLevel)
	end
end

--[[
	Author: Noya
	Date: 10.1.2015.
	Levels up the main ability after the sub ability was upgraded
]]
function UnstableConcoctionThrowLevelUp( event )
	print("Leveled Up the Sub Ability")

	local caster = event.caster
	local ability = event.ability
	local abilityName = ability:GetAbilityName()
	local abilityLevel = ability:GetLevel()
	local mainAbilityName = "alchemist_unstable_concoction_datadriven"
	local mainAbility = caster:FindAbilityByName(mainAbilityName)	
	local mainAbilityLevel = mainAbility:GetLevel()

	-- Check to not enter a level up loop
	if mainAbilityLevel ~= abilityLevel then
		mainAbility:SetLevel(abilityLevel)
	end
end