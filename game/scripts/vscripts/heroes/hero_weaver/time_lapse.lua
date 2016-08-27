function TimeLapseSave( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage_taken = keys.DamageTaken
	local backtrack_time = keys.BacktrackTime
	local remember_interval = keys.Interval
	
	-- Temporary damage array and index
	if not ability.tempList then  ability.tempList = {} end
	if not ability.tempList[caster:GetUnitName()] then ability.tempList[caster:GetUnitName()] = {} end
	local casterTable = {}
	casterTable["health"] = caster:GetHealth()
	casterTable["mana"] = caster:GetMana()
	casterTable["position"] = caster:GetAbsOrigin()
	table.insert(ability.tempList[caster:GetUnitName()],casterTable)
	if caster:HasScepter() then
  	enemies = FindUnitsInRadius(caster:GetTeam(),
                                    caster:GetAbsOrigin(),
                                    nil,
                                    9999,
                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                                    FIND_ANY_ORDER,
                                    false)
  	for _,enemy in pairs(enemies) do
  		if not ability.tempList[enemy:GetName()] then ability.tempList[enemy:GetName()] = {} end
  		local enemyTable = {}
  		enemyTable["health"] = enemy:GetHealth()
  		enemyTable["mana"] = enemy:GetMana()
  		enemyTable["position"] = enemy:GetAbsOrigin()
  		table.insert(ability.tempList[enemy:GetName()],enemyTable)
  	end
	end
	
	local maxindex = backtrack_time/remember_interval
	if #ability.tempList[caster:GetUnitName()] > maxindex then
		table.remove(ability.tempList[caster:GetUnitName()],1)
		for _,enemy in pairs(enemies) do
			table.remove(ability.tempList[enemy:GetName()],1)
		end
	end
end

function TimeLapseRewind( keys )
	local target = keys.target
	local ability = keys.ability
	
	if target ~= caster and not caster:HasScepter() then 
	  caster:SetMana(caster:GetMana()+ability:GetManaCost(-1))
	  ability:EndCooldown()
	  return 
	end
	local health = ability.tempList[target:GetUnitName()][1]["health"]
	local mana = ability.tempList[target:GetUnitName()][1]["mana"]
	local position = ability.tempList[target:GetUnitName()][1]["position"]

	target:Interrupt()
	
	-- Adds damage to caster's current health
	particle_ground = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_ABSORIGIN  , target)
    ParticleManager:SetParticleControl(particle_ground, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_ground, 1, position) --radius
    ParticleManager:SetParticleControl(particle_ground, 2, position) --ammount of particle
	
	target:SetHealth(health)
	target:SetMana(mana)
	target:Purge(false,true,false,true,false)
	ProjectileManager:ProjectileDodge(target)
	FindClearSpaceForUnit(target, position, true)
end
