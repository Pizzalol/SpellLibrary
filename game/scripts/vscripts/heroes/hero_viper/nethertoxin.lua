--[[Author: Pizzalol
	Date: 19.12.2014.
	This is run whenever an attack is started to determine which modifier gets applied]]
function Nethertoxin( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local HPPercentage = (target:GetHealth()/target:GetMaxHealth())*100 -- Calculate the target HP percentage

	print("Hello !")
	print(HPPercentage)


	-- Apply a modifier depending on the HP percentage and unit type
	if(HPPercentage<=100 and HPPercentage>80) then
		if target:IsRealHero() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_100_hero_datadriven", {})
		else
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_100_creep_datadriven", {})
		end
	elseif(HPPercentage<=80 and HPPercentage>60) then
		if target:IsRealHero() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_80_hero_datadriven", {})
		else
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_80_creep_datadriven", {})
		end
	elseif(HPPercentage<=60 and HPPercentage>40) then
		if target:IsRealHero() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_60_hero_datadriven", {})
		else
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_60_creep_datadriven", {})
		end
	elseif(HPPercentage<=40 and HPPercentage>20) then
		if target:IsRealHero() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_40_hero_datadriven", {})
		else
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_40_creep_datadriven", {})
		end
	else
		print("Hello Im testing")
		if target:IsRealHero() then
			print("Im a hero!")
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_20_hero_datadriven", {})
		else
			print("Im not a hero :(")
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nethertoxin_20_creep_datadriven", {})
		end
	end
end