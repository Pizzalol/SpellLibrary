--[[
	Author: Noya
	Date: April 5, 2015.
	FURION CAN YOU TP TOP? FURION CAN YOU TP TOP? CAN YOU TP TOP? FURION CAN YOU TP TOP? 
]]
function Teleport( event )
	local caster = event.caster
	local point = event.target_points[1]
	
    FindClearSpaceForUnit(caster, point, true)
    caster:Stop()
    --ParticleManager:DestroyParticle(unit.teleport_particle,false)
    --caster:StopSound("Hero_KeeperOfTheLight.Recall.Cast")
    
end