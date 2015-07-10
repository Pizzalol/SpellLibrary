--[[
	Author: Ractidous
	Date: 29.01.2015.
	Get all illusions owned by the hero.
]]
function GetIllusions( hero )
	local playerID = hero:GetPlayerID()

	local allies = FindUnitsInRadius( hero:GetTeamNumber(),
									  hero:GetAbsOrigin(),
									  nil,
									  FIND_UNITS_EVERYWHERE,
									  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
									  DOTA_UNIT_TARGET_HERO,
									  DOTA_UNIT_TARGET_FLAG_NONE,
									  FIND_ANY_ORDER,
									  false )
	local illusions = {}

	for _,v in pairs( allies ) do
		if v:GetPlayerID() == playerID and v:IsIllusion() then
			table.insert( illusions, v )
		end
	end

	return illusions

--	return hero.illusions or {}
end

--[[
	Author: Ractidous
	Date: 25.01.2015.
	Play fake animation for illusions.
]]
function Ensnare_PlayFakeAnimation( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local anim_duration = ability:GetCastPoint()
	local target_origin = target:GetAbsOrigin()
	local fake_ensnare_distance = ability:GetLevelSpecialValueFor( "fake_ensnare_distance", ( ability:GetLevel() - 1 ) )

	caster.ensnare_fake_illusions = {}

	for _,v in pairs(GetIllusions(caster)) do
		if v and IsValidEntity(v) and v:IsAlive() then
			-- Calculate distance
			local illusion_origin = v:GetAbsOrigin()
			local direction = target_origin - illusion_origin
			local dist = direction:Length2D()

			if dist <= fake_ensnare_distance then
				ability:ApplyDataDrivenModifier( v, v, "modifier_ensnare_fake_datadriven", {duration = anim_duration} )

				-- Face to the target if the illusion is idling
				if v:IsIdle() then
					direction = direction / dist
					v:MoveToPosition( illusion_origin + direction )
				end

				table.insert( caster.ensnare_fake_illusions, v )
			end
		end
	end
end


--[[
	Author: Ractidous
	Date: 25.01.2015.
	Cast fake nets from illusions.
]]
function Ensnare_CastFakeNets( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local projectile_speed = ability:GetLevelSpecialValueFor( "net_speed", ( ability:GetLevel() - 1 ) )

	if not caster.ensnare_fake_illusions then
		return
	end

	for _,v in pairs(caster.ensnare_fake_illusions) do
		if v and IsValidEntity(v) and v:IsAlive() then
			-- Cast a fake net
			ProjectileManager:CreateTrackingProjectile( {
				Target = target,
				Source = v,
				Ability = nil,	-- Don't let it call "OnProjectileHitUnit"
				EffectName = "particles/units/heroes/hero_siren/siren_net_projectile.vpcf",
				bDodgeable = true,
				bProvideVision = true,
				iMoveSpeed = projectile_speed,
				iVisionRadius = 0,
				iVisionTeamNumber = v:GetTeamNumber(),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			} )
		end
	end
end