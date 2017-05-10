--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                    S H O R T C U T   C O M M A N D S                       --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- === cp.commands.shortcut ===
---
--- Shortcut Commands

--------------------------------------------------------------------------------
--
-- EXTENSIONS:
--
--------------------------------------------------------------------------------
local log										= require("hs.logger").new("shortcut")

local eventtap									= require("hs.eventtap")
local hotkey									= require("hs.hotkey")
local keycodes									= require("hs.keycodes")
local englishKeyCodes							= require("cp.commands.englishKeyCodes")
local prop										= require("cp.prop")

--------------------------------------------------------------------------------
--
-- THE MODULE:
--
--------------------------------------------------------------------------------

-- The shortcut class
local shortcut = {}

-- The shortcut builder class
local builder = {}

-- shortcut.textToKeyCode() -> string
-- Function
-- Translates string into a key code.
--
-- Parameters:
--  * input - string
--
-- Returns:
--  * Keycode as String or ""
function shortcut.textToKeyCode(input)
	local result = englishKeyCodes[input]
	if not result then
		result = keycodes.map[input]
		if not result then
			result = ""
		end
	end
	return result
end

--- cp.commands.shortcut:new(modifiers, keyCode) -> shortcut
--- Method
--- Creates a new keyboard shortcut, attached to the specified `hs.commands.command`
---
--- Parameters:
---  * `modifiers` 	- The modifiers.
---  * `keyCode`	- The key code.
---
--- Returns:
---  * shortcut - The shortcut that was created.
function shortcut:new(modifiers, keyCode)
	local o = {
		_modifiers	= modifiers or {},
		_keyCode	= keyCode,
	}
	return prop.extend(o, shortcut)
end

--- cp.commands.shortcut:build(receiverFn) -> cp.commands.shortcut.builder
--- Method
--- Creates a new shortcut builder.
---
--- Parameters:
---  * `receiverFn`		- (optional) a function which will get passed the shortcut when the build is complete.
---
--- Returns:
---  * `shortcut.builder` which can be used to create the shortcut.
---
--- Notes:
--- * If provided, the receiver function will be called when the shortcut has been configured, and passed the new
---   shortcut. The result of that function will be returned to the next stage.
---   If no `receiverFn` is provided, the shortcut will be returned directly.
---
---   The builder is additive. You can create a complex keystroke combo by
---   chaining the shortcut names together.
---
---   For example:
---
---     `local myShortcut = shortcut:build():cmd():alt("x")`
---
---   Alternately, provide a `receiver` function and it will get passed the shortcut instead:
---
---     `shortcut:build(function(shortcut) self._myShortcut = shortcut end):cmd():alt("x")`
function shortcut:build(receiverFn)
	return builder:new(receiverFn)
end

-- TODO: Add documentation
function shortcut:getModifiers()
	return self._modifiers
end

-- TODO: Add documentation
function shortcut:getKeyCode()
	return self._keyCode
end

--- cp.commands.shortcut:isEnabled <cp.prop: boolean>
--- Field
--- If `true`, the shortcut is enabled.
shortcut.isEnabled = prop(
	function(self) return self._enabled end,
	function(enabled, self)
		self._enabled = enabled
		if self._hotkey then
			if enabled then
				self._hotkey:enable()
			else
				self._hotkey:disable()
			end
		end
	end
):bind(shortcut)

--- cp.commands.shortcut:enable() - > shortcut
--- Method
--- This enables the shortcut. If a hotkey has been bound, it will be enabled also.
---
--- Parameters:
---  * N/A
---
--- Returns:
---  * `self`
function shortcut:enable()
	self:isEnabled(true)
	return self
end

--- cp.commands.shortcut:enable() - > shortcut
--- Method
--- This enables the shortcut. If a hotkey has been bound, it will be enabled also.
---
--- Parameters:
---  * None
---
--- Returns:
---  * `self`
function shortcut:disable()
	self:ifEnabled(false)
	return self
end

--- cp.commands.shortcut:bind(pressedFn, releasedFn, repeatedFn) -> shortcut
--- Method
--- This function binds the shortcut to a hotkey, with the specified callback functions for `pressedFn`, `releasedFn` and `repeatedFn`.
---
--- Parameters:
---  * `pressedFn`	- (optional) If present, this is called when the shortcut combo is pressed.
---  * `releasedFn`	- (optional) If present, this is called when the shortcut combo is released.
---  * `repeatedFn`	- (optional) If present, this is called when the shortcut combo is repeated.
---
--- Returns:
---  * `self`
---
--- Notes:
---  * If the shortcut is enabled, the hotkey will also be enabled at this point.
function shortcut:bind(pressedFn, releasedFn, repeatedFn)
	-- Unbind any existing hotkey
	self:unbind()
	-- Bind a new one with the specified calleback functions.
	local keyCode = shortcut.textToKeyCode(self:getKeyCode())
	if keyCode ~= nil and keyCode ~= "" then
		self._hotkey = hotkey.new(self:getModifiers(), keyCode, pressedFn, releasedFn, repeatedFn)
		self._hotkey.shortcut = self
		if self:isEnabled() then
			self._hotkey:enable()
		end
	else
		--TODO: Why it this happening?
		log.wf("Unable to find key code for '%s'.", self:getKeyCode())
	end
	return self
end

-- TODO: Add documentation
function shortcut:unbind()
	local hotkey = self._hotkey
	if hotkey then
		hotkey:disable()
		hotkey:delete()
		self._hotkey = nil
	end
	return self
end

-- TODO: Add documentation
function shortcut:delete()
	-- unhook the hotkeys
	self:unbind()
	return self
end

--- cp.commands.shortcut:trigger() -> shortcut
--- Method
--- This will trigger the keystroke specified in the shortcut.
---
--- Parameters:
---  * N/A
---
--- Returns:
---  * `self`
function shortcut:trigger()
	local keyCode = shortcut.textToKeyCode(self:getKeyCode())
	eventtap.keyStroke(self._modifiers, keyCode)
	return self
end

function shortcut:__tostring()
	local modifiers = table.concat(self._modifiers, "+")
	return string.format("shortcut: %s %s", modifiers, self:getKeyCode())
end

--- === cp.commands.shortcut.builder ===
---
--- Shortcut Commands Builder Module.

--- cp.commands.shortcut.builder:new(receiverFn)
--- Method
--- Creates a new shortcut builder. If provided, the receiver function
--- will be called when the shortcut has been configured, and passed the new
--- shortcut. The result of that function will be returned to the next stage.
--- If no `receiverFn` is provided, the shortcut will be returned directly.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function builder:new(receiverFn)
	local o = {
		_receiver	= receiverFn,
		_modifiers 	= modifiers or {},
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

--- cp.commands.shortcut.builder:add(modifier, [keyCode]) -> shortcut/command
--- Method
--- Adds the specified modifier to the set. If a `keyCode` is provided,
--- no more modifiers can be added and the original `command` is returned instead.
--- Otherwise, `self` is returned and further modifiers can be added.
---
--- Parameters:
---  * modifier - (optional) The modifier that was added.
---  * keyCode	- (optional) The key code being modified.
---
--- Returns:
---  * `self` if no `keyCode` is provided, or the original `command`.
function builder:add(modifier, keyCode)
	self._modifiers[#self._modifiers + 1] = modifier
	if keyCode then
		self._keyCode = keyCode
		-- we're done here
		local shortcut = shortcut:new(self._modifiers, keyCode)
		if self._receiver then
			return self._receiver(shortcut)
		else
			return
		end
		return self._command:addShortcut(self)
	else
		return self
	end
end

-- TODO: Add documentation
function builder:control(keyCode)
	return self:add("control", keyCode)
end

-- TODO: Add documentation
function builder:ctrl(keyCode)
	return self:control(keyCode)
end

-- TODO: Add documentation
function builder:option(keyCode)
	return self:add("option", keyCode)
end

-- TODO: Add documentation
function builder:alt(keyCode)
	return self:option(keyCode)
end

-- TODO: Add documentation
function builder:command(keyCode)
	return self:add("command", keyCode)
end

-- TODO: Add documentation
function builder:cmd(keyCode)
	return self:command(keyCode)
end

-- TODO: Add documentation
function builder:shift(keyCode)
	return self:add("shift", keyCode)
end

return shortcut