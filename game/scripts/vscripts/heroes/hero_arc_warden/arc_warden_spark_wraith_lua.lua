LinkLuaModifier( "arc_warden_spark_wraith_thinker", "heroes/hero_arc_warden/arc_warden_spark_wraith_lua.lua", LUA_MODIFIER_MOTION_HORIZONTAL )


arc_warden_spark_wraith = class({})

function arc_warden_spark_wraith:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local team_id = caster:GetTeamNumber()
	local thinker = CreateModifierThinker(caster, self, "arc_warden_spark_wraith_thinker", {}, point, team_id, false)
end

function arc_warden_spark_wraith:OnProjectileHit( target, location )
	local thinker = self:GetCaster()
	local modifier = thinker:FindModifierByName("arc_warden_spark_wraith_thinker")
	local caster = modifier:GetCaster()
	if caster == nil then
		caster = PlayerResource:GetSelectedHeroEntity(thinker.player_id)
	end
	ApplyDamage({ victim = target, attacker = caster, damage = self:GetAbilityDamage(), damage_type = self:GetAbilityDamageType(), ["ability"] = self})
	local damage_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_base_attack_sparkles.vpcf", PATTACH_ROOTBONE_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(damage_particle)
	AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), self:GetSpecialValueFor("vision_radius"), 3.34, true)
	modifier:Destroy()
end

arc_warden_spark_wraith_thinker = class({})

function arc_warden_spark_wraith_thinker:OnCreated(event)
	if IsServer() then
		local thinker = self:GetParent()
		local ability = self:GetAbility()
		self.startup_time = ability:GetSpecialValueFor("startup_time")
		self.duration = ability:GetSpecialValueFor("duration")
		self.speed = ability:GetSpecialValueFor("speed")
		self.search_radius = ability:GetSpecialValueFor("search_radius")
		self.vision_radius = ability:GetSpecialValueFor("vision_radius")
		thinker:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
		local startup_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_buff_sphere3.vpcf", PATTACH_WORLDORIGIN, thinker)
		local thinker_pos = thinker:GetAbsOrigin()
		ParticleManager:SetParticleControl(startup_particle, 3, (thinker_pos + Vector(0, 0, 150)))
		self:StartIntervalThink(self.startup_time)
		self.startup_particle = startup_particle
		thinker:SetDayTimeVisionRange(self.vision_radius)
		thinker:SetNightTimeVisionRange(self.vision_radius)
		thinker:AddAbility("arc_warden_spark_wraith")
		thinker:FindAbilityByName("arc_warden_spark_wraith"):SetLevel(ability:GetLevel())
		thinker.player_id = ability:GetCaster():GetPlayerOwnerID()
	end
end

function arc_warden_spark_wraith_thinker:OnIntervalThink()
	local thinker = self:GetParent()
	local thinker_pos = thinker:GetAbsOrigin()
	if self.startup_time ~= nil then
		ParticleManager:DestroyParticle(self.startup_particle, false)
		self.startup_time = nil
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_buff_sphere.vpcf", PATTACH_WORLDORIGIN, thinker)
		ParticleManager:SetParticleControl(self.particle, 3, (thinker_pos + Vector(0, 0, 150)))
		self.expire = GameRules:GetGameTime() + self.duration
		self:StartIntervalThink(0)
	elseif self.duration ~= nil then
		if GameRules:GetGameTime() > self.expire then
			self:Destroy()
		else
			local enemies = FindUnitsInRadius(thinker:GetOpposingTeamNumber(), thinker_pos, nil, self.search_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_CLOSEST, false)
			if enemies[1] then
				self.target = enemies[1]
				self.duration = nil
				self.expire = nil
				self:StartIntervalThink(-1)
				local info = 
					{
					Target = enemies[1],
					Source = thinker,
					Ability = thinker:FindAbilityByName("arc_warden_spark_wraith"),	
					EffectName = "particles/units/heroes/hero_zuus/zuus_base_attack.vpcf",
					vSourceLoc = (thinker_pos + Vector(0, 0, 150)),
					bDrawsOnMinimap = false,
					iSourceAttachment = 1,
					iMoveSpeed = self.speed,
					bDodgeable = false,
					bProvidesVision = true,
					iVisionRadius = self.vision_radius,
					iVisionTeamNumber = thinker:GetTeamNumber(),
					bVisibleToEnemies = true,
					flExpireTime = nil,
					bReplaceExisting = false
					}
				ProjectileManager:CreateTrackingProjectile(info)
				ParticleManager:DestroyParticle(self.particle, false)
			end
		end
	else

	end
end

function arc_warden_spark_wraith_thinker:OnDestroy()
	if self.particle then
		ParticleManager:DestroyParticle(self.particle, false)
	end
end

function arc_warden_spark_wraith_thinker:CheckState()
	if self.duration then
		return {[MODIFIER_STATE_PROVIDES_VISION] = true}
	end
	return nil
end