--[[
	Author: Ractidous
	Date: 29.01.2015.
	Deal damage to the egg.
]]
function OnAttackedEgg( event )
	local egg			= event.target
	local attacker		= event.attacker
	local maxAttacks	= event.max_hero_attacks

	-- Only real heroes can deal damage to the egg.
	if not attacker:IsRealHero() then
		return
	end

	local numAttacked = egg.supernova_numAttacked or 0
	numAttacked = numAttacked + 1
	egg.supernova_numAttacked = numAttacked

	local health = 100 * ( maxAttacks - numAttacked ) / maxAttacks
	egg:SetHealth( health )

	if numAttacked >= maxAttacks then
		-- Now the egg has been killed.
		egg.supernova_lastAttacker = attacker
		event.caster:RemoveModifierByName( "modifier_supernova_sun_form_caster_datadriven" )
		egg:RemoveModifierByName( "modifier_supernova_sun_form_egg_datadriven" )
	end
end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Kill the bird if the egg has been killed; Refresh him and stun around enemies otherwise.
]]
function OnDestroyEgg( event )
	local egg		= event.target
	local hero		= event.caster
	local ability	= event.ability

	local isDead = egg:GetHealth() == 0

	if isDead then

		hero:Kill( ability, egg.supernova_lastAttacker )

	else

		hero:SetHealth( hero:GetMaxHealth() )
		hero:SetMana( hero:GetMaxMana() )

		-- Strong despel
		local RemovePositiveBuffs = true
		local RemoveDebuffs = true
		local BuffsCreatedThisFrameOnly = false
		local RemoveStuns = true
		local RemoveExceptions = true
		hero:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions )

		-- Stun nearby enemies
		ability:ApplyDataDrivenModifier( hero, egg, "modifier_supernova_egg_explode_datadriven", {} )
		hero:RemoveModifierByName( "modifier_supernova_egg_explode_datadriven" )

	end

	-- Play sound effect
	local soundName = "Hero_Phoenix.SuperNova." .. ( isDead and "Death" or "Explode" )
	StartSoundEvent( soundName, hero )

	-- Create particle effect
	local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_" .. ( isDead and "death" or "reborn" ) .. ".vpcf"
	local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN, egg )
	ParticleManager:SetParticleControlEnt( pfx, 0, egg, PATTACH_POINT_FOLLOW, "follow_origin", egg:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( pfx, 1, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAbsOrigin(), true )

	-- Remove the egg
	egg:ForceKill( false )
	egg:AddNoDraw()
end


--[[
	Author: Ractidous
	Date: 29.01.2015.
	Hide caster's model.
]]
function HideCaster( event )
	event.caster:AddNoDraw()
end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Show caster's model.
]]
function ShowCaster( event )
	event.caster:RemoveNoDraw()
end