--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                   F I N A L    C U T    P R O    A P I                     --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- === cp.apple.finalcutpro.main.Inspector.GeneratorInspector ===
---
--- Generator Inspector Module.

--------------------------------------------------------------------------------
--
-- EXTENSIONS:
--
--------------------------------------------------------------------------------
local log								= require("hs.logger").new("generatorInspect")

local prop								= require("cp.prop")

--------------------------------------------------------------------------------
--
-- THE MODULE:
--
--------------------------------------------------------------------------------
local GeneratorInspector = {}

--- cp.apple.finalcutpro.main.Inspector.GeneratorInspector:new(parent) -> GeneratorInspector object
--- Method
--- Creates a new GeneratorInspector object
---
--- Parameters:
---  * `parent`		- The parent
---
--- Returns:
---  * A GeneratorInspector object
function GeneratorInspector:new(parent)
	local o = {
		_parent = parent,
		_child = {}
	}
	return prop.extend(o, GeneratorInspector)
end

--- cp.apple.finalcutpro.main.Inspector.GeneratorInspector:parent() -> table
--- Method
--- Returns the GeneratorInspector's parent table
---
--- Parameters:
---  * None
---
--- Returns:
---  * The parent object as a table
function GeneratorInspector:parent()
	return self._parent
end

--- cp.apple.finalcutpro.main.Inspector.GeneratorInspector:app() -> table
--- Method
--- Returns the `cp.apple.finalcutpro` app table
---
--- Parameters:
---  * None
---
--- Returns:
---  * The application object as a table
function GeneratorInspector:app()
	return self:parent():app()
end

--------------------------------------------------------------------------------
--
-- GENERATOR INSPECTOR:
--
--------------------------------------------------------------------------------

return GeneratorInspector