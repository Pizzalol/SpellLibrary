--[[
	Author: kritth
	Date: 3.1.2015.
	Create timer to provide bonus damage
]]
function trueshot_initialize( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys. ability
	local prefix = "modifier_trueshot_damage_mod_"
	
	Timers:CreateTimer( DoUniqueString( "trueshot_updateDamage_" .. target:entindex() ), {
		endTime = 0.25,
		callback = function()
			-- Adjust damage based on agility of caster
			local agility = caster:GetAgility()
			local percent = ability:GetLevelSpecialValueFor( "trueshot_ranged_damage", ability:GetLevel() - 1 )
			local damage = math.floor( agility * percent / 100 )
			
			-- check if unit has attribute
			if not target.TrueshotDamage then
				target.TrueshotDamage = 0
			end
			
			-- Check if unit doesn't have buff
			if not target:HasModifier( "modifier_trueshot_effect_datadriven" ) then
				damage = 0
			end
			
			local damage_ref = damage
			
			-- If the stored value is different
			if target.TrueshotDamage ~= damage then
				-- modifier values
				local bitTable = { 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }
				
				-- Get the list of modifiers on the hero and loops through removing
				local modCount = target:GetModifierCount()
				for i = 0, modCount do
					for u = 1, #bitTable do
						local val = bitTable[u]
						if target:GetModifierNameByIndex( i ) == prefix .. val then
							target:RemoveModifierByName( prefix .. val )
						end
					end
				end
				
				-- Add modifiers
				for p = 1, #bitTable do
					local val = bitTable[p]
					local count = math.floor( damage / val )
					if count >= 1 then
						ability:ApplyDataDrivenModifier( caster, target, prefix .. val, {} )
						damage = damage - val
					end
				end
			end
			target.TrueshotDamage = damage_ref
			return 0.25
		end
	})
end
