--[[
    author: jacklarnes
    email: christucket@gmail.com
    reddit: /u/jacklarnes
]]

function rage_start( keys )
    local caster = keys.caster

    caster:Purge(false, true, false, true, false)
end