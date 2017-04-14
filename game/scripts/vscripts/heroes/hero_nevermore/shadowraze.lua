--[[
	Author: Noya + nc-dk
	Date: March 4, 2017
	Obtains a forward position relative to caster, then fires effects and does damage to units within the area of effect.
]]
function Raze( keys )
	local caster = keys.caster
	local ability = keys.ability

	--Finding Raze location
	local vOrigin = caster:GetAbsOrigin()
	local vForward = caster:GetForwardVector()
	local iDistance = ability:GetSpecialValueFor("shadowraze_range")
	local ability_location = vOrigin + vForward * iDistance

	--Radius and damage
	local ability_damage = ability:GetSpecialValueFor("shadowraze_damage")
	local damage_radius = ability:GetSpecialValueFor("shadowraze_radius")

	--Create Shadowraze particle on damage origin
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_CUSTOMORIGIN, nil) --Setting an owning entity hides the particle if the handle cannot be see by a player
	ParticleManager:SetParticleControl(particle, 0, ability_location)
	ParticleManager:SetParticleControl(particle, 1, ability_location)

	--Fires sound at target location
	EmitSoundOnLocationWithCaster(ability_location, "Hero_Nevermore.Shadowraze", caster)

	--Finds legal targets on damage location
	local target_table = FindUnitsInRadius(caster:GetTeam(), ability_location, nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if #target_table > 0 then
		for _, enemy in pairs (target_table) do
			ApplyDamage({ victim = enemy, attacker = caster, damage = ability_damage, damage_type = DAMAGE_TYPE_MAGICAL })
		end
	end
end

---

--[[
	Author: nc-dk
	Date: March 4, 2017
	Whenever the datadriven "OnUpgrade" event is triggered on one Shadowraze, level all three to the same ability.
]]
function LevelRaze( keys )
	--If any Shadowraze is levelled up, skill them to the same level
	
	--Obtaining general ability info
	local ability = keys.ability
	local ability_name = ability:GetAbilityName()
	local ability_level = ability:GetLevel()
	local caster = keys.caster

	--Getting all Shadowraze's on the caster
	local raze1 = caster:FindAbilityByName("nevermore_shadowraze1_datadriven")
	local raze2 = caster:FindAbilityByName("nevermore_shadowraze2_datadriven")
	local raze3 = caster:FindAbilityByName("nevermore_shadowraze3_datadriven")
	
	--If the current Shadowraze isn't the one used in the ability, attempt to skill it.
	if raze1 ~= ability_name then
		if raze1:GetLevel() < ability_level then --Less then to prevent a loop (when the other Raze's are levelled, they'll call upon this script too).
			raze1:SetLevel(ability_level)
		end
	end

	if raze2 ~= ability_name then
		if raze2:GetLevel() < ability_level then
			raze2:SetLevel(ability_level)
		end
	end

	if raze3 ~= ability_name then
		if raze3:GetLevel() < ability_level then
			raze3:SetLevel(ability_level)
		end
	end
end
