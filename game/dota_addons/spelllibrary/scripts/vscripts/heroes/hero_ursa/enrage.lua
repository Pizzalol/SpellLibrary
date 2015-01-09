--[[
	CHANGELIST
	09.01.2015 - Standized the variables
]]

--[[
	Author: kritth
	Date: 7.1.2015.
	Create a timer to periodically add/remove damage base on health
]]
function enrage_init( keys )
	-- Local variables
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_enrage_buff_datadriven"
	local percent = ability:GetLevelSpecialValueFor( "life_damage_bonus_percent", ability:GetLevel() - 1)
	
	-- Necessary data to pass into the timer iteration
	local prefix = "modifier_enrage_damage_mod_"
	local bitTable = { 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }

	
	-- Remove existing damage
	keys.caster.enrage_damage = 0
	
	-- Create Timer
	Timers:CreateTimer(
		function()
			-- Variables for each loop
			local damage = caster:GetMaxHealth() * ( percent / 100.0 )
			
			-- Check if user needs additional modifiers
			if caster.enrage_damage ~= damage then
				-- Remove all damage modifiers
				local modCount = caster:GetModifierCount()
				for i = 0, modCount do
					for u = 1, #bitTable do
						local val = bitTable[u]
						if caster:GetModifierNameByIndex(i) == prefix .. val then
							caster:RemoveModifierByName( prefix .. val )
						end
					end
				end
				
				-- Add damage modifiers
				local damage_tmp = damage
				for i = 1, #bitTable do
					local val = bitTable[i]
					local count = math.floor( damage_tmp / val )
					if count >= 1 then
						ability:ApplyDataDrivenModifier( caster, caster, prefix .. val, {} )
						damage_tmp = damage_tmp - val
					end
				end
			end
			
			-- Updates
			caster.enrage_damage = damage
			
			-- Check if it is time to remove the buff
			if caster:HasModifier( modifierName ) == false then
				-- Remove all damage modifiers
				local modCount = caster:GetModifierCount()
				for i = 0, modCount do
					for u = 1, #bitTable do
						local val = bitTable[u]
						if caster:GetModifierNameByIndex(i) == prefix .. val then
							caster:RemoveModifierByName( prefix .. val )
						end
					end
				end
				return nil
			else
				return 0.1
			end
		end
	)
end
