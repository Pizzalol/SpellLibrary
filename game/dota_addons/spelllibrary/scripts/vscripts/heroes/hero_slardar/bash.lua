--[[Slardar's bash
	Author: chrislotix
	Date: 31.12.2014.]]
function Bash( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability

	if target:IsRealHero() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_bash_stun_hero_datadriven", {}) 
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_bash_stun_creep_datadriven", {})
	end	 
end


