--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                   F I N A L    C U T    P R O    A P I                     --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- === cp.apple.finalcutpro.export.ReplaceAlert ===
---
--- Replace Alert

--------------------------------------------------------------------------------
--
-- EXTENSIONS:
--
--------------------------------------------------------------------------------
local axutils						= require("cp.ui.axutils")
local prop							= require("cp.prop")

--------------------------------------------------------------------------------
--
-- THE MODULE:
--
--------------------------------------------------------------------------------
local ReplaceAlert = {}

-- TODO: Add documentation
function ReplaceAlert.matches(element)
	if element then
		return element:attributeValue("AXRole") == "AXSheet"			-- it's a sheet
		   and axutils.childWithRole(element, "AXTextField") == nil 	-- with no text fields
	end
	return false
end

-- TODO: Add documentation
function ReplaceAlert:new(parent)
	local o = {_parent = parent}
	return prop.extend(o, ReplaceAlert)
end

-- TODO: Add documentation
function ReplaceAlert:parent()
	return self._parent
end

-- TODO: Add documentation
function ReplaceAlert:app()
	return self:parent():app()
end

-- TODO: Add documentation
function ReplaceAlert:UI()
	return axutils.cache(self, "_ui", function()
		return axutils.childMatching(self:parent():UI(), ReplaceAlert.matches)
	end,
	ReplaceAlert.matches)
end

--- cp.apple.finalcutpro.export.ReplaceAlert.isShowing <cp.prop: boolean; read-only>
--- Field
--- Is the Replace File alert showing?
ReplaceAlert.isShowing = prop.new(function(self)
	return self:UI() ~= nil
end):bind(ReplaceAlert)

-- TODO: Add documentation
function ReplaceAlert:hide()
	self:pressCancel()
end

-- TODO: Add documentation
function ReplaceAlert:pressCancel()
	local ui = self:UI()
	if ui then
		local btn = ui:cancelButton()
		if btn then
			btn:doPress()
		end
	end
	return self
end

-- TODO: Add documentation
function ReplaceAlert:pressReplace()
	local ui = self:UI()
	if ui then
		local btn = ui:defaultButton()
		if btn and btn:enabled() then
			btn:doPress()
		end
	end
	return self
end

-- TODO: Add documentation
function ReplaceAlert:getTitle()
	local ui = self:UI()
	return ui and ui:title()
end

return ReplaceAlert