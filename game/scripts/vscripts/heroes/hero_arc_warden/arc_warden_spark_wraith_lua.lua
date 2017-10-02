LinkLuaModifier( "arc_warden_spark_wraith_thinker", "heroes/hero_arc_warden/arc_warden_spark_wraith_lua.lua", LUA_MODIFIER_MOTION_HORIZONTAL )


arc_warden_spark_wraith_lua = class({})

function arc_warden_spark_wraith_lua:GetAOERadius()
	return self:GetSpecialValueFor( "search_radius" )
end

function arc_warden_spark_wraith_lua:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local team_id = caster:GetTeamNumber()
	local thinker = CreateModifierThinker(caster, self, "arc_warden_spark_wraith_thinker", {}, point, team_id, false)
end

function arc_warden_spark_wraith_lua:OnProjectileHit( target, location )
	local thinker = self:GetCaster()
	local modifier = thinker:FindModifierByName("arc_warden_spark_wraith_thinker")
	local caster = modifier:GetCaster()
	local spark_damage
	if caster:HasAbility("special_bonus_unique_arc_warden") and (caster:FindAbilityByName("special_bonus_unique_arc_warden"):GetLevel() ~= 0) then
		spark_damage = self:GetSpecialValueFor("spark_damage") + 250
	else
		spark_damage = self:GetSpecialValueFor("spark_damage")
	end
	if caster == nil then
		caster = PlayerResource:GetSelectedHeroEntity(thinker.player_id)
	end
	ApplyDamage({ victim = target, attacker = caster, damage = spark_damage, damage_type = self:GetAbilityDamageType(), ["ability"] = self})
	target:AddNewModifier( caster, self, "modifier_arc_warden_spark_wraith_purge", { duration = self:GetSpecialValueFor("ministun_duration") } )
	local damage_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj_hit.vpcf", PATTACH_ROOTBONE_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(damage_particle)
	thinker:StopSound("Hero_ArcWarden.SparkWraith.Activate")
	AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), self:GetSpecialValueFor("wraith_vision_radius"), self:GetSpecialValueFor("wraith_vision_duration"), true)
	modifier:Destroy()
end

arc_warden_spark_wraith_thinker = class({})

function arc_warden_spark_wraith_thinker:OnCreated(event)
	if IsServer() then
		local thinker = self:GetParent()
		local ability = self:GetAbility()
		self.activation_delay = ability:GetSpecialValueFor("activation_delay")
		self.duration = ability:GetSpecialValueFor("duration")
		self.speed = ability:GetSpecialValueFor("wraith_speed")
		self.search_radius = ability:GetSpecialValueFor("search_radius")
		self.vision_radius = ability:GetSpecialValueFor("wraith_vision_radius")
		thinker:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
		local thinker_pos = thinker:GetAbsOrigin()
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_wraith.vpcf", PATTACH_WORLDORIGIN, thinker)
		ParticleManager:SetParticleControl(self.particle, 0, thinker_pos)
		ParticleManager:SetParticleControl(self.particle, 1, Vector(self.search_radius,self.search_radius,0))
		self:StartIntervalThink(self.activation_delay)
		thinker:SetDayTimeVisionRange(self.vision_radius)
		thinker:SetNightTimeVisionRange(self.vision_radius)
		thinker:AddAbility("arc_warden_spark_wraith_lua")
		thinker:FindAbilityByName("arc_warden_spark_wraith_lua"):SetLevel(ability:GetLevel())
		thinker.player_id = ability:GetCaster():GetPlayerOwnerID()
	end
end

function arc_warden_spark_wraith_thinker:OnIntervalThink()
	local thinker = self:GetParent()
	local thinker_pos = thinker:GetAbsOrigin()
	if self.activation_delay ~= nil then
		self.activation_delay = nil
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
					Ability = thinker:FindAbilityByName("arc_warden_spark_wraith_lua"),	
					EffectName = "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj.vpcf",
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
				thinker:EmitSound("Hero_ArcWarden.SparkWraith.Activate")
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
