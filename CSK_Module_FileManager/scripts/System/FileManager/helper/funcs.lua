--[[
++============================================================================++
||                                                                            ||
||  Inside of this script, you will find helper functions.                    ||
||                                                                            ||
++============================================================================++
]]--
---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--[[ ********************************************************************** ]]--
--[[ ************************ Start of Global Scope *********************** ]]--
--[[ ********************************************************************** ]]--

local funcs = {}
--- Provide access to standard JSON functions.
funcs.json = require( "System/FileManager/helper/Json" )

--[[ ********************************************************************** ]]--
--[[ ************************* End of Global Scope ************************ ]]--
--[[ ********************************************************************** ]]--

--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--
--[[ :::::::::::::::::: Start of Function and Event Scope ::::::::::::::::: ]]--
--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Create a string containing a list with a sequence of numbers.
---@param inSize int Size of the list
---@return string outString List of numbers
local function createStringListBySize(inSize)
  local outString = "["
  if inSize >= 1 then
    outString = outString .. '"' .. tostring(1) .. '"'
  end
  if inSize >= 2 then
    for i = 2, inSize, 1 do
      outString = outString .. ", " .. '"' .. tostring(i) .. '"'
    end
  end
  outString = outString .. "]"

  return outString
end
funcs.createStringListBySize = createStringListBySize

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Convert a table into a 'Container' object.
---@param inContent auto[] Lua table to convert to 'Container'
---@return Container outContainer Created 'Container'
local function convertTable2Container(inContent)
  local outContainer = Container.create()
  for key, value in pairs(inContent) do
    if type(value) == "table" then
      outContainer:add(key, convertTable2Container(value), nil)
    else
      outContainer:add(key, value, nil)
    end
  end

  return outContainer
end
funcs.convertTable2Container = convertTable2Container

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Convert a 'Container' object into a table.
---@param inContainer Container 'Container' to convert to Lua table
---@return auto[] outData Created Lua table
local function convertContainer2Table(inContainer)
  local outData = {}
  local containerList = Container.list(inContainer)
  local containerCheck = false
  if tonumber(containerList[1]) then
    containerCheck = true
  end
  for i = 1, #containerList, 1 do
    local subContainer

    if containerCheck == true then
      subContainer = Container.get(inContainer, tostring(i) .. ".00")
    else
      subContainer = Container.get(inContainer, containerList[i])
    end
    if type(subContainer) == "userdata" then
      if Object.getType(subContainer) == "Container" then

        if containerCheck == true then
          table.insert(outData, convertContainer2Table(subContainer))
        else
          outData[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck == true then
          table.insert(outData, subContainer)
        else
          outData[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck == true then
        table.insert(outData, subContainer)
      else
        outData[containerList[i]] = subContainer
      end
    end
  end

  return outData
end
funcs.convertContainer2Table = convertContainer2Table

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Get a content list out of a table.
---@param inData string[] Table with data entries
---@return string sortedTable Sorted entries as string, internally separated by ','
local function createContentList(inData)
  local sortedTable = {}
  for key, _ in pairs(inData) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)

  return table.concat( sortedTable, "," )
end
funcs.createContentList = createContentList

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Get a content list as a JSON string.
---@param inData string[] Table with data entries
---@return string sortedTable Sorted entries as JSON string
local function createJsonList(inData)
  local sortedTable = {}
  for key, _ in pairs(inData) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)

  return funcs.json.encode(sortedTable)
end
funcs.createJsonList = createJsonList

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Create a string of all elements of a table.
---@param inData string[] Table with data entries
---@return string list List of data entries
local function createStringListBySimpleTable(inData)
  if inData ~= nil then
    local list = "["
    if #inData >= 1 then
      list = list .. '"' .. inData[1] .. '"'
    end
    if #inData >= 2 then
      for i=2, #inData, 1 do
        list = list .. ', ' .. '"' .. inData[i] .. '"'
      end
    end
    list = list .. "]"

    return list
  else

    return ''
  end
end
funcs.createStringListBySimpleTable = createStringListBySimpleTable

return funcs

--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--
--[[ ::::::::::::::::::: End of Function and Event Scope :::::::::::::::::: ]]--
--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--
