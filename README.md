SpellLibrary
============

This repository is a collection of remade Dota 2 Hero abilities for the use of the Dota2 modding community by the Dota2 modding community

If you have any questions regarding the project or if you have found a bug/issue with the spells then feel free to [create an issue](https://github.com/Pizzalol/SpellLibrary/issues/new) or [contact us on irc](https://moddota.com/forums/chat)

[Forum thread](https://moddota.com/forums/discussion/23/spell-library)

[Progress so far](https://docs.google.com/spreadsheets/d/1oNoqMW2_PZ57TEonAQgMF-9JlApbt3LPNFtx72RhS8Y/edit#gid=0)

Contribution & Guidelines
=========================
If you wish to contribute to this project then it is prefered if you could follow the following guidelines when contributing

- Lua scripts should be separated on a per hero basis

- *Use as many AbilitySpecials as possible*, ***do not hardcode the lua file.***

- Don't use Global Lua Events, abilities should work without any main addon scripts.

- Don't bother with completely dota-hardcoded interactions

- Implementing Aghanims upgrades and casting animations is not neccessary

- Implementing Refresher compatibility is recommended but not mandatory

- Use default particles and sounds

- If you find an ability that seems hard or impossible to rewrite, ask and document your attempts, others will help you
- It is fine to use BMD's Timers and Physics libraries

- KV abilities should be saved as **abilityname_datadriven.txt** inside *scripts/npc/abilities/HERONAME/* folder
- Lua abilities should be saved as **abilityname_lua.txt** inside *scripts/npc/abilities/HERONAME/* folder
- Lua scripts should be saved as **abilityname.lua** inside *scripts/vscripts/heroes/hero_HERONAME/* folder

- Every KV file should have this in its header([EXAMPLE](https://github.com/Pizzalol/SpellLibrary/blob/master/game/scripts/npc/abilities/broodmother/spin_web_datadriven.txt#L1-L15))
~~~
// Rewrite of HERONAME ABILITYNAME
// Author: AUTHORNAME - the name of the author or authors that created this ability
// Date: MONTHNAME DAY, YEAR(eg. February 12, 2016) - date on which the file was created or had modifications
// Version: eg. 6.86 - latest game version for which this ability is up to date
// Type: Datadriven, Lua or Datadriven/Lua - what kind of type this ability is
// Notes: write any notes regarding the ability such as particle incomplete, minor differences compared to the original ability, etc.
//
// List the file requirements if the ability requires other files to function
// ----- FILE REQUIREMENTS -----
// Script files:
// scripts/vscripts/heroes/hero_HERONAME/ABILITYNAME.lua
//
// KV files:
// scripts/npc/abilities/HERONAME/ABILITYNAME_datadriven.txt
//
// Unit files:
// scripts/npc/units/UNITNAME.txt
~~~

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
    Date: Monthname Day, Year
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

- Modifier Name conventions

  - Start with "modifier_"
  - Then add the spell name (no hero name)
  - Add "_buff" "_debuff" "_stun" or anything when appropiate



Recommended resources
=====================
- [Tutorials](https://moddota.com/forums/categories/tutorials) the great Moddota tutorial collection

- [Dota2ModKit](https://github.com/stephenfournier/Dota-2-ModKit/releases) an essential tool for Dota 2 Modding

- [Workshop Tools Wiki](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools) the official Dota 2 Workshop Tools wiki


Special Thanks
==============
[Noya](https://github.com/MNoya) for many of his tutorials

[BMD](https://github.com/bmddota) for his libraries

[Attero](https://github.com/Attero) for his npc_abilities splitter

[cris9696](https://github.com/cris9696) for his files joiner

[zedor](https://github.com/zedor) for Custom Errors plugin

[Myll](https://github.com/stephenfournier) for his Dota2ModKit tool
