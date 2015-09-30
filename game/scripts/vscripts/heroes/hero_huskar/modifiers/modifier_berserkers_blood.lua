if modifier_huskar_berserkers_blood_lua == nil then
    modifier_huskar_berserkers_blood_lua = class({})
end

--[[Author: Bude
	Date: 30.09.2015.
	Grants magical resistance and attackspeed and increases model size per modifier stack
	TODO: Particles and status effects need to be implemented correctly
	NOTE: Model size increase is probably inaccurate and also awfully jumpy
]]--

function modifier_huskar_berserkers_blood_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

--As described: Could not get the particles to work ...
--[[
function modifier_huskar_berserkers_blood_lua:GetStatusEffectName()
	return "particles/units/heroes/hero_huskar/huskar_berserker_blood_hero_effect.vpcf"
end

function modifier_huskar_berserkers_blood_lua:GetStatusEffectPriority()
	return 16
end
]]--

function modifier_huskar_berserkers_blood_lua:OnCreated()
	-- Variables
	self.berserkers_blood_magic_resist = self:GetAbility():GetSpecialValueFor( "resistance_per_stack" )
	self.berserkers_blood_attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus_per_stack" )
	self.berserkers_blood_model_size = self:GetAbility():GetSpecialValueFor("model_size_per_stack")
	self.berserkers_blood_hurt_health_ceiling = self:GetAbility():GetSpecialValueFor("hurt_health_ceiling")
	self.berserkers_blood_hurt_health_floor = self:GetAbility():GetSpecialValueFor("hurt_health_floor")
	self.berserkers_blood_hurt_health_step = self:GetAbility():GetSpecialValueFor("hurt_health_step")


    if IsServer() then
        --print("Created")
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

		local model_size = self.berserkers_blood_model_size
		local hurt_health_ceiling = self.berserkers_blood_hurt_health_ceiling
		local hurt_health_floor = self.berserkers_blood_hurt_health_floor
		local hurt_health_step = self.berserkers_blood_hurt_health_step


	    for current_health=hurt_health_ceiling, hurt_health_floor, -hurt_health_step do
	        if health_perc <= current_health then

	            newStackCount = newStackCount+1
	        else
	        	break
	        end
	    end
	   

    	local difference = newStackCount - oldStackCount

    	-- set stackcount
    	if difference ~= 0 then
    		caster:SetModelScale(caster:GetModelScale()+difference*model_size)
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