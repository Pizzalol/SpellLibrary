--[[
	Author: kritth
	Date: 6.1.2015.
	Register target
]]
function assassinate_register_target( keys )
	keys.caster.assassinate_target = keys.target
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Remove debuff from target
]]
function assassinate_remove_target( keys )
	if keys.caster.assassinate_target then
		keys.caster.assassinate_target:RemoveModifierByName( "modifier_assassinate_target_datadriven" )
		keys.caster.assassinate_target = nil
	end
end
