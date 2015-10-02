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
	
	-- Swap sub_ability
	local sub_ability_name = event.sub_ability_name
	local main_ability_name = ability:GetAbilityName()

	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
	print("Swapped "..main_ability_name.." with " ..sub_ability_name)


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
	local decimal = math.abs(number) % 1

	if decimal < 0.5 then 
		decimal = 1 -- ".0"
	else 
		decimal = 8 -- ".5"
	end

	print(integer,decimal)

	for k, v in pairs( allHeroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			-- Don't display the 0.0 message
			if integer == 0 and decimal == 1 then
				
			else
				local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_OVERHEAD_FOLLOW, caster, PlayerResource:GetPlayer( v:GetPlayerID() ) )
				
				ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
				ParticleManager:SetParticleControl( particle, 1, Vector( preSymbol, integer, decimal) )
				ParticleManager:SetParticleControl( particle, 2, Vector( digits, 0, 0) )
			end
		end
	end

end

--[[
	Author: Noya
	Date: 10.1.2015.
	When the sub_ability is cast, stops the sound, the particle thinker and sets the time charged
	Also swaps the abilities back to the original state
]]
function EndBrewing( event )

	local caster = event.caster
	local sub_ability = event.ability

	-- Stops the charging sound
	caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")

	-- Swap the sub_ability back to normal
	local sub_ability_name = sub_ability:GetAbilityName()
	local main_ability_name = event.main_ability_name

	caster:SwapAbilities(main_ability_name, sub_ability_name, true, false)
	print("Swapped "..main_ability_name.." with " ..sub_ability_name)

	-- Get the handle of the main ability to get the time started
	local ability = caster:FindAbilityByName(main_ability_name)

	-- Set how much time the spell charged
	ability.time_charged = GameRules:GetGameTime() - ability.brew_start

	-- Remove the brewing modifier
	caster:RemoveModifierByName("modifier_unstable_concoction_brewing")

end	

--[[
	Author: Noya
	Date: 16.1.2015.
	After destroying the modifier, checks how much time was the spell charged for, and does a explosion around self if charged over the brew_explosion time
]]
function CheckSelfStun( event )

	local caster = event.caster
	local ability = event.ability
	local brew_explosion = ability:GetLevelSpecialValueFor( "brew_explosion", ability:GetLevel() - 1 )

	-- Set how much time the spell charged
	ability.time_charged = GameRules:GetGameTime() - ability.brew_start

	if ability.time_charged >= brew_explosion then
		print("Stun Self")

		-- Stops the charging sound
		caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")

		-- Plays the Concoction Stun sound
		caster:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")

		-- Swap the sub_ability back to normal
		local main_ability_name = ability:GetAbilityName()
		local sub_ability_name = event.sub_ability_name

		caster:SwapAbilities(sub_ability_name, main_ability_name, false, true)
		print("Swapped "..sub_ability_name.." with " ..main_ability_name)

		-- Launch the projectile hit on the caster, which will do the effect on enemies
		ConcoctionHit ( event )

		-- Apply the self stun for max duration and damage
		local subAbility = caster:FindAbilityByName(sub_ability_name)
		local max_stun = ability:GetLevelSpecialValueFor( "max_stun", ability:GetLevel() - 1 )
		local max_damage = ability:GetLevelSpecialValueFor( "max_damage", ability:GetLevel() - 1 )
		local mainAbilityDamageType = ability:GetAbilityDamageType()

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_unstable_concoction_stun", {duration = max_stun})
		ApplyDamage({ victim = caster, attacker = caster, damage = max_damage, damage_type = mainAbilityDamageType })

		-- Fire the explosion effect
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf"
		local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
				
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end

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
	local ability = event.ability
	local heroes_around = event.target_entities
	local brew_time = ability:GetLevelSpecialValueFor( "brew_time", ability:GetLevel() - 1 )
	local mainAbility = caster:FindAbilityByName("unstable_concoction_datadriven")
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

	-- Apply the AoE stun and damage with the variable duration
	for _,unit in pairs(heroes_around) do
		ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = mainAbilityDamageType })
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_unstable_concoction_stun", { duration = stun_duration})
	end
	

end	

--[[
	Author: Noya
	Date: 16.01.2015.
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