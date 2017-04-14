function JinguHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local jinguBuff = caster:FindModifierByName("modifier_jingu_mastery_activated")
	if jinguBuff then
		jinguBuff:DecrementStackCount()
		if jinguBuff:GetStackCount() <= 0 then
			jinguBuff:Destroy()
			caster:RemoveModifierByName("modifier_jingu_mastery_activated_damage")
		end
	end
end

function CheckJingu(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if caster:HasModifier("modifier_jingu_mastery_activated") or not target:IsRealHero() or not caster:IsRealHero() or caster:PassivesDisabled() then return
	else
		local jinguStack = target:FindModifierByName("modifier_jingu_mastery_hitcount")
		if not jinguStack then 
			ability:ApplyDataDrivenModifier(caster, target, "modifier_jingu_mastery_hitcount", {duration = ability:GetTalentSpecialValueFor("counter_duration")})
			jinguStack = target:FindModifierByName("modifier_jingu_mastery_hitcount")
			jinguStack:SetStackCount(0)
			
		end
		jinguStack:SetStackCount(jinguStack:GetStackCount() + 1)
		print(jinguStack:GetStackCount())
		if not target.OverHeadJingu then 
			target.OverHeadJingu = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, target)
			ParticleManager:SetParticleControl(target.OverHeadJingu, 0, target:GetAbsOrigin())
		end
		ParticleManager:SetParticleControl(target.OverHeadJingu, 1, Vector(0,jinguStack:GetStackCount(),0))
		
		if jinguStack:GetStackCount() == ability:GetTalentSpecialValueFor("required_hits") then
			local jinguBuff = ability:ApplyDataDrivenModifier(caster, caster, "modifier_jingu_mastery_activated", {})
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jingu_mastery_activated_damage", {})
			jinguBuff:SetStackCount(ability:GetTalentSpecialValueFor("charges"))
			jinguStack:Destroy()
		end
	end
end

function JinguOverheadDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	ParticleManager:DestroyParticle(target.OverHeadJingu, false)
	ParticleManager:ReleaseParticleIndex(target.OverHeadJingu)
	target.OverHeadJingu = nil
end
