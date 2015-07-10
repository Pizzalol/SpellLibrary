--[[
	Author: Noya
	Date: 25.01.2015.
	Checks for trees, if the spell didn't target one on its radius, interrupt with a message
]]
function CheckTrees( event )
	if event.ability:GetSpecialValueFor("check_trees_precast") == 1 then
		local caster = event.caster
		local pID = caster:GetPlayerID()
		local ability = event.ability
		local point = event.target_points[1]
		local area_of_effect = ability:GetLevelSpecialValueFor( "area_of_effect", ability:GetLevel() - 1 )

		if GridNav:IsNearbyTree( point, area_of_effect, true ) then
			--print(ability,"Trees found")
		else
			caster:Interrupt()
			FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Must target a tree." } )
		end
	end
end

--[[
	Author: Noya
	Date: 25.01.2015.
	Latches the tree_cut event to spawn treants up to the amount of trees destroyed, limited by the ability rank.
]]
function ForceOfNature( event )
	local caster = event.caster
	local pID = event.caster:GetPlayerID()
	local ability = event.ability
	local point = event.target_points[1]
	local area_of_effect = ability:GetLevelSpecialValueFor( "area_of_effect", ability:GetLevel() - 1 )
	local max_treants = ability:GetLevelSpecialValueFor( "max_treants", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local unit_name = event.UnitName

	-- Reinitialize the trees cut count
	ability.trees_cut = 0

	-- Check if listener is already running
	if not ability.listenerRunning then
		ability.listenerRunning = true
		ListenToGameEvent( "tree_cut", 
			function( event )
				ability.trees_cut = ability.trees_cut + 1
				--print(ability,"One tree cut")	
			end, 
		nil	)
	end

	-- Play the particle
	local particleName = "particles/units/heroes/hero_furion/furion_force_of_nature_cast.vpcf"
	local particle1 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( particle1, 0, point )
	ParticleManager:SetParticleControl( particle1, 1, point )
	ParticleManager:SetParticleControl( particle1, 2, Vector(area_of_effect,0,0) )

	-- Create the units on the next frame
	Timers:CreateTimer(0.03,
		function() 
			--print(ability.trees_cut)
			local treants_spawned = max_treants
			if ability.trees_cut < max_treants then
				treants_spawned = ability.trees_cut
			end

			-- Spawn as many treants as possible
			for i=1,treants_spawned do
				local treant = CreateUnitByName(unit_name, point, true, caster, caster, caster:GetTeamNumber())
				treant:SetControllableByPlayer(pID, true)
				treant:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
				FindClearSpaceForUnit(treant, point, true)
			end
		end
	)
end
