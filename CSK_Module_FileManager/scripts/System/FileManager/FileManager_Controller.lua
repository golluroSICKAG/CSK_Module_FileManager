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

-- Timer to hide UI callouts after a while
local tmrCalloutVisible = Timer.create()
tmrCalloutVisible:setExpirationTime(5000)
tmrCalloutVisible:setPeriodic(false)

-- ************************ UI Events Start ********************************

Script.serveEvent('CSK_FileManager.OnNewStatusModuleVersion', 'FileManager_OnNewStatusModuleVersion')
Script.serveEvent('CSK_FileManager.OnNewStatusCSKStyle', 'FileManager_OnNewStatusCSKStyle')
Script.serveEvent('CSK_FileManager.OnNewStatusModuleIsActive', 'FileManager_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_FileManager.OnNewStatusShowCallout', 'FileManager_OnNewStatusShowCallout')
Script.serveEvent('CSK_FileManager.OnNewStatusCalloutText', 'FileManager_OnNewStatusCalloutText')
Script.serveEvent('CSK_FileManager.OnNewStatusCalloutType', 'FileManager_OnNewStatusCalloutType')

Script.serveEvent('CSK_FileManager.OnNewStatusDiskInfo', 'FileManager_OnNewStatusDiskInfo')

Script.serveEvent('CSK_FileManager.OnNewStatusAvailableSources', 'FileManager_OnNewStatusAvailableSources')
Script.serveEvent('CSK_FileManager.OnNewStatusSelectedSource', 'FileManager_OnNewStatusSelectedSource')

Script.serveEvent('CSK_FileManager.OnNewStatusFileList', 'FileManager_OnNewStatusFileList')
Script.serveEvent('CSK_FileManager.OnNewStatusSelectedFile', 'FileManager_OnNewStatusSelectedFile')

Script.serveEvent('CSK_FileManager.OnNewStatusFileToDownload', 'FileManager_OnNewStatusFileToDownload')
Script.serveEvent('CSK_FileManager.OnNewStatusDownloadFilename', 'FileManager_OnNewStatusDownloadFilename')

Script.serveEvent('CSK_FileManager.OnNewStatusPath', 'FileManager_OnNewStatusPath')

Script.serveEvent('CSK_FileManager.OnUserLevelOperatorActive', 'FileManager_OnUserLevelOperatorActive')
Script.serveEvent('CSK_FileManager.OnUserLevelMaintenanceActive', 'FileManager_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_FileManager.OnUserLevelServiceActive', 'FileManager_OnUserLevelServiceActive')
Script.serveEvent('CSK_FileManager.OnUserLevelAdminActive', 'FileManager_OnUserLevelAdminActive')

-- Not used so far
Script.serveEvent("CSK_FileManager.OnNewStatusLoadParameterOnReboot", "FileManager_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_FileManager.OnPersistentDataModuleAvailable", "FileManager_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_FileManager.OnNewParameterName", "FileManager_OnNewParameterName")
Script.serveEvent("CSK_FileManager.OnDataLoadedOnReboot", "FileManager_OnDataLoadedOnReboot")

-- ************************ UI Events End **********************************

-- Function to hide UI callouts if Timer expired
local function handleOnExpired()
  Script.notifyEvent("FileManager_OnNewStatusShowCallout", false)
end
Timer.register(tmrCalloutVisible, 'OnExpired', handleOnExpired)

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

  Script.notifyEvent("FileManager_OnNewStatusShowCallout", false)
  Script.notifyEvent("FileManager_OnNewStatusModuleVersion", 'v' .. fileManager_Model.version)
  Script.notifyEvent("FileManager_OnNewStatusCSKStyle", fileManager_Model.styleForUI)
  Script.notifyEvent("FileManager_OnNewStatusModuleIsActive", _G.availableAPIs.default)

  local memoryDividerFree, memoryUnitFree  = fileManager_Model.getValueDividerAndUnit(fileManager_Model.freeBytes)
  local memoryDividerUsed, memoryUnitUsed  = fileManager_Model.getValueDividerAndUnit(fileManager_Model.usedBytes)
  Script.notifyEvent("FileManager_OnNewStatusDiskInfo", "Disk free = " .. string.format("%.2f", (fileManager_Model.freeBytes/memoryDividerFree)) .. memoryUnitFree .. " / Disk usage = " .. string.format("%.2f", (fileManager_Model.usedBytes/memoryDividerUsed)) .. memoryUnitUsed)

  Script.notifyEvent("FileManager_OnNewStatusAvailableSources", fileManager_Model.helperFuncs.createStringListBySimpleTable(fileManager_Model.availableSources))
  Script.notifyEvent("FileManager_OnNewStatusSelectedSource", fileManager_Model.selectedFileSource)
  Script.notifyEvent("FileManager_OnNewStatusFileList", fileManager_Model.helperFuncs.createStringListBySimpleTable(fileManager_Model.listOfFiles))
  Script.notifyEvent("FileManager_OnNewStatusSelectedFile", fileManager_Model.selectedFile)

  Script.notifyEvent("FileManager_OnNewStatusFileToDownload", fileManager_Model.selectedFileSource .. '/' .. fileManager_Model.selectedFile)
  Script.notifyEvent("FileManager_OnNewStatusDownloadFilename", fileManager_Model.selectedFilename)

  Script.notifyEvent("FileManager_OnNewStatusPath", fileManager_Model.path)

  -- Not used so far
  --Script.notifyEvent("FileManager_OnNewStatusLoadParameterOnReboot", fileManager_Model.parameterLoadOnReboot)
  --Script.notifyEvent("FileManager_OnPersistentDataModuleAvailable", fileManager_Model.persistentModuleAvailable)
  --Script.notifyEvent("FileManager_OnNewParameterName", fileManager_Model.parametersName)

end
Timer.register(tmrFileManager, "OnExpired", handleOnExpiredTmrFileManager)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrFileManager:start()
  return ''
end
Script.serveFunction("CSK_FileManager.pageCalled", pageCalled)

local function selectFileSource(source)
  fileManager_Model.selectedFileSource = source
  fileManager_Model.updateListOfFiles()
end
Script.serveFunction('CSK_FileManager.selectFileSource', selectFileSource)

-- Function to search for '/' to get info about subdirectories
---@param name string Name to search for subdirectories
local function checkForSubdirectories(name)
  local foundPos = string.find(name, '/')
  if not foundPos then
    return name
  end
  return checkForSubdirectories(string.sub(name, foundPos+1))
end

local function selectFile(filename)
  fileManager_Model.selectedFile = filename
  local result = fileManager_Model.selectedFile

  fileManager_Model.selectedFilename = checkForSubdirectories(fileManager_Model.selectedFile)

  Script.notifyEvent("FileManager_OnNewStatusFileToDownload", fileManager_Model.selectedFileSource .. '/' .. fileManager_Model.selectedFile)
  Script.notifyEvent("FileManager_OnNewStatusDownloadFilename", fileManager_Model.selectedFilename)
end
Script.serveFunction('CSK_FileManager.selectFile', selectFile)

local function setPath(path)
  fileManager_Model.path = path
  Script.notifyEvent("FileManager_OnNewStatusPath", fileManager_Model.path)
end
Script.serveFunction('CSK_FileManager.setPath', setPath)

local function fileUploadFinished(status)
  _G.logger:info(nameOfModule .. ': File upload: ' .. tostring(status))
  fileManager_Model.updateListOfFiles()

  Script.notifyEvent("FileManager_OnNewStatusShowCallout", true)
  tmrCalloutVisible:start()
  if status then
    Script.notifyEvent("FileManager_OnNewStatusCalloutType", 'success')
    Script.notifyEvent("FileManager_OnNewStatusCalloutText", 'File was uploaded.')
  else
    Script.notifyEvent("FileManager_OnNewStatusCalloutType", 'error')
    Script.notifyEvent("FileManager_OnNewStatusCalloutText", 'File upload failed.')
  end
  fileManager_Model.updateFileSystemUsageInfo()
end
Script.serveFunction('CSK_FileManager.fileUploadFinished', fileUploadFinished)

--- Function to react on status change of Admin user level
---@param pos int Position to start to search for a slash
---@param path string Full file path to search for subfolders
local function createRecursiveFolder(pos, path)
  local foundPos = string.find(path, '/', pos)
  if foundPos then
    local found2ndPos = string.find(path, '/', foundPos+1)
    if found2ndPos and found2ndPos ~= #path then
      local folderToCheck = string.sub(path, 1, found2ndPos)
      local folderExists = File.isdir(folderToCheck)
      if not folderExists then
        local suc = File.mkdir(folderToCheck)
        _G.logger:info(nameOfModule .. ': Creating folder: "' .. folderToCheck .. '" = ' .. tostring(suc))
      end
      return createRecursiveFolder(foundPos+1, path)
    else
      local folderExists = File.isdir(path)
      if folderExists then
        _G.logger:info(nameOfModule .. ': Folder: "' .. path .. '" already exists.')
        Script.notifyEvent("FileManager_OnNewStatusCalloutType", 'success')
        Script.notifyEvent("FileManager_OnNewStatusCalloutText", 'Folder already exists.')
      else
        local suc = File.mkdir(path)
        _G.logger:info(nameOfModule .. ': Creating folder: "' .. path .. '" = ' .. tostring(suc))
        if suc then
          Script.notifyEvent("FileManager_OnNewStatusCalloutType", 'success')
          Script.notifyEvent("FileManager_OnNewStatusCalloutText", 'Folder created.')
        else
          Script.notifyEvent("FileManager_OnNewStatusCalloutType", 'error')
          Script.notifyEvent("FileManager_OnNewStatusCalloutText", 'Folder not created.')
        end
        return
      end
    end
  else
    return
  end
end

local function createFolder()
  if string.sub(fileManager_Model.path, 1, 1) == '/' then
    createRecursiveFolder(1, fileManager_Model.path)
  else
    _G.logger:warning(nameOfModule .. ': Wrong path to create new folder.')
    Script.notifyEvent("FileManager_OnNewStatusCalloutType", 'error')
    Script.notifyEvent("FileManager_OnNewStatusCalloutText", 'Wrong path to create new folder.')
  end
  Script.notifyEvent("FileManager_OnNewStatusShowCallout", true)
  tmrCalloutVisible:start()
  fileManager_Model.updateListOfFiles()
end
Script.serveFunction('CSK_FileManager.createFolder', createFolder)

--- Function to give feedback if deleting of file / folder did work
---@param suc boolean Success of removal
local function checkRemoval(suc)
  _G.logger:info(nameOfModule .. ': File / Folder removed: ' .. tostring(suc))

  Script.notifyEvent("FileManager_OnNewStatusShowCallout", true)
  tmrCalloutVisible:start()
  if suc then
    Script.notifyEvent("FileManager_OnNewStatusCalloutType", 'success')
    Script.notifyEvent("FileManager_OnNewStatusCalloutText", 'File / Folder removed.')
  else
    Script.notifyEvent("FileManager_OnNewStatusCalloutType", 'error')
    Script.notifyEvent("FileManager_OnNewStatusCalloutText", 'Deleting file / folder did not work.')
  end
  fileManager_Model.updateListOfFiles()
end

local function deleteFile()
  local suc = File.del(fileManager_Model.selectedFileSource .. '/' .. fileManager_Model.selectedFile)
  checkRemoval(suc)
end
Script.serveFunction('CSK_FileManager.deleteFile', deleteFile)

local function deleteFolder()
  if fileManager_Model.path ~= '/public' and fileManager_Model.path ~= 'public' then
    local suc = File.del(fileManager_Model.path)
    checkRemoval(suc)
  else
    Script.notifyEvent("FileManager_OnNewStatusShowCallout", true)
    tmrCalloutVisible:start()
    Script.notifyEvent("FileManager_OnNewStatusCalloutType", 'error')
    Script.notifyEvent("FileManager_OnNewStatusCalloutText", 'Deleting file / folder did not work.')
  end
end
Script.serveFunction('CSK_FileManager.deleteFolder', deleteFolder)

local function getStatusModuleActive()
  return _G.availableAPIs.default
end
Script.serveFunction('CSK_FileManager.getStatusModuleActive', getStatusModuleActive)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

-- No need for these features in this module till now ...
--[[
local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name: " .. tostring(name))
  fileManager_Model.parametersName = name
end
Script.serveFunction("CSK_FileManager.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if fileManager_Model.parameters then
    if fileManager_Model.persistentModuleAvailable then
      CSK_PersistentData.addParameter(fileManager_Model.helperFuncs.convertTable2Container(fileManager_Model.parameters), fileManager_Model.parametersName)
      CSK_PersistentData.setModuleParameterName(nameOfModule, fileManager_Model.parametersName, fileManager_Model.parameterLoadOnReboot)
      _G.logger:fine(nameOfModule .. ": Send FileManager parameters with name '" .. fileManager_Model.parametersName .. "' to CSK_PersistentData module.")
      if not noDataSave then
        CSK_PersistentData.saveData()
      end
    else
      _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    end
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
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    return false
  end
end
Script.serveFunction("CSK_FileManager.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  fileManager_Model.parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
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
]]

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setFileManager_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

