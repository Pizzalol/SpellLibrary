--[[
	Author: Ractidous
	Date: 29.01.2015.
	Get all illusions owned by the hero.
]]
function GetIllusions( hero )
	local playerID = hero:GetPlayerID()

	local allies = FindUnitsInRadius( hero:GetTeamNumber(),
									  hero:GetAbsOrigin(),
									  nil,
									  FIND_UNITS_EVERYWHERE,
									  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
									  DOTA_UNIT_TARGET_HERO,
									  DOTA_UNIT_TARGET_FLAG_NONE,
									  FIND_ANY_ORDER,
									  false )
	local illusions = {}

	for _,v in pairs( allies ) do
		if v:GetPlayerID() == playerID and v:IsIllusion() then
			table.insert( illusions, v )
		end
	end

	return illusions

--	return hero.illusions or {}
end

--[[
	Author: Ractidous
	Date: 25.01.2015.
	Cast RipTide from all illusions and the real hero.
]]
function RipTide( event )
	local caster = event.caster
	local ability = event.ability
	local damage = ability:GetAbilityDamage()
	local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
	local modifierName = "modifier_rip_tide_datadriven"
	local dummyModifierName = "modifier_rip_tide_dummy_datadriven"

	local allVictims = {}	-- hashset

	local castRipTide = function ( unit )
		-- Find victims
		unit.riptide_victims = {}

		ability:ApplyDataDrivenModifier( unit, unit, dummyModifierName, {} )
		unit:RemoveModifierByName( dummyModifierName )

		for k,v in pairs(unit.riptide_victims) do
			allVictims[v] = true
		end

		unit.riptide_victims = nil

		-- Create effects
		local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_siren/naga_siren_riptide.vpcf", PATTACH_ABSORIGIN, unit )
		ParticleManager:SetParticleControl( pfx, 0, unit:GetAbsOrigin() )
		ParticleManager:SetParticleControl( pfx, 1, Vector( radius, radius, radius ) )
		ParticleManager:SetParticleControl( pfx, 3, Vector( 0.0, 0.0, 0.0 ) )

		StartSoundEvent( "Hero_NagaSiren.RipTide.Precast", unit )
		StartSoundEvent( "Hero_NagaSiren.Riptide.Cast", unit )
	end
	
	-- Cast from the real hero
	castRipTide( caster )

	-- Cast from all illusions owned
	local illusions = GetIllusions( caster )
	for _,v in pairs(illusions) do
		if v and IsValidEntity(v) and v:IsAlive() then
			castRipTide( v )
		end
	end

	-- Apply damage and debuff to all victims
	for victim, _ in pairs(allVictims) do
		ability:ApplyDataDrivenModifier( caster, victim, modifierName, {} )
		ApplyDamage( {
			victim = victim,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		} )
	end
end

--[[
	Author: Ractidous
	Date: 25.01.2015.
	Add the target unit to the caster's victim list.
]]
function RipTide_MarkAsVictim( event )
	local caster = event.caster
	local target = event.target

	table.insert( caster.riptide_victims, target )
end