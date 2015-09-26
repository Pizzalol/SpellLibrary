modifier_shapeshift_model_lua = class({})

--[[Author: Noya
	Date: 26.09.2015.
	Changes the model of the unit into the lycan shapeshift model as long as the modifier is active]]
function modifier_shapeshift_model_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_shapeshift_model_lua:GetModifierModelChange()
	return "models/heroes/lycan/lycan_wolf.vmdl"
end

function modifier_shapeshift_model_lua:IsHidden() 
	return true
end