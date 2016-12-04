function ApplyLivingArmor(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if not target then
		local search = ability:GetCursorPosition()
		local allies = FindUnitsInRadius(caster:GetTeamNumber(), search, nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _,ally in pairs(allies) do
			if ally then
				target = ally
				break
			end
		end
	end
	ability:ApplyDataDrivenModifier(caster,target, "modifier_living_armor_datadriven", {duration = ability:GetSpecialValueFor("duration")})
	ability:ApplyDataDrivenModifier(caster,target, "modifier_living_armor_datadriven_stacks", {duration = ability:GetSpecialValueFor("duration")})
	target:SetModifierStackCount("modifier_living_armor_datadriven_stacks", caster, ability:GetSpecialValueFor("damage_count"))
	target.LivingArmorParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_livingarmor.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(target.LivingArmorParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(target.LivingArmorParticle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end

function HandleLivingArmor(keys)
	-- init --
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit

	local damage = keys.damage
	local block = ability:GetSpecialValueFor("damage_block")
	-- heal handling --
	local heal = damage
	if damage > block then heal = block end
	target:SetHealth(target:GetHealth() + heal)
	SendOverheadEventMessage( target, OVERHEAD_ALERT_BLOCK, target, heal, nil )
	
	-- stack handling --
	local stacks = target:GetModifierStackCount("modifier_living_armor_datadriven_stacks", caster)
	if stacks - 1 == 0 then 
		target:RemoveModifierByName("modifier_living_armor_datadriven")
		target:RemoveModifierByName("modifier_living_armor_datadriven_stacks")
	else target:SetModifierStackCount("modifier_living_armor_datadriven_stacks", caster, stacks - 1) end
end
