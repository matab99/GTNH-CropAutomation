local gps = require('gps')
local scanner = require('scanner')
local config = require('config')
local events = require('events')
local storage = {}
local reverseStorage = {}
local farm = {}

-- ======================== WORKING FARM ========================

local function getFarm()
    return farm
end

local function getTarget()
    return farm[1]
end

local function updateFarm(slot, crop)
    farm[slot] = crop
end

-- ======================== STORAGE FARM ========================

local function getStorage()
    return storage
end


local function resetStorage()
    storage = {}
end


local function addToStorage(crop)
    storage[#storage + 1] = crop
    reverseStorage[crop.name] = #storage
end


local function existInStorage(crop)
    if reverseStorage[crop.name] then
        return true
    else
        return false
    end
end


local function nextStorageSlot()
    return #storage + 1
end


return {
    getFarm = getFarm,
    getTarget = getTarget,
    updateFarm = updateFarm,
    getStorage = getStorage,
    resetStorage = resetStorage,
    addToStorage = addToStorage,
    existInStorage = existInStorage,
    nextStorageSlot = nextStorageSlot
}
