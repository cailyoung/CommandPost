--- hs.finalcutpro.App
---
--- Represents the Final Cut Pro X application, providing functions that allow different tasks to be accomplished.
---
--- Author: David Peterson (david@randombits.org)
---

--- Standard Modules
local application								= require("hs.application")
local ax 										= require("hs._asm.axuielement")
local inspect									= require("hs.inspect")
local log										= require("hs.logger").new("fcpxapp")

--- Local Modules
local MenuBar									= require("hs.finalcutpro.MenuBar")
local PreferencesWindow							= require("hs.finalcutpro.prefs.PreferencesWindow")
local PrimaryWindow								= require("hs.finalcutpro.main.PrimaryWindow")

--- The App module
local App = {}

--- Constants
App.BUNDLE_ID 							= "com.apple.FinalCut"
App.PASTEBOARD_UTI 						= "com.apple.flexo.proFFPasteboardUTI"

--- hs.finalcutpro.App:new() -> App
--- Function
--- Creates a new App instance representing Final Cut Pro
---
--- Parameters:
---  * N/A
---
--- Returns:
---  * True is successful otherwise Nil
---
function App:new()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

--- hs.finalcutpro.App:application() -> hs.application
--- Function
--- Returns the hs.application for Final Cut Pro X.
---
--- Parameters:
---  * N/A
---
--- Returns:
---  * The hs.application, or nil if the application is not installed.
---
function App:application()
	return application(App.BUNDLE_ID) or nil
end

function App:UI()
	local fcp = self:application()
	return fcp and ax.applicationElement(fcp)
end

--- hs.finalcutpro.running() -> boolean
--- Function
--- Is Final Cut Pro Running?
---
--- Parameters:
---  * None
---
--- Returns:
---  * True if Final Cut Pro is running otherwise False
---
function App:isRunning()
	local fcpx = self:application()
	return fcpx and fcpx:isRunning()
end

function App:menuBar()
	if not self._menuBar then
		self._menuBar = MenuBar:new(self)
	end
	return self._menuBar
end

function App:preferencesWindow()
	if not self._preferencesWindow then
		self._preferencesWindow = PreferencesWindow:new(self)
	end
	return self._preferencesWindow
end

function App:primaryWindow()
	if not self._primaryWindow then
		self._primaryWindow = PrimaryWindow:new(self)
	end
	return self._primaryWindow
end

--- hs.finalcutpro.App:windowsUI() -> axuielement
--- Function
--- Returns the UI containing the list of windows in the app.
---
--- Parameters:
---  * N/A
---
--- Returns:
---  * The axuielement, or nil if the application is not running.
---
function App:windowsUI()
	local ui = self:UI()
	return ui and ui:attributeValue("AXWindows")
end

--- hs.finalcutpro.App:timeline() -> Timeline
--- Function
--- Returns the Timeline instance, whether it is in the primary or secondary window.
---
--- Parameters:
---  * N/A
---
--- Returns:
---  * the Timeline
function App:timeline()
	return self:primaryWindow():timeline()
end	

--- hs.finalcutpro.App:viewer() -> Viewer
--- Function
--- Returns the Viewer instance, whether it is in the primary or secondary window.
---
--- Parameters:
---  * N/A
---
--- Returns:
---  * the Viewer
function App:viewer()
	return self:primaryWindow():viewer()
end	

--- hs.finalcutpro.App:eventViewer() -> Viewer
--- Function
--- Returns the Event Viewer instance, whether it is in the primary or secondary window.
---
--- Parameters:
---  * N/A
---
--- Returns:
---  * the Event Viewer
function App:eventViewer()
	return self:primaryWindow():viewer()
end	

--- hs.finalcutpro.App:browser() -> Browser
--- Function
--- Returns the Browser instance, whether it is in the primary or secondary window.
---
--- Parameters:
---  * N/A
---
--- Returns:
---  * the Browser
function App:browser()
	return self:primaryWindow():browser()
end	


----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
-- 
-- DEBUG FUNCTIONS
--
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

function App:_listWindows()
	log.d("Listing FCPX windows:")
	local windows = self:windowsUI()
	for i,w in ipairs(windows) do
		debugMessage(string.format("%7d", i)..": "..self:_describeWindow(w))
	end
	
	debugMessage("")
	debugMessage("   Main: "..self:_describeWindow(self:UI():mainWindow()))
	debugMessage("Focused: "..self:_describeWindow(self:UI():focusedWindow()))
end

function App:_describeWindow(w)
	return "title: "..inspect(w:title()).."; role: "..inspect(w:role()).."; subrole: "..inspect(w:subrole()).."; modal: "..inspect(w:modal())
end

return App