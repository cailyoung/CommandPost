--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                      D E V E L O P E R     T O O L S                       --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- === cp.developer ===
---
--- Developer Tools
---

--[[

hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "q", function()
  require("cp.developer")
  print(_inspectAtMouse())
end)

--]]

--------------------------------------------------------------------------------
--
-- EXTENSIONS:
--
--------------------------------------------------------------------------------
local log			= require("hs.logger").new("develop")

local ax 			= require("hs._asm.axuielement")
local drawing		= require("hs.drawing")
local geometry		= require("hs.geometry")
local inspect		= require("hs.inspect")
local mouse			= require("hs.mouse")
local timer			= require("hs.timer")

local fcp			= require("cp.apple.finalcutpro")

--------------------------------------------------------------------------------
-- SHORTCUTS:
--------------------------------------------------------------------------------
_plugins			= require("cp.plugins")
_fcp				= require("cp.apple.finalcutpro")

--------------------------------------------------------------------------------
--
-- THE MODULE:
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- FIND UNUSED LANGUAGES STRINGS:
--------------------------------------------------------------------------------
function _findUnusedLanguageStrings()
	local translations = require("cp.resources.languages.en")["en"]
	local result = "\nUNUSED STRINGS IN EN.LUA:\n"
	local stringCount = 0
	local ignoreStart = {"plugin_group_", "shareDetails_", "plugin_status_", "plugin_action_", "shortcut_group_"}
	local ignoreEnd = {"_action", "_label", "_title", "_customTitle", "_group"}
	for string, _ in pairs(translations) do
		local skip = false
		for _, ignoreFile in pairs(ignoreStart) do
			if string.sub(string, 1, string.len(ignoreFile)) == ignoreFile then
				skip = true
			end
		end
		for _, ignoreFile in pairs(ignoreEnd) do
			if string.sub(string, string.len(ignoreFile) * -1) == ignoreFile then
				skip = true
			end
		end
		if not skip then
			local executeString = [[grep -r --max-count=1 --exclude-dir=resources --include \*.html --include \*.htm --include \*.lua ']] .. string .. [[' ']] .. hs.processInfo.bundlePath .. [[/']]
			local output, status = hs.execute(executeString)
			if not status then
				result = result .. string .. "\n"
				stringCount = stringCount + 1
			end
		end
	end
	if stringCount == 0 then
		result = result .. "None"
	end
	log.df(result)
end

--------------------------------------------------------------------------------
-- FIND TEXT:
--------------------------------------------------------------------------------
function _findString(string)
	local output, status = hs.execute([[grep -r ']] .. string .. [[' ']] .. fcp:getPath() .. [[/']])
	if status then
		log.df("Output: %s", output)
	else
		log.ef("An error occurred in _findString")
	end
end

--------------------------------------------------------------------------------
-- ELEMENT AT MOUSE:
--------------------------------------------------------------------------------
function _elementAtMouse()
    return ax.systemElementAtPosition(mouse.getAbsolutePosition())
end

--------------------------------------------------------------------------------
-- INSPECT ELEMENT AT MOUSE:
--------------------------------------------------------------------------------
function _inspectAtMouse(options)
    options = options or {}
    local element = _elementAtMouse()
    if options.parents then
        for i=1,options.parents do
            element = element ~= nil and element:parent()
        end
    end

    if element then
        local result = ""
        if options.type == "path" then
            local path = element:path()
            for i,e in ipairs(path) do
                result = result .._inspectElement(e, options, i)
            end
            return result
        else
            return inspect(element:buildTree(options.depth))
        end
    else
        return "<no element found>"
    end
end

--------------------------------------------------------------------------------
-- INSPECT:
--------------------------------------------------------------------------------
function _inspect(e, options)
    if e == nil then
        return "<nil>"
    elseif type(e) ~= "userdata" or not e.attributeValue then
        if type(e) == "table" and #e > 0 then
            local item = nil
            local result = ""
            for i=1,#e do
                item = e[i]
                result = result ..
                         "\n= " .. string.format("%3d", i) ..
                         " ========================================" ..
                         _inspect(item, options)
            end
            return result
        else
            return inspect(e, options)
        end
    else
        return "\n==============================================" ..
               _inspectElement(e, options)
    end
end

--------------------------------------------------------------------------------
-- INSPECT ELEMENT:
--------------------------------------------------------------------------------
function _inspectElement(e, options, i)
    _highlight(e)

    i = i or 0
    local depth = options and options.depth or 1
    local out = "\n      Role       = " .. inspect(e:attributeValue("AXRole"))

    local id = e:attributeValue("AXIdentifier")
    if id then
        out = out.. "\n      Identifier = " .. inspect(id)
    end

    out = out.. "\n      Children   = " .. inspect(#e)

    out = out.. "\n==============================================" ..
                "\n" .. inspect(e:buildTree(depth)) .. "\n"

    return out
end

--------------------------------------------------------------------------------
-- HIGHLIGHT ELEMENT:
--------------------------------------------------------------------------------
function _highlight(e)
    if not e or not e.frame then
        return e
    end

    local eFrame = geometry.rect(e:frame())

    --------------------------------------------------------------------------------
    -- Get Highlight Colour Preferences:
    --------------------------------------------------------------------------------
    local highlightColor = {["red"]=1,["blue"]=0,["green"]=0,["alpha"]=0.75}

    local highlight = drawing.rectangle(eFrame)
    highlight:setStrokeColor(highlightColor)
    highlight:setFill(false)
    highlight:setStrokeWidth(3)
    highlight:show()

    --------------------------------------------------------------------------------
    -- Set a timer to delete the highlight after 3 seconds:
    --------------------------------------------------------------------------------
    local highlightTimer = timer.doAfter(3,
    function()
        highlight:delete()
        highlightTimer = nil
    end)
	return e
end

--------------------------------------------------------------------------------
-- INSPECT ELEMENT AT MOUSE PATH:
--------------------------------------------------------------------------------
function _inspectElementAtMousePath()
    return inspect(_elementAtMouse():path())
end