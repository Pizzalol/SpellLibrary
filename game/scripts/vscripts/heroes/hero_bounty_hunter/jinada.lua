--[[Jinada
	Author: Pizzalol/DDSuper
	Date: 11.03.2019.]]
function JinadaStart(keys)

	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local cooldown = ability:GetCooldown(level)
	local caster = keys.caster
	local modifier = keys.modifier

	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)  -- Эффекты, частиц мидаса
	if keys.target:IsRealHero() then
		ability:StartCooldown(cooldown)
		keys.target:ModifyGold(keys.StealGold, false, 0)
		caster:ModifyGold(keys.GetGoldSelf, true, 0)
		caster:RemoveModifierByName(modifier)
		ParticleManager:SetParticleControlEnt(midas_particle, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), false) -- Контроль как и сказано
		keys.target:EmitSound("Hero_BountyHunter.Jinata")
		keys.target:EmitSound("DOTA_Item.Hand_Of_Midas")
	end

	if keys.target:IsCreep() then
		caster:RemoveModifierByName(modifier)
		keys.target:EmitSound("Hero_BountyHunter.Jinada")
		ability:StartCooldown(cooldown)
		ParticleManager:DestroyParticle(midas_particle, true)
	end 
	Timers:CreateTimer(cooldown, function()
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
		end)
end


