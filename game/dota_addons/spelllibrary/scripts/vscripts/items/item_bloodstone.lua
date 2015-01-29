--[[ ============================================================================================================
	Author: Rook
	Date: January 29, 2015
	Called when Bloodstone is cast.  Denies the unit.
================================================================================================================= ]]
function item_bloodstone_datadriven_on_spell_start(keys)
	keys.caster:Kill(keys.ability, keys.caster)
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 29, 2015
	Called when a hero affected by Bloodstone's hidden aura (i.e. a hero within range of an enemy with a Bloodstone) dies.
	Increases the charges on the item.
================================================================================================================= ]]
function modifier_item_bloodstone_datadriven_aura_on_death(keys)
	 --Search for a Bloodstone in the aura creator's inventory.  If there are multiple Bloodstones in the player's inventory,
	 --the one in the highest inventory slot gains a charge.
	local bloodstone_in_highest_slot = nil
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then			
			if current_item:GetName() == "item_bloodstone_datadriven" then
				bloodstone_in_highest_slot = current_item
			end
		end
	end

	if bloodstone_in_highest_slot ~= nil then
		bloodstone_in_highest_slot:SetCurrentCharges(bloodstone_in_highest_slot:GetCurrentCharges() + 1)
	end
	
	item_bloodstone_datadriven_recalculate_charge_bonuses(keys)
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when a hero is killed by the player.  Increases the charges on the Bloodstone if the killed hero was not within range.
================================================================================================================= ]]
function modifier_item_bloodstone_datadriven_aura_emitter_on_hero_kill(keys)
	--We want to award a charge in the event of a long-range kill as well.  The killed unit will still have the aura modifier
	--on them if they are in range (in which case modifier_item_bloodstone_datadriven_aura_on_death() would award the killer a charge),
	--but will not have the modifier if they are out of range.
	if keys.unit:GetTeam() ~= keys.attacker:GetTeam() and not keys.unit:HasModifier("modifier_item_bloodstone_datadriven_aura") then
		modifier_item_bloodstone_datadriven_aura_on_death(keys)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 29, 2015
	Called whenever a unit has a Bloodstone's charge count altered.  Calculates what their gold lost on death should
	be and makes sure the corresponding modifier is applied.  This function is necessary because of the way we need a
	specific modifier with a hardcoded MODIFIER_PROPERTY_DEATHGOLDCOST for each possible charge value.  A unit should
	only have at most one Bloodstone charge modifier regardless of how many Bloodstones they have.
================================================================================================================= ]]
function item_bloodstone_datadriven_recalculate_charge_bonuses(keys)
	local total_charge_count = 0

	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil and current_item:GetName() == "item_bloodstone_datadriven" then
			total_charge_count = total_charge_count + current_item:GetCurrentCharges()
		end
	end

	--Temporarily remove all existing Bloodstone charge modifiers on the unit.
	while keys.caster:HasModifier("modifier_item_bloodstone_datadriven_charge") do
		keys.caster:RemoveModifierByName("modifier_item_bloodstone_datadriven_charge")
	end
	
	--Apply modifiers giving the player bonus mana regen and less gold lost on death.
	for i=1, total_charge_count, 1 do
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_bloodstone_datadriven_charge", nil)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 29, 2015
	Called when a player with Bloodstone in their inventory dies.  Heals nearby allies, provides vision around the
	spot they died in, allows them to gain experience there while dead, removes charges from the item, and reduces
	the respawn time left depending on the number of charges that had been built up.  The "OnDeath" event is called
	after the player died and has lost gold from death.
	Additional parameters: keys.HealOnDeathRange, keys.HealOnDeathBase, keys.HealOnDeathPerCharge,
	keys.VisionOnDeathRadius, keys.RespawnTimeReductionPerCharge, keys.OnDeathChargePercent, and keys.ExperienceOnDeathRange
	Known bugs:
		Buying back does not prematurely end the vision in the spot the hero died at.
		Dying with a Bloodstone in your inventory, then moving the Bloodstone out of your inventory will halt the experience
		    gained in the area of your death.
================================================================================================================= ]]
function modifier_item_bloodstone_datadriven_aura_emitter_on_death(keys)
	--Reduce the hero's time spent dead for each charge on all Bloodstones in the player's inventory.
	local total_charge_count = 0
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil and current_item:GetName() == "item_bloodstone_datadriven" then
			local current_charges = current_item:GetCurrentCharges()
			total_charge_count = total_charge_count + current_charges
			
			--Reduce the number of charges left on this Bloodstone.
			local charges_left = math.floor(current_charges * keys.OnDeathChargePercent)
			if charges_left < 0 then
				charges_left = 0
			end
			current_item:SetCurrentCharges(charges_left)
		end
	end
	
	--Heal nearby allied units.
	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.HealOnDeathRange,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i, nearby_ally in ipairs(nearby_allied_units) do
		nearby_ally:Heal(keys.HealOnDeathBase + (keys.HealOnDeathPerCharge * total_charge_count), keys.caster)
		ParticleManager:CreateParticle("particles/items_fx/bloodstone_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, nearby_ally)
	end
	
	--Reduce the time the cast spends dead.  This works correctly when killed by Necrophos' Reaper's Scythe as well.
	local new_time_until_respawn = keys.caster:GetRespawnTime() - (total_charge_count * keys.RespawnTimeReductionPerCharge)
	if new_time_until_respawn < 0 then
		new_time_until_respawn = 0
	end
	
	--Place the Bloodstone marker in the spot the hero died.
	local bloodstone_glyph = ParticleManager:CreateParticle("particles/items_fx/bloodstone_glyph.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(bloodstone_glyph, 1, Vector(new_time_until_respawn))  --Set the duration of the Bloodstone glyph particle.
	keys.ability:CreateVisibilityNode(keys.caster:GetAbsOrigin(), keys.VisionOnDeathRadius, new_time_until_respawn)  --Provide vision around the Bloodstone glyph.
	
	--If this is the hero's first death with a Bloodstone, start a global engine event listener so they can gain experience while dead.
	--Ideally, a game event will be listened to only once, so beware of other items or abilities that invoke this game event.
	if keys.caster.HasDiedWithBloodstoneBefore == nil then
		ListenToGameEvent("entity_killed", function(keys)  --Allow the caster to gain experience around the spot they died in, if they are still dead and had a Bloodstone in their inventory.
			local killed_entity = EntIndexToHScript(keys.entindex_killed)
			local attacker_entity = EntIndexToHScript(keys.entindex_attacker)

			for i, individual_hero in ipairs(HeroList:GetAllHeroes()) do
				if individual_hero:HasItemInInventory("item_bloodstone_datadriven") and not individual_hero:IsAlive() then  --If the hero is still dead and has a Bloodstone.
					if individual_hero:GetTeam() ~= killed_entity:GetTeam() and individual_hero:GetRangeToUnit(killed_entity) <= 1200 then  --If the killed unit is an enemy and within range of the Bloodstone glyph.
						if killed_entity:GetTeam() ~= attacker_entity:GetTeam()then  --If the killed entity was not denied.
							individual_hero:AddExperience(killed_entity:GetDeathXP(), false, false)
						elseif not killed_entity:IsHero() then  --If the killed entity was denied.  Denied heroes do not award experience.
							individual_hero:AddExperience(killed_entity:GetDeathXP() * .5, false, false)  --Denied creeps grant 50% experience.  Change this value if this mechanic is ever changed.
						end
					end
				end
			end
		end, nil)
		keys.caster.HasDiedWithBloodstoneBefore = true
	end
	
	keys.caster:SetTimeUntilRespawn(new_time_until_respawn)
	
	item_bloodstone_datadriven_recalculate_charge_bonuses(keys)
end