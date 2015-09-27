LinkLuaModifier("modifier_voodoo_lua", "heroes/hero_shadow_shaman/modifiers/modifier_voodoo_lua.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: Pizzalol
	Date: 27.09.2015.
	Checks if the target is an illusion, if true then it kills it
	otherwise it applies the hex modifier to the target]]
function voodoo_start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target

	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	
	if target:IsIllusion() then
		target:ForceKill(true)
	else
		target:AddNewModifier(caster, ability, "modifier_voodoo_lua", {duration = duration})
	end
end