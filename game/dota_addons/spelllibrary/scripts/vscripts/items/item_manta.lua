--[[ ============================================================================================================
	Author: Rook, with help from Noya
	Date: February 2, 2015
	Returns a reference to a newly-created illusion unit.
================================================================================================================= ]]
function create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local player_id = keys.caster:GetPlayerID()
	local caster_team = keys.caster:GetTeam()
	
	local illusion = CreateUnitByName(keys.caster:GetUnitName(), illusion_origin, true, keys.caster, nil, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	--Level up the illusion to the caster's level.
	local caster_level = keys.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = keys.caster:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = keys.caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
		end
	end
	
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(keys.caster, keys.ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
	
	illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.

	return illusion
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 2, 2015
	Called when Manta Style is cast.  Performs the first part of Manta Style's active, where the caster becomes
	invulnerable and disappears briefly.
	Additional parameters: keys.CooldownMelee, keys.InvulnerabilityDuration, keys.VisionRadius
================================================================================================================= ]]
function item_manta_datadriven_on_spell_start(keys)
	if not keys.caster:IsRangedAttacker() then  --Manta Style's cooldown is less for melee heroes.
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(keys.CooldownMelee)
	end
	
	local manta_particle = ParticleManager:CreateParticle("particles/items2_fx/manta_phase.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	Timers:CreateTimer({  --Start a timer that stops the particle after a short time.
		endTime = keys.InvulnerabilityDuration, --When this timer will first execute
		callback = function()
			ParticleManager:DestroyParticle(manta_particle, false)
		end
	})
	
	keys.caster:EmitSound("DOTA_Item.Manta.Activate")
	
	--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions) 
	keys.caster:Purge(false, true, false, false, false)
	
	ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.
	
	--The caster is briefly made invulnerable and disappears, while ground vision is supplied nearby.
	keys.ability:CreateVisibilityNode(keys.caster:GetAbsOrigin(), keys.VisionRadius, keys.InvulnerabilityDuration)
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_manta_datadriven_invulnerability", nil)
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 2, 2015
	Called after Manta Style's brief invulnerability period ends.  Creates some illusions.
	Additional parameters: keys.IllusionIncomingDamageMelee, keys.IllusionOutgoingDamageMelee, 
		keys.IllusionIncomingDamageRanged, keys.IllusionOutgoingDamageRanged, keys.IllusionDuration,
================================================================================================================= ]]
function modifier_item_manta_datadriven_invulnerability_on_destroy(keys)
	local caster_origin = keys.caster:GetAbsOrigin()
	
	--Illusions are created to the North, South, East, or West of the hero (obviously, both cannot be created in the same direction).
	local illusion1_direction = RandomInt(1, 4)
	local illusion2_direction = (RandomInt(1, 3) + illusion1_direction) % 4  --This will ensure that the illusions will spawn in different directions.
	
	local illusion1_origin = nil
	local illusion2_origin = nil
	
	if illusion1_direction == 1 then  --North
		illusion1_origin = caster_origin + Vector(0, 100, 0)
	elseif illusion1_direction == 2 then  --South
		illusion1_origin = caster_origin + Vector(0, -100, 0)
	elseif illusion1_direction == 3 then  --East
		illusion1_origin = caster_origin + Vector(100, 0, 0)
	else  --West
		illusion1_origin = caster_origin + Vector(-100, 0, 0)
	end
	
	if illusion2_direction == 1 then  --North
		illusion2_origin = caster_origin + Vector(0, 100, 0)
	elseif illusion2_direction == 2 then  --South
		illusion2_origin = caster_origin + Vector(0, -100, 0)
	elseif illusion2_direction == 3 then  --East
		illusion2_origin = caster_origin + Vector(100, 0, 0)
	else  --West
		illusion2_origin = caster_origin + Vector(-100, 0, 0)
	end
	
	--Create the illusions.
	local illusion1 = nil
	local illusion2 = nil
	if keys.caster:IsRangedAttacker() then  --We don't have to worry about illusions switching from melee to ranged or vice versa because they can't use abilities.
		illusion1 = create_illusion(keys, illusion1_origin, keys.IllusionIncomingDamageRanged, keys.IllusionOutgoingDamageRanged, keys.IllusionDuration)
		illusion2 = create_illusion(keys, illusion2_origin, keys.IllusionIncomingDamageRanged, keys.IllusionOutgoingDamageRanged, keys.IllusionDuration)
	else  --keys.caster is melee.
		illusion1 = create_illusion(keys, illusion1_origin, keys.IllusionIncomingDamageMelee, keys.IllusionOutgoingDamageMelee, keys.IllusionDuration)
		illusion2 = create_illusion(keys, illusion2_origin, keys.IllusionIncomingDamageMelee, keys.IllusionOutgoingDamageMelee, keys.IllusionDuration)
	end
	
	--Reset our illusion origin variables because CreateUnitByName might have slightly changed the origin so that the unit won't be stuck.
	illusion1_origin = illusion1:GetAbsOrigin()
	illusion2_origin = illusion2:GetAbsOrigin()
	
	--Make it so all of the units are facing the same direction.
	local caster_forward_vector = keys.caster:GetForwardVector()
	illusion1:SetForwardVector(caster_forward_vector)
	illusion2:SetForwardVector(caster_forward_vector)
	
	--Randomize the positions of the illusions and the real hero.
	local hero_random_origin = RandomInt(1, 3)
	local illusion1_random_origin = (RandomInt(1, 2) + hero_random_origin) % 3  --This will ensure that this variable will be different from hero_random_origin.
	
	if hero_random_origin == 1 then
		keys.caster:SetAbsOrigin(caster_origin)
		if illusion1_random_origin == 2 then
			illusion1:SetAbsOrigin(illusion1_origin)
			illusion2:SetAbsOrigin(illusion2_origin)
		else  --illusion1_random_origin == 3
			illusion1:SetAbsOrigin(illusion2_origin)
			illusion2:SetAbsOrigin(illusion1_origin)
		end
	elseif hero_random_origin == 2 then
		keys.caster:SetAbsOrigin(illusion1_origin)
		if illusion1_random_origin == 1 then
			illusion1:SetAbsOrigin(caster_origin)
			illusion2:SetAbsOrigin(illusion2_origin)
		else  --illusion1_random_origin == 3
			illusion1:SetAbsOrigin(illusion2_origin)
			illusion2:SetAbsOrigin(caster_origin)
		end
	else  --hero_random_origin == 3
		keys.caster:SetAbsOrigin(illusion2_origin)
		if illusion1_random_origin == 1 then
			illusion1:SetAbsOrigin(caster_origin)
			illusion2:SetAbsOrigin(illusion1_origin)
		else  --illusion1_random_origin == 2
			illusion1:SetAbsOrigin(illusion1_origin)
			illusion2:SetAbsOrigin(caster_origin)
		end
	end
	
	--Set the health and mana values to those of the real hero.
	local caster_health = keys.caster:GetHealth()
	local caster_mana = keys.caster:GetMana()
	illusion1:SetHealth(caster_health)
	illusion1:SetMana(caster_mana)
	illusion2:SetHealth(caster_health)
	illusion2:SetMana(caster_mana)
	
	keys.caster:Stop()  --Start playing the idle animation.
end
		

--[[ ============================================================================================================
	Author: Noya
	Date: February 2, 2015
	Swaps the model with the given model.  Used when Manta Style is cast in order to briefly hide the caster.
	Additional parameters: keys.model
================================================================================================================= ]]
function SwapModelStart( keys )
	local target = keys.target
	local model = keys.model

	if target.target_model == nil then
		target.target_model = target:GetModelName()
	end

	target:SetOriginalModel(model)
end


--[[ ============================================================================================================
	Author: Noya
	Date: February 2, 2015
	Reverts the model to the original.  Used when Manta Style is cast in order to briefly hide the caster.
================================================================================================================= ]]
function SwapModelEnd( keys )
	local target = keys.target

	-- Checking for errors
	if target.target_model ~= nil then
		target:SetModel(target.target_model)
		target:SetOriginalModel(target.target_model)
	end
end


--[[ ============================================================================================================
	Author: Noya
	Date: February 2, 2015
	Hides hats.  Used when Manta Style is cast in order to briefly hide the caster.
================================================================================================================= ]]
function HideWearables( event )
	local hero = event.target
	local ability = event.ability
	print("Hiding Wearables")
	--hero:AddNoDraw() -- Doesn't work on classname dota_item_wearable

	hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
	hero.hiddenWearables = {} -- Keep every wearable handle in a table, as its way better to iterate than in the MovePeer system
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if string.find(modelName, "invisiblebox") == nil then
            	-- Add the original model name to revert later
            	table.insert(hero.wearableNames,modelName)
            	print("Hidden "..modelName.."")

            	-- Set model invisible
            	model:SetModel("models/development/invisiblebox.vmdl")
            	table.insert(hero.hiddenWearables,model)
            end
        end
        model = model:NextMovePeer()
        if model ~= nil then
        	print("Next Peer:" .. model:GetModelName())
        end
    end
end

--[[ ============================================================================================================
	Author: Noya
	Date: February 2, 2015
	Shows the hidden hero wearables.  Used when Manta Style is cast in order to briefly hide the caster.
================================================================================================================= ]]
function ShowWearables( event )
	local hero = event.target
	print("Showing Wearables on ".. hero:GetModelName())

	-- Iterate on both tables to set each item back to their original modelName
	for i,v in ipairs(hero.hiddenWearables) do
		for index,modelName in ipairs(hero.wearableNames) do
			if i==index then
				print("Changed "..v:GetModelName().. " back to "..modelName)
				v:SetModel(modelName)
			end
		end
	end
end