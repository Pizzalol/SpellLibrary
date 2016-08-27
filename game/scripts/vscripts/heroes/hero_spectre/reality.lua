function RealityCast (keys)

	local caster = keys.caster
	local ability = keys.ability
	local unit = caster:GetUnitName()
	local vPoint = ability:GetCursorPosition()

	if caster.haunting then
		
		local target = Entities:FindByNameNearest(unit, vPoint, 0)

		target.vPosition = target:GetAbsOrigin()					--Store the target illusions current position

		if target:IsIllusion() then

			EmitSoundOn("Hero_Spectre.Reality", caster)
			
			local illusions = Entities:FindAllByName(unit)
			for i, illusion in ipairs(illusions) do
				local illusion = illusions[i]
				if illusion:IsIllusion() then
					illusion:RemoveModifierByName("modifier_spectre_haunt_reality")
					--illusion:SetAbsOrigin(target.vPosition)

				end
			end

			ability:ApplyDataDrivenModifier(caster, target, "modifier_spectre_haunt_reality", {})

			caster:SetAbsOrigin(target:GetAbsOrigin())		--Move caster to the illusion

			target:SetAbsOrigin( target:GetAbsOrigin() - Vector(0, 0, 900) )				--Hide the illusion underground

		end

	end

end
