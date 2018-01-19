--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                   C  O  M  M  A  N  D  P  O  S  T                          --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- === plugins.finalcutpro.timeline.pluginactions ===
---
--- Adds Final Cut Pro Plugins (i.e. Effects, Generators, Titles and Transitions) to CommandPost Actions.

--------------------------------------------------------------------------------
--
-- EXTENSIONS:
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Logger:
--------------------------------------------------------------------------------
local log				= require("hs.logger").new("plgnactns")

--------------------------------------------------------------------------------
-- Hammerspoon Extensions:
--------------------------------------------------------------------------------
local chooser			= require("hs.chooser")
local drawing			= require("hs.drawing")
local screen			= require("hs.screen")
local timer				= require("hs.timer")

--------------------------------------------------------------------------------
-- CommandPost Extensions:
--------------------------------------------------------------------------------
local config			= require("cp.config")
local dialog			= require("cp.dialog")
local fcp				= require("cp.apple.finalcutpro")
local plugins			= require("cp.apple.finalcutpro.plugins")
local tools				= require("cp.tools")
local prop				= require("cp.prop")

--------------------------------------------------------------------------------
--
-- CONSTANTS:
--
--------------------------------------------------------------------------------
local PRIORITY 			= 3000
local MAX_SHORTCUTS 	= 5
local GROUP 			= "fcpx"

local format			= string.format

--------------------------------------------------------------------------------
--
-- THE MODULE:
--
--------------------------------------------------------------------------------
local mod = {}

-- plugins.finalcutpro.timeline.pluginactions._generateActionId(pluginType, action) -> string
-- Function
-- Generates a Action ID.
--
-- Parameters:
--  * pluginType - Plugin Type as string
--  * action - Action Table
--
-- Returns:
--  * Action ID as string
function mod._generateActionId(pluginType, action)
    local result = ""
    if action then
        if action.name then result = result .. action.name end
        if action.theme then result = result .. action.theme end
        if action.category then result = result .. action.category end
    end
    return result
end

--- plugins.finalcutpro.timeline.pluginactions.init(actionmanager, generators, titles, transitions, audioeffects, videoeffects) -> none
--- Function
--- Initialise the module.
---
--- Parameters:
---  * `actionmanager` - Action Manager Plugin
---  * `generators` - Generators Plugin
---  * `titles` - Titles Plugin
---  * `transitions` - Transitions Plugin
---  * `audioeffects` - Audio Effects Plugin
---  * `videoeffects` - Video Effects Plugin
---
--- Returns:
---  * The module
function mod.init(actionmanager, generators, titles, transitions, audioeffects, videoeffects)
	mod._manager = actionmanager
	mod._actors = {
		[plugins.types.generator]		= generators,
		[plugins.types.title]			= titles,
		[plugins.types.transition]		= transitions,
		[plugins.types.audioEffect]		= audioeffects,
		[plugins.types.videoEffect]		= videoeffects,
	}

	mod._handlers = {}

	for pluginType,_ in pairs(plugins.types) do

		mod._handlers[pluginType] = actionmanager.addHandler(GROUP .. "_" .. pluginType, GROUP)
		:onChoices(function(choices)
		    --------------------------------------------------------------------------------
			-- Get the effects of the specified type in the current language:
			--------------------------------------------------------------------------------
			local list = fcp:plugins():ofType(pluginType)
			if list then
				for i,plugin in ipairs(list) do
					local subText = i18n(pluginType .. "_group")
					if plugin.category then
						subText = subText..": "..plugin.category
					end
					if plugin.theme then
						subText = subText.." ("..plugin.theme..")"
					end
					choices:add(plugin.name)
						:subText(subText)
						:params(plugin)
						--:id(mod._generateActionId(pluginType, action))
				end
			end
		end)
		:onExecute(function(action)
			local actor = mod._actors[pluginType]
			if actor then
				actor.apply(action)
			else
				error(string.format("Unsupported plugin type: %s", pluginType))
			end
		end)
		--:onActionId(actionId)
	end

    --------------------------------------------------------------------------------
	-- Reset the handler choices when the Final Cut Pro language changes:
	--------------------------------------------------------------------------------
	fcp.currentLanguage:watch(function(value)
		for _,handler in pairs(mod._handlers) do
			handler:reset()
			timer.doAfter(0.01, function() handler.choices:update() end)
		end
	end)

	return mod
end

--------------------------------------------------------------------------------
--
-- THE PLUGIN:
--
--------------------------------------------------------------------------------
local plugin = {
	id = "finalcutpro.timeline.pluginactions",
	group = "finalcutpro",
	dependencies = {
		["core.action.manager"]					        = "actionmanager",
		["finalcutpro.timeline.generators"]				= "generators",
		["finalcutpro.timeline.titles"]					= "titles",
		["finalcutpro.timeline.transitions"]			= "transitions",
		["finalcutpro.timeline.audioeffects"]			= "audioeffects",
		["finalcutpro.timeline.videoeffects"]			= "videoeffects",
	}
}

--------------------------------------------------------------------------------
-- INITIALISE PLUGIN:
--------------------------------------------------------------------------------
function plugin.init(deps)
	return mod.init(deps.actionmanager, deps.generators, deps.titles, deps.transitions, deps.audioeffects, deps.videoeffects)
end

--------------------------------------------------------------------------------
-- POST INITIALISE PLUGIN:
--------------------------------------------------------------------------------
function plugin.postInit()
    --------------------------------------------------------------------------------
    -- Let's pre-load the choices to avoid delay when opening Console
    -- for first time:
    --------------------------------------------------------------------------------
    log.df("Loading Final Cut Pro Plugin Actions.")
    for _,handler in pairs(mod._handlers) do
        handler:reset()
        handler.choices:update()
    end
end

return plugin