--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--             G L O B A L     C O M M A N D     C O L L E C T I O N          --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- === plugins.core.commands.global ===
---
--- The 'global' command collection.

--------------------------------------------------------------------------------
--
-- EXTENSIONS:
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- CommandPost Extensions:
--------------------------------------------------------------------------------
local commands                  = require("cp.commands")

--------------------------------------------------------------------------------
--
-- THE PLUGIN:
--
--------------------------------------------------------------------------------
local plugin = {
    id              = "core.commands.global",
    group           = "core",
}

--------------------------------------------------------------------------------
-- INITIALISE PLUGIN:
--------------------------------------------------------------------------------
function plugin.init()
    return commands.new("global")
end

return plugin