--[[ ============================================================================================================
	Author: Rook
	Date: February 4, 2015
	Called when Medallion of Courage is cast.  Applies an armor debuff to the caster.  If cast on an enemy, applies
	an armor debuff to them as well; if cast on an ally, applies an armor buff to them.
================================================================================================================= ]]
function item_medallion_of_courage_datadriven_on_spell_start(keys)	
	if keys.caster:GetTeam() == keys.target:GetTeam() then  --If Medallion of Courage is cast on an ally.
		if keys.caster ~= keys.target then  --If Medallion of Courage wasn't self-casted.
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_medallion_of_courage_datadriven_debuff", nil)
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_medallion_of_courage_datadriven_buff", nil)
			
			keys.caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
			keys.target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		else  --If Medallion of Courage was self-casted, which it's not supposed to be able to do.
			keys.ability:RefundManaCost()
			keys.ability:EndCooldown()
			EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", keys.caster:GetPlayerOwner())
			
			--This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
			FireGameEvent('custom_error_show', {player_ID = keys.caster:GetPlayerID(), _error = "Ability Can't Target Self"})
		end
	else  --If Medallion of Courage is cast on an enemy.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_medallion_of_courage_datadriven_debuff", nil)
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_medallion_of_courage_datadriven_debuff", nil)
		
		keys.caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		keys.target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
	end
end