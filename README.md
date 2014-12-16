SpellLibrary
============

Repo for recreating the original dota skills for the use of the Dota2 modding community

If you wish to contribute then it would be nice to do it in a way that would be readable and recognizable like this http://yrrep.me/dota/dota-standards.html

Forum thread - https://moddota.com/forums/discussion/23/spell-library

Progress spreadsheet - https://docs.google.com/spreadsheets/d/1oNoqMW2_PZ57TEonAQgMF-9JlApbt3LPNFtx72RhS8Y/edit#gid=0

Guidelines
==========

- Lua scripts should be separated on a per hero basis

- Every ability should be portable (i.e. 0 dependence on each other).
If the ability depends on another ability to function (Earth Spirit, Invoker, SF Requiem, etc) leave it for later.

- Don't Use Global Lua Events (related to making the spells portable). Abilities should work without any main addon scripts.

- Dont bother with Cast Animation, Aghs Upgrades or completely dota-hardcoded interactions

- Keep it as much datadriven as possible (for example don't lua FindUnitsInRadius if you only need to do aoe damage, use ActOnTargets Damage instead)

- Use default particles and sounds

- If you find an ability that seems hard or impossible to rewrite, ask and document your attempts, others will help you



Contributors
============


Special Thanks
==============
Noya for creating the ability guides

BMD for his libraries

Attero for his npc_abilities splitter
