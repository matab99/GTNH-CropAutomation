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
    if farm == 'working' then
        return crop.name == 'weed' or
            crop.name == 'Grass' or
            crop.gr > config.workingMaxGrowth or
            crop.re > config.workingMaxResistance or
            (crop.name == 'venomilia' and crop.gr > 7)
    elseif farm == 'storage' then
        return crop.name == 'weed' or
            crop.name == 'Grass' or
            crop.gr > config.storageMaxGrowth or
            crop.re > config.storageMaxResistance or
            (crop.name == 'venomilia' and crop.gr > 7)
    end
end


return {
    scan = scan,
    inspect = inspect,
    isWeed = isWeed
}
