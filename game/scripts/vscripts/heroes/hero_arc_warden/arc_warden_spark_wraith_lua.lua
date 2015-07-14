LinkLuaModifier( "arc_warden_spark_wraith_thinker", "heroes/hero_arc_warden/arc_warden_spark_wraith_lua.lua", LUA_MODIFIER_MOTION_HORIZONTAL )


arc_warden_spark_wraith = class({})

function arc_warden_spark_wraith:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local team_id = caster:GetTeamNumber()
	local thinker = CreateModifierThinker(caster, self, "arc_warden_spark_wraith_thinker", {}, point, team_id, false)
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
		self.damage = ability:GetAbilityDamage()
		self.damage_type = ability:GetAbilityDamageType()
		local startup_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_buff_sphere3.vpcf", PATTACH_WORLDORIGIN, thinker)
		local thinker_pos = thinker:GetAbsOrigin()
		ParticleManager:SetParticleControl(startup_particle, 3, (thinker_pos + Vector(0, 0, 150)))
		self:StartIntervalThink(self.startup_time)
		self.startup_particle = startup_particle
		thinker:SetDayTimeVisionRange(self.vision_radius)
		thinker:SetNightTimeVisionRange(self.vision_radius)
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
				self.time = GameRules:GetGameTime()
			end
		end
	else
		local current_time = GameRules:GetGameTime()
		self:UpdateHorizontalMotion(thinker, current_time - self.time)
		self.time = current_time
	end
end

function arc_warden_spark_wraith_thinker:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function arc_warden_spark_wraith_thinker:UpdateHorizontalMotion(thinker, time)
	if IsServer() then
		local thinker_pos = thinker:GetAbsOrigin()
		local target_pos = self.target:GetAbsOrigin()
		local bounds_radius = 24
		local direction = (target_pos - thinker_pos):Normalized()
		local next_pos = GetGroundPosition(thinker_pos + direction * self.speed * time, thinker)
		thinker:SetAbsOrigin(next_pos)
		ParticleManager:SetParticleControl(self.particle, 3, (next_pos + Vector(0, 0, 150)))
		if (next_pos - target_pos):Length2D() < bounds_radius then
			self:Damage()
		end
	end
end

function arc_warden_spark_wraith_thinker:Damage()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	ApplyDamage({ victim = self.target, attacker = caster, damage = self.damage, damage_type = self.damage_type, ["ability"] = ability})
	local damage_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_base_attack_sparkles.vpcf", PATTACH_ROOTBONE_FOLLOW, self.target)
	ParticleManager:ReleaseParticleIndex(damage_particle)
	AddFOWViewer(caster:GetTeamNumber(), self.target:GetAbsOrigin(), self.vision_radius, 3.34, true)
	self:Destroy()
end

function arc_warden_spark_wraith_thinker:OnDestroy()
	if self.particle then
		ParticleManager:DestroyParticle(self.particle, false)
	end
end

function arc_warden_spark_wraith_thinker:CheckState() 
	return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end