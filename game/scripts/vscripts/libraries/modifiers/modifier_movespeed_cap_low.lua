modifier_movespeed_cap_low = class({})

function modifier_movespeed_cap_low:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }

    return funcs
end

function modifier_movespeed_cap_low:GetModifierMoveSpeed_Max( params )
    return 0.1
end

function modifier_movespeed_cap_low:GetModifierMoveSpeed_Limit( params )
    return 0.1
end

function modifier_movespeed_cap_low:IsHidden()
    return true
end
