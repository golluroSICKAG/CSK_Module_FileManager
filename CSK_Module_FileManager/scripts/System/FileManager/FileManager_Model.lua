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

-- Available source paths for files like '/public', '/ram', 'sdcard/0'
fileManager_Model.availableSources = Engine.getEnumValues('MountedDrives')
table.insert(fileManager_Model.availableSources, '/public')
fileManager_Model.selectedFileSource = '/public' -- File source selected out of list

fileManager_Model.listOfFiles = {} -- List of available files on device
fileManager_Model.selectedFile = '' -- Full path of file selected out of list (exkl. fileSource, see above)
fileManager_Model.selectedFilename = '' -- Reduced filename out of full path

fileManager_Model.path = '/public' -- Target path for e.g. files to upload / create new folder

fileManager_Model.freeBytes = File.getDiskFree(fileManager_Model.selectedFileSource) -- Free bytes on selected file source
fileManager_Model.usedBytes = File.getDiskUsage(fileManager_Model.selectedFileSource) -- Used bytes on selected file source

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Function to get related divider and unit of a value
---@param memoryUsage int Amount of bytes
local function getValueDividerAndUnit(memoryUsage)
  local memoryUsageDividerLog = math.log(memoryUsage,10)
  local memoryUsageDivider = 1
  local memoryUsageUnit = "B"
  if memoryUsageDividerLog < 6 and memoryUsageDividerLog >= 3 then
    memoryUsageUnit = "kB"
    memoryUsageDivider = 1024
  elseif memoryUsageDividerLog < 9 and memoryUsageDividerLog >= 6 then
    memoryUsageUnit = "MB"
    memoryUsageDivider = 1024^2
  elseif memoryUsageDividerLog < 12 and memoryUsageDividerLog >= 9 then
    memoryUsageUnit = "GB"
    memoryUsageDivider = 1024^3
  elseif memoryUsageDividerLog < 15 and memoryUsageDividerLog >= 12 then
    memoryUsageUnit = "TB"
    memoryUsageDivider = 1024^4
  end
  return memoryUsageDivider, memoryUsageUnit
end
fileManager_Model.getValueDividerAndUnit = getValueDividerAndUnit

-- Function to get file system usage infos
local function updateFileSystemUsageInfo()
  fileManager_Model.freeBytes = File.getDiskFree(fileManager_Model.selectedFileSource)
  fileManager_Model.usedBytes = File.getDiskUsage(fileManager_Model.selectedFileSource)

  local memoryDividerFree, memoryUnitFree  = getValueDividerAndUnit(fileManager_Model.freeBytes)
  local memoryDividerUsed, memoryUnitUsed  = getValueDividerAndUnit(fileManager_Model.usedBytes)
  Script.notifyEvent("FileManager_OnNewStatusDiskInfo", "Disk free = " .. string.format("%.2f", (fileManager_Model.freeBytes/memoryDividerFree)) .. memoryUnitFree .. " / Disk usage = " .. string.format("%.2f", (fileManager_Model.freeBytes/memoryDividerFree)) .. memoryUnitUsed)
end
fileManager_Model.updateFileSystemUsageInfo = updateFileSystemUsageInfo

-- Function to update list of files / selected file
local function updateListOfFiles()
  fileManager_Model.listOfFiles = File.listRecursive(fileManager_Model.selectedFileSource)
  if fileManager_Model.listOfFiles then
    if #fileManager_Model.listOfFiles >=1 then
      fileManager_Model.selectedFile = fileManager_Model.listOfFiles[1]
      CSK_FileManager.selectFile(fileManager_Model.selectedFile)
    else
      fileManager_Model.selectedFile = ''
    end
  else
    fileManager_Model.selectedFile = ''
  end
  Script.notifyEvent("FileManager_OnNewStatusFileList", fileManager_Model.helperFuncs.createStringListBySimpleTable(fileManager_Model.listOfFiles))
  Script.notifyEvent("FileManager_OnNewStatusSelectedFile", fileManager_Model.selectedFile)
end
fileManager_Model.updateListOfFiles = updateListOfFiles
updateListOfFiles()

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return fileManager_Model
