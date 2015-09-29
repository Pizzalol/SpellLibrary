--[[
	Author: Ractidous, with help from Noya
	Date: 03.02.2015.
	Initialize the slowed units list, and let the caster latch.
	We also need to track the health/mana, in order to grab amount gained of health/mana in the future.
]]
function CastTether( event )
	-- Variables
	local caster	= event.caster
	local target	= event.target
	local ability	= event.ability

	local casterOrigin	= caster:GetAbsOrigin()
	local targetOrigin	= target:GetAbsOrigin()

	-- Store current Health/Mana to detect gained value
	TrackCurrentHealth( event )
	TrackCurrentMana( event )

	-- Store the ally unit
	ability.tether_ally = target

	-- Clear the slowed units list
	ability.tether_slowedUnits = {}

	-- Start latching
	local distToAlly = (targetOrigin - casterOrigin):Length2D()
	if distToAlly >= event.latch_distance then
		ability:ApplyDataDrivenModifier( caster, caster, event.latch_modifier, {} )
	end

	-- Swap sub ability
	local mainAbilityName	= ability:GetAbilityName()
	local subAbilityName	= event.sub_ability_name
	caster:SwapAbilities( mainAbilityName, subAbilityName, false, true )
end

--[[
	Author: Ractidous
	Date: 04.02.2015.
	Check for tether break distance.
]]
function CheckDistance( event )
	local caster = event.caster
	local ability = event.ability

	-- Now on latching, so we don't need to break tether.
	if caster:HasModifier( event.latch_modifier ) then
		return
	end

	local distance = ( ability.tether_ally:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D()
	if distance <= event.radius then
		return
	end

	-- Break tether
	caster:RemoveModifierByName( event.caster_modifier )
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Remove tether from the ally, then swap the abilities back to the original states.
]]
function EndTether( event )
	local caster = event.caster
	local ability = event.ability

	ability.tether_ally:RemoveModifierByName( event.ally_modifier )
	ability.tether_ally = nil

	caster:SwapAbilities( ability:GetAbilityName(), event.sub_ability_name, true, false )
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Store the current health.
]]
function TrackCurrentHealth( event )
	local caster = event.caster
	caster.tether_lastHealth = caster:GetHealth()
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Store the current mana.
]]
function TrackCurrentMana( event )
	local caster = event.caster
	caster.tether_lastMana = caster:GetMana()
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Heal the gained health to the tethered ally.
]]
function HealAlly( event )
	local caster	= event.caster
	local ability	= event.ability
	local target	= ability.tether_ally

	local healthGained = caster:GetHealth() - caster.tether_lastHealth
	if healthGained < 0 then
		return
	end

	-- Heal the tethered ally
	target:Heal( healthGained * event.tether_heal_amp, ability )
end

--[[
	Author: Ractidous
	Date: 04.02.2015.
	Give mana to the tethered ally.
]]
function GiveManaToAlly( event )
	local caster	= event.caster
	local ability	= event.ability
	local target	= ability.tether_ally

	local manaGained = caster:GetMana() - caster.tether_lastMana
	if manaGained < 0 then
		return
	end

	--print( caster.tether_lastMana )

	target:GiveMana( manaGained * event.tether_heal_amp )
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Pull the caster to the tethered ally.
]]
function Latch( event )
	-- Variables
	local caster	= event.caster
	local ability	= event.ability
	local target 	= ability.tether_ally

	local tickInterval	= event.tick_interval
	local latchSpeed	= event.latch_speed
	local latchDistance	= event.latch_distance_to_target

	local casterOrigin	= caster:GetAbsOrigin()
	local targetOrigin	= target:GetAbsOrigin()

	-- Calculate the distance
	local casterDir = casterOrigin - targetOrigin
	local distToAlly = casterDir:Length2D()
	casterDir = casterDir:Normalized()

	if distToAlly > latchDistance then

		-- Leap to the target
		distToAlly = distToAlly - latchSpeed * tickInterval
		distToAlly = math.max( distToAlly, latchDistance )	-- Clamp this value

		local pos = targetOrigin + casterDir * distToAlly
		pos = GetGroundPosition( pos, caster )

		caster:SetAbsOrigin( pos )

	end

	if distToAlly <= latchDistance then
		-- We've reached, so finish latching
		caster:RemoveModifierByName( event.latch_modifier )
	end

end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Launch a projectile in order to detect enemies crosses the tether.
]]
function FireTetherProjectile( event )
	-- Variables
	local caster	= event.caster
	local target	= event.target
	local ability	= event.ability

	local lineRadius	= event.tether_line_radius
	local tickInterval	= event.tick_interval

	local casterOrigin	= caster:GetAbsOrigin()
	local targetOrigin	= target:GetAbsOrigin()

	local velocity = targetOrigin - casterOrigin

	-- Create a projectile
	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		vSpawnOrigin		= casterOrigin,
		fDistance			= velocity:Length2D(),
		fStartRadius		= lineRadius,
		fEndRadius			= lineRadius,
		Source				= caster,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime			= GameRules:GetGameTime() + tickInterval + 0.03,
		bDeleteOnHit		= false,
		vVelocity			= velocity / tickInterval,
	} )
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Apply the slow debuff to the enemy unit.
	If the unit has already got slowed in current cast of Tether, just skip it.
]]
function OnProjectileHit( event )
	-- Variables
	local caster	= event.caster
	local target	= event.target	-- An enemy unit
	local ability	= event.ability

	-- Already got slowed
	if ability.tether_slowedUnits[target] then
		return
	end

	-- Apply slow debuff
	ability:ApplyDataDrivenModifier( caster, target, event.slow_modifier, {} )

	-- An enemy unit may only be slowed once per cast.
	-- We store the enemy unit to the hashset, so we can check whether the unit has got debuff already later on.
	ability.tether_slowedUnits[target] = true
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


--[[
	Author: Ractidous
	Date: 29.01.2015.
	Stop a sound.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.caster )
end
