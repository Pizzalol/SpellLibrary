--[[
	Author: Ractidous
	Date: 11.02.2015.
	Drain HP and Mana.
]]
function TickDrain( event )
	local caster = event.caster
	local deltaDrainPct	= event.drain_interval * event.drain_pct

	ApplyDamage( {
		victim = caster,
		attacker = caster,
		damage = caster:GetHealth() * deltaDrainPct,
		damage_type = DAMAGE_TYPE_PURE,
	} )

	caster:SpendMana( caster:GetMana() * deltaDrainPct, event.ability )
end

--[[
	Author: Ractidous
	Date: 11.02.2015.
	Grab the tether ability and reset overcharged ally.
]]
function GrabTetherAbility( event )
	local caster = event.caster
	local tether = caster:FindAbilityByName( event.tether_ability_name )
	local overcharge = event.ability

	-- Store tether
	overcharge.overcharge_tether = tether

	-- Reset the overcharged ally
	overcharge.overcharge_ally = nil
end

--[[
	Author: Ractidous
	Date: 11.02.2015.
	Check to see if the overcharged ally should be changed.
]]
function CheckTetheredAlly( event )

	local caster		= event.caster
	local overcharge	= event.ability
	local buffModifier	= event.buff_modifier

	-- If the caster has no TETHER ability, skip it.
	if not overcharge.overcharge_tether then
		return
	end

	local tetheredAlly		= overcharge.overcharge_tether[ event.tether_ally_property_name ]
	local overchargedAlly	= overcharge.overcharge_ally

	-- If the tethered ally has been changed
	if tetheredAlly ~= overchargedAlly then

		-- Remove the buff from the old overcharged ally
		if overchargedAlly then
			overchargedAlly:RemoveModifierByNameAndCaster( buffModifier, caster )
		end

		-- Attach the buff to the new tethered ally
		if tetheredAlly then
			overcharge:ApplyDataDrivenModifier( caster, tetheredAlly, buffModifier, {} )
		end

		-- Update overcharged ally
		overcharge.overcharge_ally = tetheredAlly

	end

end

--[[
	Author: Ractidous
	Date: 11.02.2015.
	Remove the overcharge modifier from the ally.
]]
function RemoveOverchargeFromAlly( event )
	
	local caster		= event.caster
	local overcharge	= event.ability
	local buffModifier	= event.buff_modifier

	local overchargedAlly	= overcharge.overcharge_ally

	if overchargedAlly then
		overchargedAlly:RemoveModifierByNameAndCaster( buffModifier, caster )
	end

	overcharge.overcharge_ally = nil

end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Stop a sound.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.caster )
end
