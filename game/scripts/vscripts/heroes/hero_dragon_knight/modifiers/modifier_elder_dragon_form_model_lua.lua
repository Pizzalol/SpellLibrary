modifier_elder_dragon_form_model_lua = class({})

--[[Author: Noya
	Date: 27.01.2016.
	Changes the model of the unit into the Dragon Knight Elder Dragon Form model as long as the modifier is active]]
function modifier_elder_dragon_form_model_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_elder_dragon_form_model_lua:GetModifierModelChange()
	return "models/heroes/dragon_knight/dragon_knight_dragon.vmdl"
end

function modifier_elder_dragon_form_model_lua:IsHidden() 
	return true
end