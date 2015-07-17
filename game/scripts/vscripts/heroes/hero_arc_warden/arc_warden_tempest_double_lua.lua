LinkLuaModifier( "arc_warden_tempest_double_modifier", "heroes/hero_arc_warden/arc_warden_tempest_double_lua.lua", LUA_MODIFIER_MOTION_NONE )


arc_warden_tempest_double = class({})

function arc_warden_tempest_double:OnSpellStart()
	
	local caster = self:GetCaster()
	local spawn_location = caster:GetOrigin()
	local health_cost = 1 - (self:GetSpecialValueFor("health_cost") / 100)
	local mana_cost = 1 - (self:GetSpecialValueFor("mana_cost") / 100)
	local duration = self:GetSpecialValueFor("duration")
	local health_after_cast = caster:GetHealth() * mana_cost
	local mana_after_cast = caster:GetMana() * health_cost

	caster:SetHealth(health_after_cast)
	caster:SetMana(mana_after_cast)
	local double = CreateUnitByName( caster:GetUnitName(), spawn_location, true, caster, caster:GetOwner(), caster:GetTeamNumber())
	double:SetControllableByPlayer(caster:GetPlayerID(), false)

	local caster_level = caster:GetLevel()
	for i = 2, caster_level do
		double:HeroLevelUp(false)
	end


	for ability_id = 0, 15 do
		local ability = double:GetAbilityByIndex(ability_id)
		if ability then
			
			ability:SetLevel(caster:GetAbilityByIndex(ability_id):GetLevel())
			if ability:GetName() == "arc_warden_tempest_double" then
				ability:SetActivated(false)
			end
		end
	end


	for item_id = 0, 5 do
		local item_in_caster = caster:GetItemInSlot(item_id)
		if item_in_caster ~= nil then
			local item_name = item_in_caster:GetName()
			if not (item_name == "item_aegis" or item_name == "item_smoke_of_deceit" or item_name == "item_recipe_refresher" or item_name == "item_refresher" or item_name == "item_ward_observer" or item_name == "item_ward_sentry") then
				local item_created = CreateItem( item_in_caster:GetName(), double, double)
				double:AddItem(item_created)
				item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges()) 
			end
		end
	end

	double:SetHealth(health_after_cast)
	double:SetMana(mana_after_cast)

	double:SetMaximumGoldBounty(0)
	double:SetMinimumGoldBounty(0)
	double:SetDeathXP(0)
	double:SetAbilityPoints(0) 

	double:SetHasInventory(false)
	double:SetCanSellItems(false)

	double:AddNewModifier(caster, self, "arc_warden_tempest_double_modifier", nil)
	double:AddNewModifier(caster, self, "modifier_kill", {["duration"] = duration})
	
end

arc_warden_tempest_double_modifier = class({})

function arc_warden_tempest_double_modifier:DeclareFunctions()
	return {MODIFIER_PROPERTY_SUPER_ILLUSION, MODIFIER_PROPERTY_ILLUSION_LABEL, MODIFIER_PROPERTY_IS_ILLUSION, MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function arc_warden_tempest_double_modifier:GetIsIllusion()
	return true
end

function arc_warden_tempest_double_modifier:GetModifierSuperIllusion()
	return true
end

function arc_warden_tempest_double_modifier:GetModifierIllusionLabel()
	return true
end

function arc_warden_tempest_double_modifier:OnTakeDamage( event )
	if event.unit:IsAlive() == false then
		event.unit:MakeIllusion()
	end
end

function arc_warden_tempest_double_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_ancestral_spirit.vpcf"
end

function arc_warden_tempest_double_modifier:IsHidden()
	return true
end

function arc_warden_tempest_double_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end