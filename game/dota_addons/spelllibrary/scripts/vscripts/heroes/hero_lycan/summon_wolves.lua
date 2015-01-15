--[[Kill wolves on resummon
	Author: chrislotix
	Date: 15.1.2015.]]

function KillWolves( keys )
	
	local targets = keys.target_entities
	local wolfname_1 = keys.wolf_name1
	local wolfname_2 = keys.wolf_name2
	local wolfname_3 = keys.wolf_name3
	local wolfname_4 = keys.wolf_name4 
	local caster = keys.caster	

	for _,unit in pairs(targets) do	
		
	   	if unit:GetUnitName() == (wolfname_1) or unit:GetUnitName() == (wolfname_2) or unit:GetUnitName() == (wolfname_3) or unit:GetUnitName() == (wolfname_4) and unit:GetOwner() == caster then
    	  unit:ForceKill(true) 
    	end
	end	
end
