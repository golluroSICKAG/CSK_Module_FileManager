---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_FileManager'

local fileManager_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
fileManager_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
fileManager_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
fileManager_Model.parametersName = 'CSK_FileManager_Parameter' -- name of parameter dataset to be used for this module
fileManager_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the FileManager_Model interface and give access
-- to the FileManager_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setFileManager_ModelHandle = require('System/FileManager/FileManager_Controller')
setFileManager_ModelHandle(fileManager_Model)

--Loading helper functions if needed
fileManager_Model.helperFuncs = require('System/FileManager/helper/funcs')

-- Optionally check if specific API was loaded via
--[[
if _G.availableAPIs.specific then
-- ... doSomething ...
end
]]

--[[
-- Create parameters / instances for this module
fileManager_Model.object = Image.create() -- Use any AppEngine CROWN
fileManager_Model.counter = 1 -- Short docu of variable
fileManager_Model.varA = 'value' -- Short docu of variable
--...
]]

-- Parameters to be saved permanently if wanted
fileManager_Model.parameters = {}
--fileManager_Model.parameters.paramA = 'paramA' -- Short docu of variable
--fileManager_Model.parameters.paramB = 123 -- Short docu of variable
--...

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--[[
-- Some internal code docu for local used function to do something
---@param content auto Some info text if function is not already served
local function doSomething(content)
  _G.logger:info(nameOfModule .. ": Do something")
  fileManager_Model.counter = fileManager_Model.counter + 1
end
fileManager_Model.doSomething = doSomething
]]

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return fileManager_Model
