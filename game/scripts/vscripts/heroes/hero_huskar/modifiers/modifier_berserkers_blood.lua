if modifier_huskar_berserkers_blood_lua == nil then
    modifier_huskar_berserkers_blood_lua = class({})
end

function modifier_huskar_berserkers_blood_lua:GetStatusEffectName()
	return "particles/units/heroes/hero_huskar/huskar_berserker_blood_hero_effect.vpcf"
end

function modifier_huskar_berserkers_blood_lua:GetStatusEffectPriority()
	return 16
end

function modifier_huskar_berserkers_blood_lua:OnCreated()
	self.berserkers_blood_magic_resist = self:GetAbility():GetSpecialValueFor( "resistance_per_stack" )
	self.berserkers_blood_attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus_per_stack" )

    if IsServer() then
        print("Created")
        self:SetStackCount( 1 )
		self:GetParent():CalculateStatBonus()

		self:StartIntervalThink(0.1) 
    end
end

function modifier_huskar_berserkers_blood_lua:OnIntervalThink()
	if IsServer() then
		--print("Thinking")

		-- Variables
		local caster = self:GetParent()
		local oldStackCount = self:GetStackCount()
		local health_perc = caster:GetHealthPercent()/100
		local newStackCount = 1
		
		-- check to update stackcount here
		local maxcount = 14

	    local i = 0

	    for current_health=0.03, 0.87, 0.07 do
	        if health_perc <= current_health then

	            newStackCount = maxcount - i
	            print("setting count to " .. newStackCount)
	            break
	        end

	        i = i+1
	    end
	   
    	local difference = newStackCount - oldStackCount

    	-- set stackcount
    	if difference ~= 0 then
    		caster:SetModelScale(caster:GetModelScale()+difference*0.025)
    		self:SetStackCount( newStackCount )
    		self:ForceRefresh()
    	end
		
	end
end

function modifier_huskar_berserkers_blood_lua:OnRefresh()
	self.berserkers_blood_magic_resist = self:GetAbility():GetSpecialValueFor( "resistance_per_stack" )
	self.berserkers_blood_attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus_per_stack" )
	local StackCount = self:GetStackCount()
	local caster = self:GetParent()

    if IsServer() then
        print("Refreshed")
        --if self.particle_glow and self.particle_hero then
        	--ParticleManager:ReleaseParticleIndex(self.particle_glow)
        	--ParticleManager:ReleaseParticleIndex(self.particle_hero)
        --end

       	--local particle_glow = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
       	--self:AddParticle(particle_glow, false, false, 16, false, true)
        --ParticleManager:ReleaseParticleIndex(particle_glow)

        --local particle_hero = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_berserker_blood_hero_effect.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
        --self:AddParticle(particle_hero, false, false, 17, true, false)
        --ParticleManager:SetParticleControlEnt(particle_hero, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), false)
        --ParticleManager:SetParticleControl(self.particle_hero, 1, Vector(StackCount*10, StackCount*10, StackCount*10))
        --ParticleManager:SetParticleControl(self.particle_hero, 2, Vector(StackCount*10, StackCount*10, StackCount*10))
        --ParticleManager:ReleaseParticleIndex(particle_hero)

        self:GetParent():CalculateStatBonus()
    end
end

function modifier_huskar_berserkers_blood_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT 
	}

	return funcs
end

function modifier_huskar_berserkers_blood_lua:GetModifierMagicalResistanceBonus( params )
	return self:GetStackCount() * self.berserkers_blood_magic_resist
end

function modifier_huskar_berserkers_blood_lua:GetModifierAttackSpeedBonus_Constant ( params )
	return self:GetStackCount() * self.berserkers_blood_attack_speed
end