--[[
	Author: Ractidous
	Date: 28.01.2015.
	Cast Fire Spirts.
]]
function CastFireSpirits( event )
	local caster	= event.caster
	local ability	= event.ability
	local modifierStackName	= event.modifier_stack_name

	local hpCost		= event.hp_cost_perc
	local numSpirits	= event.spirit_count

	-- Create particle FX
	local particleName = "particles/units/heroes/hero_phoenix/phoenix_fire_spirits.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( pfx, 1, Vector( numSpirits, 0, 0 ) )
	for i=1, numSpirits do
		ParticleManager:SetParticleControl( pfx, 8+i, Vector( 1, 0, 0 ) )
	end

	caster.fire_spirits_numSpirits	= numSpirits
	caster.fire_spirits_pfx			= pfx

	-- Set the stack count
	caster:SetModifierStackCount( modifierStackName, ability, numSpirits )

	-- Apply HP removal
--	ApplyDamage( {
--		victim = caster,
--		attacker = caster,
--		damage = caster:GetHealth() * hpCost / 100,
--		damage_type = DAMAGE_TYPE_PURE,		-- will show the pure damage indicator popup
--	} )

	caster:SetHealth( caster:GetHealth() * ( 100 - hpCost ) / 100 )

	-- Swap sub ability
	local sub_ability_name	= event.sub_ability_name
	local main_ability_name	= ability:GetAbilityName()
	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
end

--[[
	Author: Ractidous
	Date: 28.01.2015.
	Launch a fire spirit.
]]
function LaunchFireSpirit( event )
	local caster		= event.caster
	local ability		= event.ability
	local modifierName	= event.modifier_stack_name

	-- Update spirits count
	local mainAbility	= caster:FindAbilityByName( event.main_ability_name )
	local currentStack	= caster:GetModifierStackCount( modifierName, mainAbility )
	currentStack = currentStack - 1
	caster:SetModifierStackCount( modifierName, mainAbility, currentStack )

	-- Update the particle FX
	local pfx = caster.fire_spirits_pfx
	ParticleManager:SetParticleControl( pfx, 1, Vector( currentStack, 0, 0 ) )
	for i=1, caster.fire_spirits_numSpirits do
		local radius = 0
		if i <= currentStack then
			radius = 1
		end

		ParticleManager:SetParticleControl( pfx, 8+i, Vector( radius, 0, 0 ) )
	end

	-- Remove the stack modifier if all the spirits has been launched.
	if currentStack == 0 then
		caster:RemoveModifierByName( modifierName )
	end
end

--[[
	Author: Ractidous
	Date: 28.01.2015.
	Remove fire spirits' FX.
]]
function RemoveFireSpirits( event )
	local caster	= event.caster
	local ability	= event.ability

	local pfx = caster.fire_spirits_pfx
	ParticleManager:DestroyParticle( pfx, false )

	-- Swap main ability
	local main_ability_name	= ability:GetAbilityName()
	local sub_ability_name	= event.sub_ability_name
	caster:SwapAbilities( main_ability_name, sub_ability_name, true, false )
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