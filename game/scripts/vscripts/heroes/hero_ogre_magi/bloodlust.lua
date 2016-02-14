--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Scales target's model by 125%]]
function ChangeModel(keys)
	local target = keys.target
	local ability = keys.ability
	local model_scale = ability:GetLevelSpecialValueFor( "model_scale", ability:GetLevel() - 1 )
	
	-- Instant scaling, as opposed to the gradual way it happens in Dota
	target:SetModelScale(model_scale)
end

--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Reverts the target's model to normal scale]]
function RevertModel(keys)
	local target = keys.target
	
	-- Instant scaling, as opposed to the gradual way it happens in Dota
	target:SetModelScale(1)
end
