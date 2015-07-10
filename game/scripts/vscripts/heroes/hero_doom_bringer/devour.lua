--[[Author: Pizzalol
	Date: 04.03.2015.
	Kills the target and applies a modifier with a duration according to the remaining hp of the target
	Checks if the target is in the allowed table for taking abilities
	If it is then get the abilities of the target and give them to the caster]]
function Devour( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local target_hp = target:GetHealth()
	local health_per_second = ability:GetLevelSpecialValueFor("health_per_second", ability_level)
	local modifier = keys.modifier
	local modifier_duration = target_hp/health_per_second

	-- Apply the modifier and kill the target
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = modifier_duration})
	target:Kill(ability, caster)

	-- Setting up the table for allowed devour targets
	local devour_table = {}
	local doom_empty1 = keys.doom_empty1
	local doom_empty2 = keys.doom_empty2

	-- Insert the names of the units that you want to be valid targets for ability stealing
	table.insert(devour_table, "npc_dota_neutral_polar_furbolg_ursa_warrior") -- Red Hellbear
	table.insert(devour_table, "npc_dota_neutral_giant_wolf") -- Small wolf
	table.insert(devour_table, "npc_dota_neutral_centaur_khan") -- Big centaur

	-- Checks if the killed unit is in the table for allowed targets
	for _,v in ipairs(devour_table) do
		if target:GetUnitName() == v then
			-- Get the first two abilities
			local ability1 = target:GetAbilityByIndex(0)
			local ability2 = target:GetAbilityByIndex(1)

			-- If we already devoured a target and stole an ability from before then clear it
			if caster.devour_ability1 then
				caster:SwapAbilities(doom_empty1, caster.devour_ability1, true, false)
				caster:RemoveAbility(caster.devour_ability1)
			end

			if caster.devour_ability2 then
				caster:SwapAbilities(doom_empty2, caster.devour_ability2, true, false) 
				caster:RemoveAbility(caster.devour_ability2)
			end

			-- Checks if the ability actually exist on the target
			if ability1 then
				-- Get the name and add it to the caster
				local ability1_name = ability1:GetAbilityName()
				caster:AddAbility(ability1_name)

				-- Make the stolen ability active, level it up and save it in the caster handle for later checks
				caster:SwapAbilities(doom_empty1, ability1_name, false, true)
				caster.devour_ability1 = ability1_name
				caster:FindAbilityByName(ability1_name):SetLevel(ability1:GetLevel())
			end

			-- Checks if the ability actually exist on the target
			if ability2 then
				-- Get the name and add it to the caster
				local ability2_name = ability2:GetAbilityName()
				caster:AddAbility(ability2_name)

				-- Make the stolen ability active, level it up and save it in the caster handle for later checks
				caster:SwapAbilities(doom_empty2, ability2_name, false, true)
				caster.devour_ability2 = ability2_name
				caster:FindAbilityByName(ability2_name):SetLevel(ability2:GetLevel())
			end
		end
	end
end

--[[Author: Pizzalol
	Date: 04.03.2015.
	Awards the bonus gold to the modifier owner only if the modifier owner is alive]]
function DevourGold( keys )
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local bonus_gold = ability:GetLevelSpecialValueFor("bonus_gold", ability_level)

	-- Give the gold only if the target is alive
	if target:IsAlive() then
		target:ModifyGold(bonus_gold, false, 0)
	end
end

--[[Author: igo95862, Noya
	Used by: Pizzalol
	Date: 04.03.2015.
	Disallows eating another unit while Devour is in progress]]
function DevourCheck( keys )
	local caster = keys.caster
	local modifier = keys.modifier
	local player = caster:GetPlayerOwner()
	local pID = caster:GetPlayerOwnerID()

	if caster:HasModifier(modifier) then
		caster:Stop()

		-- Play Error Sound
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", player)

		-- This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
		FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Can't Devour While Mouth is Full" } )
	end
end