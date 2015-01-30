--[[
	Author: Ractidous
	Date: 28.01.2015.
	Start cooldown.
]]
function StartCooldown( event )
	local caster = event.caster
	local ability = event.ability
	local cooldown = ability:GetCooldown( ability:GetLevel() - 1 )
	local modifierName = "modifier_liquid_fire_orb_datadriven"

	-- Start cooldown
	ability:EndCooldown()
	ability:StartCooldown( cooldown )

	-- Disable orb modifier
	caster:RemoveModifierByName( "modifier_liquid_fire_orb_datadriven" )

	-- Re-enable orb modifier after for the duration
	ability:SetContextThink( DoUniqueString("activateLiquidFire"), function ()
		-- Here's a magic
		-- Reset the ability level in order to restore a passive modifier
		ability.liquid_fire_forceEnableOrb = true
		ability:SetLevel( ability:GetLevel() )	
	end, cooldown + 0.05 )
end

--[[
	Author: Ractidous
	Dage: 28.01.2015.
	Check orb modifer state on upgrading.
]]
function CheckOrbModifier( event )
	local ability = event.ability
	local caster = event.caster

	if ability.liquid_fire_forceEnableOrb then
		ability.liquid_fire_forceEnableOrb = nil
		return
	end

	if ability:IsCooldownReady() then
		return
	end

	caster:RemoveModifierByName( "modifier_liquid_fire_orb_datadriven" )
end