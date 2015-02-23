--[[
	Author: Ractidous
	Date: 23.02.2015.

	Store the caster.
]]
function Thinker_StoreCaster( event )
	local ability	= event.ability
	local caster	= event.caster
	local thinker	= event.target

	thinker.dream_coil_caster	= caster
	ability.dream_coil_thinker	= thinker
end

--[[
	Author: Ractidous
	Date: 23.02.2015.

	Apply modifier to the enemy
]]
function Thinker_ApplyModifierToEnemy( event )
	local ability	= event.ability
	local thinker	= ability.dream_coil_thinker
	local enemy		= event.target

	ability:ApplyDataDrivenModifier( thinker, enemy, event.modifier_name, {} )
end

--[[
	Author: Ractidous
	Date: 23.02.2015.

	Check to see if the coil gets broken.
]]
function CheckCoilBreak( event )
	local thinker	= event.caster
	local enemy		= event.target

	local dist	= (enemy:GetAbsOrigin() - thinker:GetAbsOrigin()):Length2D()
	if dist > event.coil_break_radius then
		-- Link has been broken
		local ability	= event.ability
		local caster	= thinker.dream_coil_caster

		ability:ApplyDataDrivenModifier( caster, enemy, event.coil_break_modifier, {} )

		-- Remove this modifier
		enemy:RemoveModifierByNameAndCaster( event.coil_tether_modifier, thinker )
	end
end