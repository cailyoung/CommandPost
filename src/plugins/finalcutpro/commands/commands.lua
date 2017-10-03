--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--               F I N A L    C U T    P R O    C O M M A N D S               --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- === plugins.finalcutpro.commands ===
---
--- The 'fcpx' command collection.
--- These are only active when FCPX is the active (ie. frontmost) application.

--------------------------------------------------------------------------------
--
-- EXTENSIONS:
--
--------------------------------------------------------------------------------
local log						= require("hs.logger").new("fcpxCmds")

local commands					= require("cp.commands")
local fcp						= require("cp.apple.finalcutpro")

--------------------------------------------------------------------------------
--
-- THE MODULE:
--
--------------------------------------------------------------------------------
local mod = {}

--------------------------------------------------------------------------------
--
-- THE PLUGIN:
--
--------------------------------------------------------------------------------
local plugin = {
	id				= "finalcutpro.commands",
	group			= "finalcutpro",
}

--------------------------------------------------------------------------------
-- INITIALISE PLUGIN:
--------------------------------------------------------------------------------
function plugin.init()

	--------------------------------------------------------------------------------
	-- New Final Cut Pro Command Collection:
	--------------------------------------------------------------------------------
	mod.cmds = commands:new("fcpx")

	--------------------------------------------------------------------------------
	-- Switch to Final Cut Pro to activate:
	--------------------------------------------------------------------------------
	mod.cmds:watch({
		activate	= function()
			--log.df("Final Cut Pro Activated by Commands Plugin")
			fcp:launch()
		end,
	})

	--------------------------------------------------------------------------------
	-- Enable/Disable as Final Cut Pro becomes Active/Inactive:
	--------------------------------------------------------------------------------
	mod.isEnabled = fcp.isFrontmost:AND(fcp.isModalDialogOpen:NOT()):watch(function(enabled)
		--log.df("Result: %s", enabled)
		mod.cmds:isEnabled(enabled)
	end)

	return mod.cmds
end

--------------------------------------------------------------------------------
-- POST INITIALISATION:
--------------------------------------------------------------------------------
function plugin.postInit()
	mod.isEnabled:update()
	log.df("postInit: is enabled = %s", mod.isEnabled())
end

return plugin