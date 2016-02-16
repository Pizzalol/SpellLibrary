--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Randomly creates illusions of the caster]]
function ConjureImage( event )
	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerID()
	
	local proc_chance = 0
	local rand = math.random(1,100)
	local max_illusions =  ability:GetLevelSpecialValueFor( "max_illusions", ability:GetLevel() - 1 )
	local current_illusions = 0
	
	-- Gets the ability owned by the original caster, so we can keep track of the number of illusions
	local original_hero = PlayerResource:GetSelectedHeroEntity(player)
	local ability_name = ability:GetAbilityName()
	local original_ability = original_hero:FindAbilityByName(ability_name)
	
	-- Sets the proc chance based on the caster type
	if caster:IsIllusion() then
		proc_chance = ability:GetLevelSpecialValueFor( "illusion_proc_chance", ability:GetLevel() - 1 )
	else
		proc_chance = ability:GetLevelSpecialValueFor( "hero_proc_chance", ability:GetLevel() - 1 )
	end	
	
	if original_ability.illusions == nil then
		original_ability.illusions = 0
	else
		current_illusions = original_ability.illusions
	end
	
	-- If there is a proc and there are not too many illusions, creates a new one
	if rand <= proc_chance and current_illusions <= max_illusions then
	
		original_ability.illusions = original_ability.illusions + 1
	
		local target = event.target
		local unit_name = caster:GetUnitName()
		local origin = target:GetAbsOrigin() + RandomVector(100)
		local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
		local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
		local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
		illusion:SetControllableByPlayer(player, true)
	
		-- Level Up the unit to the casters level
		local casterLevel = caster:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end

		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
		for abilitySlot=0,15 do
			local ability = caster:GetAbilityByIndex(abilitySlot)
			if ability ~= nil then 
				local abilityLevel = ability:GetLevel()
				local abilityName = ability:GetAbilityName()
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				illusionAbility:SetLevel(abilityLevel)
			end
		end

		-- Recreate the items of the caster
		for itemSlot=0,5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, illusion, illusion)
				illusion:AddItem(newItem)
			end
		end

		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
	
		-- This modifier is applied to every illusion to check if they die or expire
		ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_illusion_count", {Duration = duration})
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Decrements the illusion count when one dies or expires]]
function DecrementCount(keys)
	local caster = keys.caster
	local ability = keys.ability
	local player = caster:GetPlayerID()
	
	local original_hero = PlayerResource:GetSelectedHeroEntity(player)
	local ability_name = ability:GetAbilityName()
	local original_ability = original_hero:FindAbilityByName(ability_name)
	
	original_ability.illusions = original_ability.illusions - 1
end
