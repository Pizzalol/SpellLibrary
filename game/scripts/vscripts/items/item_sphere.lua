--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	This function should be called from targeted datadriven abilities that can be blocked by Linken's Sphere.  
	Checks to see if the inputted unit has modifier_item_sphere_target on them.  If they do, the sphere is popped,
	the animation and sound plays, and true is returned.  If they do not, false is returned.
================================================================================================================= ]]
function is_spell_blocked_by_linkens_sphere(target)
	if target:HasModifier("modifier_item_sphere_target") then
		target:RemoveModifierByName("modifier_item_sphere_target")  --The particle effect is played automatically when this modifier is removed (but the sound isn't).
		target:EmitSound("DOTA_Item.LinkensSphere.Activate")
		return true
	end
	return false
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	Called when Linken's Sphere is cast.  Places a modifier_item_sphere_target on the targeted unit.
	Additional parameters: Keys.Duration
================================================================================================================= ]]
function item_sphere_datadriven_on_spell_start(keys)
	if keys.caster ~= keys.target then
		--Place the modifier on the target, but only if they don't already have a modifier_item_sphere_target (a maximum of
		--one of these modifiers is currently supported).
		if not keys.target:HasModifier("modifier_item_sphere_target") then
			keys.target:AddNewModifier(keys.caster, keys.ability, "modifier_item_sphere_target", {duration = keys.Duration})
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_sphere_datadriven_icon", {duration = -1})
		end
		keys.target:EmitSound("DOTA_Item.LinkensSphere.Target")
		
		--Remove the passively applied modifier from the caster while their Linken's Spheres are on cooldown.  The caster should
		--have at most one modifier_item_sphere_target on themselves.
		keys.caster:RemoveModifierByName("modifier_item_sphere_target")
		keys.caster.current_spellblock_is_passive = nil
	else  --If the player self-casted Linken's, which is currently disallowed for technical reasons.
		keys.ability:RefundManaCost()
		keys.ability:EndCooldown()
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", keys.caster:GetPlayerOwner())
		
		--This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
		FireGameEvent('custom_error_show', {player_ID = keys.caster:GetPlayerID(), _error = "Ability Can't Target Self"})
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	Called when Linken's Sphere is picked up.  Makes sure the caster has a passive modifier_item_sphere_target if 
	the item is off cooldown.
================================================================================================================= ]]
function modifier_item_sphere_datadriven_on_created(keys)
	if keys.ability ~= nil and keys.ability:IsCooldownReady() then
		if keys.caster:HasModifier("modifier_item_sphere_target") then  --Remove any potentially temporary version of the modifier and replace it with an indefinite one.
			keys.caster:RemoveModifierByName("modifier_item_sphere_target")
		end
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_sphere_target", {duration = -1})
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_sphere_datadriven_icon", {duration = -1})
		keys.caster.current_spellblock_is_passive = true
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	Called when Linken's Sphere is dropped, sold, etc.  Goes through the caster's inventory and determines whether
	they should still have a modifier_item_sphere_target.
================================================================================================================= ]]
function modifier_item_sphere_datadriven_on_destroy(keys)
	local num_off_cooldown_linkens_spheres_in_inventory = 0
	for i=0, 5, 1 do --Search for off-cooldown Linken's Spheres in the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_sphere_datadriven" and current_item:IsCooldownReady() then
				num_off_cooldown_linkens_spheres_in_inventory = num_off_cooldown_linkens_spheres_in_inventory + 1
			end
		end
	end
	
	--If the player just got rid of their last Linken's Sphere, which was providing the passive spellblock.
	if num_off_cooldown_linkens_spheres_in_inventory == 0 and keys.caster.current_spellblock_is_passive == true then
		keys.caster:RemoveModifierByName("modifier_item_sphere_target")
		keys.caster.current_spellblock_is_passive = nil
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	Called regularly while at least one Linken's Sphere is in the player's inventory.  Tries to determine if the 
	modifier_item_sphere_target	modifier on the hero has been expended, and sets the Linken's Spheres in the player's
	inventory on cooldown if one has been.
================================================================================================================= ]]
function modifier_item_sphere_datadriven_on_interval_think(keys)
	local num_off_cooldown_linkens_spheres_in_inventory = 0
	for i=0, 5, 1 do --Search for off-cooldown Linken's Spheres in the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_sphere_datadriven" and current_item:IsCooldownReady() then
				num_off_cooldown_linkens_spheres_in_inventory = num_off_cooldown_linkens_spheres_in_inventory + 1
			end
		end
	end

	if num_off_cooldown_linkens_spheres_in_inventory > 0 and not keys.caster:HasModifier("modifier_item_sphere_target") then
		if keys.caster.current_spellblock_is_passive == nil then  --If the Linken's Sphere just came off cooldown.
			keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_sphere_target", {duration = -1})
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_sphere_datadriven_icon", {duration = -1})
			keys.caster.current_spellblock_is_passive = true
		else  --keys.caster.current_spellblock_is_passive == true.
			--The Linken's was presumably popped passively.  Note that modifier_item_sphere_target is non-dispellable.
			keys.caster.current_spellblock_is_passive = nil
			for i=0, 5, 1 do --Put all Linken's Spheres in the player's inventory on cooldown.
				local current_item = keys.caster:GetItemInSlot(i)
				if current_item ~= nil then
					if current_item:GetName() == "item_sphere_datadriven" then
						current_item:StartCooldown(current_item:GetCooldown(current_item:GetLevel()))
					end
				end
			end
			num_off_cooldown_linkens_spheres_in_inventory = 0
		end
	end
	
	--The passive modifier from a Linken's supersedes the active one due to its indefinite duration, so remove any modifiers that
	--were transferred to this hero from an ally with a Linken's, now that an off-cooldown Linken's Sphere is in the player's inventory.
	if num_off_cooldown_linkens_spheres_in_inventory > 0 then
		keys.caster.current_spellblock_is_passive = true
		local caster_team = keys.caster:GetTeam()
		for i=0, 9, 1 do
			local hero = HeroList:GetHero(i)
			if hero ~= nil and hero ~= keys.caster and hero:GetTeam() ~= caster_team then
				keys.caster:RemoveModifierByNameAndCaster("modifier_item_sphere_target", hero)
			end
		end
	else  --num_off_cooldown_linkens_spheres_in_inventory == 0
		keys.caster.current_spellblock_is_passive = nil
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 30, 2015
	This public-facing modifier is placed on units when they receive the modifier_item_sphere_target modifier.
	Here, it regularly checks to see if the unit it's on still has modifier_item_sphere_target; if not, it removes itself.
================================================================================================================= ]]
function modifier_item_sphere_datadriven_icon_on_interval_think(keys)
	if not keys.target:HasModifier("modifier_item_sphere_target") then
		keys.target:RemoveModifierByName("modifier_item_sphere_datadriven_icon")
	end
end