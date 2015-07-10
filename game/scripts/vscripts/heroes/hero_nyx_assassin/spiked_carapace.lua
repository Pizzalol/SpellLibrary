--[[
	Author: kritth
	Date: 10.01.2015.
	Init the table
]]
function spiked_carapace_init( keys )
	keys.caster.carapaced_units = {}
end

--[[
	Author: kritth
	Date: 10.01.2015.
	Reflect damage
]]
function spiked_carapace_reflect( keys )
	-- Variables
	local caster = keys.caster
	local attacker = keys.attacker
	local damageTaken = keys.DamageTaken
	
	-- Check if it's not already been hit
	if not caster.carapaced_units[ attacker:entindex() ] and not attacker:IsMagicImmune() then
		attacker:SetHealth( attacker:GetHealth() - damageTaken )
		keys.ability:ApplyDataDrivenModifier( caster, attacker, "modifier_spiked_carapaced_stun_datadriven", { } )
		caster:SetHealth( caster:GetHealth() + damageTaken )
		caster.carapaced_units[ attacker:entindex() ] = attacker
	end
end
