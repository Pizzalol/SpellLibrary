--[[
	Author: Noya
	Date: April 5, 2015
	Creates the Life Drain Particle rope. 
	It is indexed on the caster handle to have access to it later, because the Color CP changes if the drain is restoring mana.
]]
function LifeDrainParticle( event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local particleName = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"
	caster.LifeDrainParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(caster.LifeDrainParticle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

end

--[[
	Author: Noya
	Date: April 5, 2015
	When cast on an enemy, drains health from the target enemy unit to heal himself. 
	If the hero has full HP, and the enemy target is a Hero, Life Drain will restore mana instead.
	When cast on an ally, it will drain his own health into his ally.
]]
function LifeDrainHealthTransfer( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local health_drain = ability:GetLevelSpecialValueFor( "health_drain" , ability:GetLevel() - 1 )
	local tick_rate = ability:GetLevelSpecialValueFor( "tick_rate" , ability:GetLevel() - 1 )
	local HP_drain = health_drain * tick_rate

	-- HP drained depends on the actual damage dealt. This is for MAGICAL damage type
	local HP_gain = HP_drain * ( 1 - target:GetMagicalArmorValue())

	print(HP_drain,target:GetMagicalArmorValue(),HP_gain)

	-- Act according to the targets team
	local targetTeam = target:GetTeamNumber()
	local casterTeam = caster:GetTeamNumber()

	-- If its an illusion then kill it
	if target:IsIllusion() then
		target:ForceKill(true)
		ability:OnChannelFinish(false)
		caster:Stop()
		return
	else
		-- Location variables
		local caster_location = caster:GetAbsOrigin()
		local target_location = target:GetAbsOrigin()

		-- Distance variables
		local distance = (target_location - caster_location):Length2D()
		local break_distance = ability:GetCastRange()
		local direction = (target_location - caster_location):Normalized()

		-- If the leash is broken then stop the channel
		if distance >= break_distance then
			ability:OnChannelFinish(false)
			caster:Stop()
			return
		end

		-- Make sure that the caster always faces the target
		caster:SetForwardVector(direction)
	end

	if targetTeam == casterTeam then
		-- Health Transfer Caster->Ally
		ApplyDamage({ victim = caster, attacker = caster, damage = HP_drain, damage_type = DAMAGE_TYPE_MAGICAL })
		target:Heal( HP_gain, caster)
		--TODO: Check if this damage transfer should be lethal
		
		-- Set the particle control color as green
		ParticleManager:SetParticleControl(caster.LifeDrainParticle, 10, Vector(0,0,0))
		ParticleManager:SetParticleControl(caster.LifeDrainParticle, 11, Vector(0,0,0))

	else
		if caster:GetHealthDeficit() > 0 then
			-- Health Transfer Enemy->Caster
			ApplyDamage({ victim = target, attacker = caster, damage = HP_drain, damage_type = DAMAGE_TYPE_MAGICAL })
			caster:Heal( HP_gain, caster)

			-- Set the particle control color as green
			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 10, Vector(0,0,0))
			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 11, Vector(0,0,0))

		elseif target:IsHero() then
			-- Health to Mana Transfer Enemy->Caster
			ApplyDamage({ victim = target, attacker = caster, damage = HP_drain, damage_type = DAMAGE_TYPE_MAGICAL })
			caster:GiveMana(HP_gain)

			-- Set the particle control color as BLUE
			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 10, Vector(1,0,0))
			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 11, Vector(1,0,0))
		end
	end
end

function LifeDrainParticleEnd( event )
	local caster = event.caster
	ParticleManager:DestroyParticle(caster.LifeDrainParticle,false)
end