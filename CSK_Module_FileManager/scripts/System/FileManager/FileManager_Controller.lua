---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the FileManager_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_FileManager'

-- Timer to update UI via events after page was loaded
local tmrFileManager = Timer.create()
tmrFileManager:setExpirationTime(300)
tmrFileManager:setPeriodic(false)

-- Reference to global handle
local fileManager_Model

-- ************************ UI Events Start ********************************

-- Script.serveEvent("CSK_FileManager.OnNewEvent", "FileManager_OnNewEvent")
Script.serveEvent("CSK_FileManager.OnNewStatusLoadParameterOnReboot", "FileManager_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_FileManager.OnPersistentDataModuleAvailable", "FileManager_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_FileManager.OnNewParameterName", "FileManager_OnNewParameterName")
Script.serveEvent("CSK_FileManager.OnDataLoadedOnReboot", "FileManager_OnDataLoadedOnReboot")

Script.serveEvent('CSK_FileManager.OnUserLevelOperatorActive', 'FileManager_OnUserLevelOperatorActive')
Script.serveEvent('CSK_FileManager.OnUserLevelMaintenanceActive', 'FileManager_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_FileManager.OnUserLevelServiceActive', 'FileManager_OnUserLevelServiceActive')
Script.serveEvent('CSK_FileManager.OnUserLevelAdminActive', 'FileManager_OnUserLevelAdminActive')

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("FileManager_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("FileManager_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("FileManager_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("FileManager_OnUserLevelAdminActive", status)
end

--- Function to get access to the fileManager_Model object
---@param handle handle Handle of fileManager_Model object
local function setFileManager_Model_Handle(handle)
  fileManager_Model = handle
  if fileManager_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if fileManager_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("FileManager_OnUserLevelAdminActive", true)
    Script.notifyEvent("FileManager_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("FileManager_OnUserLevelServiceActive", true)
    Script.notifyEvent("FileManager_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrFileManager()

  updateUserLevel()

  -- Script.notifyEvent("FileManager_OnNewEvent", false)

  Script.notifyEvent("FileManager_OnNewStatusLoadParameterOnReboot", fileManager_Model.parameterLoadOnReboot)
  Script.notifyEvent("FileManager_OnPersistentDataModuleAvailable", fileManager_Model.persistentModuleAvailable)
  Script.notifyEvent("FileManager_OnNewParameterName", fileManager_Model.parametersName)
  -- ...
end
Timer.register(tmrFileManager, "OnExpired", handleOnExpiredTmrFileManager)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrFileManager:start()
  return ''
end
Script.serveFunction("CSK_FileManager.pageCalled", pageCalled)

--[[
local function setSomething(value)
  _G.logger:info(nameOfModule .. ": Set new value = " .. value)
  fileManager_Model.varA = value
end
Script.serveFunction("CSK_FileManager.setSomething", setSomething)
]]

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  fileManager_Model.parametersName = name
end
Script.serveFunction("CSK_FileManager.setParameterName", setParameterName)

local function sendParameters()
  if fileManager_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(fileManager_Model.helperFuncs.convertTable2Container(fileManager_Model.parameters), fileManager_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, fileManager_Model.parametersName, fileManager_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send FileManager parameters with name '" .. fileManager_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_FileManager.sendParameters", sendParameters)

local function loadParameters()
  if fileManager_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(fileManager_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      fileManager_Model.parameters = fileManager_Model.helperFuncs.convertContainer2Table(data)
      -- If something needs to be configured/activated with new loaded data, place this here:
      -- ...
      -- ...

      CSK_FileManager.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_FileManager.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  fileManager_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_FileManager.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    fileManager_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      fileManager_Model.parametersName = parameterName
      fileManager_Model.parameterLoadOnReboot = loadOnReboot
    end

    if fileManager_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('FileManager_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setFileManager_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

