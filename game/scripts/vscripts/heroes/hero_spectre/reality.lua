function RealityCast (keys)

	local caster = keys.caster
	local ability = keys.ability
	local unit = caster:GetUnitName()
	local vPoint = ability:GetCursorPosition()

	if caster.haunting then
		
		local target = Entities:FindByNameNearest(unit, vPoint, 0)

		if target:IsIllusion() then

			--Store the caster and the illusions current position
			caster.currentPosition = caster:GetAbsOrigin()
			target.currentPosition = target:GetAbsOrigin()

			--Swaps the position of the caster and the illusion
			target:SetAbsOrigin(caster.currentPosition)	
			caster:SetAbsOrigin(target.currentPosition)

			FindClearSpaceForUnit( caster, target.currentPosition, true )

			EmitSoundOn("Hero_Spectre.Reality", caster)

		end

	end

end
