SpellLibrary
============

Repo for recreating the original dota skills for the use of the Dota2 modding community

If you have any questions regarding the project or if you have found a bug/issue with the spells then feel free to create an issue or PM/Email either [Noya](https://github.com/MNoya) or [Pizzalol](https://github.com/Pizzalol)

Emails: [martinnoya@gmail.com](martinnoya@gmail.com) / [dario.siprak@gmail.com](dario.siprak@gmail.com)

If you wish to contribute then it would be nice to do it in a way that would be readable and recognizable like this http://yrrep.me/dota/dota-standards.html

[Forum thread](https://moddota.com/forums/discussion/23/spell-library)

[Progress spreadsheet](https://docs.google.com/spreadsheets/d/1oNoqMW2_PZ57TEonAQgMF-9JlApbt3LPNFtx72RhS8Y/edit#gid=0)

Guidelines
==========

- Lua scripts should be separated on a per hero basis

- Use as many AbilitySpecials as possible, ***do not hardcode the lua file.***

- Every ability should be portable (i.e. 0 dependence on each other).
  - If the ability depends on another ability to function (Earth Spirit, Invoker, SF Requiem, etc) leave it for later.

- Don't Use Global Lua Events (related to making the spells portable). Abilities should work without any main addon scripts.

- Dont bother with Cast Animation, Aghs Upgrades or completely dota-hardcoded interactions

- Use default particles and sounds

- If you find an ability that seems hard or impossible to rewrite, ask and document your attempts, others will help you

- Follow this coding style:

For Datadriven KeyValues
~~~
"OnSpellStart"
{
    "RunScript"
    {
        "ScriptFile"    "heroes/hero_name/ability_name.lua"
        "Function"      "AbilityName"
    }
}
~~~

For Lua functions
~~~
--[[
    Author:
    Date: Day.Month.2015.
    (Description)
]]
function AbilityName( event )
    -- Variables
    local caster = event.caster
    local ability = event.ability
    local value = = ability:GetLevelSpecialValueFor( "value" , ability:GetLevel() - 1  )

    -- Try to comment each block of logical actions
    -- If the ability handle is not nil, print a message
    if ability then
        print("RunScript")
    end
end
~~~

- Modifier Name conventions (very important for automating tooltips later)

  - Start with "modifier_"
  - Then add the spell name (no hero name)
  - Add "_buff" "_debuff" "_stun" or anything when appropiate



Recommended resources
=====================
- [Tutorials](https://moddota.com/forums/categories/tutorials) the great tutorials made by [Noya](https://moddota.com/forums/profile/5/Noya)

- [Dota 2 Modkit](https://github.com/stephenfournier/Dota-2-ModKit/releases) great tool when it comes to everything Dota 2 modding related, made by [Myll](https://github.com/Myll)

- [Sound editor](https://dl.dropboxusercontent.com/u/19417676/dota_sound_editor_v1.3.1.zip) the sound editor for finding the proper ability sounds, made by [pingzing](https://github.com/pingzing)

- [Workshop Tools Wiki](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools) the official Dota 2 Workshop Tools wiki

- [Decompiled particles](https://mega.co.nz/#!BpYUmCgJ!_Ks49abeMdgn9t4nL-yMP26BrjuHZLpiHE18p_bS-pg) provided by [Toraxxx](https://github.com/Toraxxx)


Special Thanks
==============
[Noya](https://github.com/MNoya) for creating the ability guides

[BMD](https://github.com/bmddota) for his libraries

[Attero](https://github.com/Attero) for his npc_abilities splitter

[cris9696](https://github.com/cris9696) for his files joiner

[zedor](https://github.com/zedor) for Custom Errors plugin
