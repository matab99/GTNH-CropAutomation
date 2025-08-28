local component = require('component')
local sides = require('sides')
local config = require('config')
local geolyzer = component.geolyzer
local inventory_controller = component.inventory_controller

local function scan()
    local rawResult = geolyzer.analyze(sides.down)

    -- AIR
    if rawResult.name == 'minecraft:air' or rawResult.name == 'GalacticraftCore:tile.brightAir' then
        return { isCrop = true, name = 'air' }
    elseif rawResult.name == 'IC2:blockCrop' then
        -- EMPTY CROP STICK
        if rawResult['crop:name'] == nil then
            return { isCrop = true, name = 'emptyCrop' }

            -- FILLED CROP STICK
        else
            return {
                isCrop = true,
                name = rawResult['crop:name'],
                gr = rawResult['crop:growth'],
                ga = rawResult['crop:gain'],
                re = rawResult['crop:resistance'],
                tier = rawResult['crop:tier'],
                size = rawResult['crop:size'],
                max = rawResult['crop:maxSize']
            }
        end

        -- RANDOM BLOCK
    else
        return { isCrop = false, name = 'block' }
    end
end

local function inspect(slot)
    local item = inventory_controller.getStackInInternalSlot(slot);

    if item == nil then
        return nil
    elseif item.name == 'IC2:itemCropSeed' then
        return {
            isCrop = true,
            size = item['size'],
            label = item['label'],
            name = item['crop']['name'],
            tier = item['crop']['tier'],
            gr = item['crop']['growth'],
            ga = item['crop']['gain'],
            re = item['crop']['resistance'],
        }
    else
        return { isCrop = false, name = 'item' }
    end
end

local function isWeed(crop, farm)
    local maxGrowth = nil
    local maxResistance = nil
    if farm == 'working' then
        maxGrowth = config.workingMaxGrowth
        maxResistance = config.workingMaxResistance
    elseif farm == 'storage' then
        maxGrowth = config.storageMaxGrowth
        maxResistance = config.storageMaxResistance
    end

    local isIC2Weed = crop.name == 'weed' or crop.name == 'Grass'
    local isOverGrowth = crop.gr > maxGrowth
    local isOverResistance = crop.re > maxResistance
    local isVenomilia = crop.name == 'venomilia' and crop.gr > 7
    return isIC2Weed or isOverGrowth or isOverResistance or isVenomilia
end

return {
    scan = scan,
    inspect = inspect,
    isWeed = isWeed
}
