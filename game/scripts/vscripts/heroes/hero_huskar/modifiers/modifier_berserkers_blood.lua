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
	local atrrib = { MODIFIER_ATTRIBUTE_PERMANENT }

	return attrib
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
	self.berserkers_blood_magic_resist = self:GetAbility():GetSpecialValueFor( "resistance_per_stack" )
	self.berserkers_blood_attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus_per_stack" )
	self.berserkers_blood_model_size = self:GetAbility():GetSpecialValueFor("model_size_per_stack")

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
		
		-- check to update stackcount here
		local maxcount = 14

	    local i = 0

	    for current_health=0.03, 0.87, 0.07 do
	        if health_perc <= current_health then

	            newStackCount = maxcount - i
	            --print("setting count to " .. newStackCount)
	            break
	        end

	        i = i+1
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