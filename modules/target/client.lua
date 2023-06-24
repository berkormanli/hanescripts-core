-- Caches
local GetItemLabel = Framework.GetItemLabel
local GetItemDescription = Framework.GetItemDescription

targetLib = {}

----------------------------
-- [[ TARGET FUNCTIONS ]] --
----------------------------

--- Target utility functions ---

local function getIngredients(itemName)
    local shouldCrafted, ingredients = false, nil
    if core.config then
        for _, categoryValue in pairs(core.config) do
            if categoryValue.items[itemName] then
                if categoryValue.items[itemName].ingredients then
                    shouldCrafted = true
                    ingredients = categoryValue.items[itemName].ingredients
                    return shouldCrafted, ingredients
                end
            end
        end
    end
    return shouldCrafted, ingredients
end

--- func desc
---@param items table
---@param animation table
---@param prop table
---@param inputCallback fun(value: string, ingredients: table | nil, animation: table, prop: table)
local function getItemList(items, animation, prop, inputCallback)
    local itemList = {}
    for key, value in pairs(items) do
        local shouldCrafted, ingredients = getIngredients(value)
        if shouldCrafted then
            local metadataTable = {}
            for itemName, value in pairs(ingredients) do
                metadataTable[#metadataTable+1] = {
                    label = GetItemLabel(itemName),
                    value = value.amount,
                }
            end
            itemList[key] = {
                title = GetItemLabel(value),
                description = GetItemDescription(value),
                onSelect = function(args)
                    inputCallback(value, ingredients, animation, prop)
                end,
                metadata = metadataTable,
            }
        else
            itemList[key] = {
                title = GetItemLabel(value),
                description = GetItemDescription(value),
                onSelect = function(args)
                    inputCallback(value, nil, animation, prop)
                end,
            }
        end
    end
    return itemList
end


---@class sharedTargetOption
---@field name string
---@field icon string
---@field label string
---@field canInteract fun()
---@field onSelect fun()

if Config.TargetScript == 'ox_target' then

    --- func desc
    ---@param self any
    ---@param sharedOptions sharedTargetOption[]
    targetLib.createTargetOptions = function(self, sharedOptions)
        local options = {}
        for _, option in ipairs(sharedOptions) do
            options[_] = {
                name = option.name,
                icon = option.icon,
                label = option.label,
                canInteract = option.canInteract,
                onSelect = option.onSelect
            }
        end
        return options
    end


    --- func desc
    ---@param self any
    ---@param sharedOptions sharedTargetOption[]
    ---@param name string
    ---@param title string
    ---@param items any
    ---@param animation any
    ---@param prop any
    ---@param inputCallback any
    targetLib.createTargetOptionsWithContext = function(self, sharedOptions, name, title, items, animation, prop, inputCallback)
        local options = {}
        for _, option in ipairs(sharedOptions) do
            options[_] = {
                name = option.name,
                icon = option.icon,
                label = option.label,
                canInteract = option.canInteract,
                onSelect = function()
                    contextLib.showContext({
                        id = name,
                        title = title,
                        options = getItemList(items, animation, prop, inputCallback)
                    })
                end
            }
        end
        return options
    end

    ---@class oxTargetOptions
    ---@field name string
    ---@field icon string
    ---@field label string
    ---@field canInteract fun()
    ---@field onSelect fun()

    --- func desc
    ---@param self any
    ---@param entity number
    ---@param targetOptions oxTargetOptions
    targetLib.createEntityTargets = function(self, entity, targetOptions)
        exports.ox_target:addLocalEntity(entity, targetOptions)
    end

    --- func desc
    ---@param self any
    ---@param sharedZoneOption sharedZoneOptions
    ---@param targetOptions oxTargetOptions
    targetLib.createBoxTargets = function(self, sharedZoneOption, targetOptions)
        local id = exports.ox_target:addBoxZone({
            coords = sharedZoneOption.coords,
            size = sharedZoneOption.size,
            rotation = sharedZoneOption.rotation,
            debug = sharedZoneOption.debug,
            options = targetOptions,
        })

        return id
    end

    ---@class targetOptionName
    ---@field name string
    ---@field label string

    --- func desc
    ---@param self any
    ---@param entity number | table
    ---@param targetOptionNames targetOptionName[]
    targetLib.removeEntityTargets = function(self, entity, targetOptionNames)
        local optionNames = {}
        for index, value in ipairs(targetOptionNames) do
            optionNames[index] = value.name
        end
        exports.ox_target:removeLocalEntity(entity, optionNames)
    end
else
    --- func desc
    ---@param self any
    ---@param sharedOptions sharedTargetOption[]
    targetLib.createTargetOptions = function(self, sharedOptions)
        local options = {}
        for _, option in ipairs(sharedOptions) do
            options[_] = {
                num = _,
                icon = option.icon,
                label = option.label,
                canInteract = option.canInteract,
                action = option.onSelect
            }
        end
        return options
    end

    --- func desc
    ---@param self any
    ---@param sharedOptions sharedTargetOption[]
    ---@param name string
    ---@param title string
    ---@param items any
    ---@param animation any
    ---@param prop any
    ---@param inputCallback any
    targetLib.createTargetOptionsWithContext = function(self, sharedOptions, name, title, items, animation, prop, inputCallback)
        local options = {}
        for _, option in ipairs(sharedOptions) do
            options[_] = {
                num = _,
                icon = option.icon,
                label = option.label,
                canInteract = option.canInteract,
                action = function()
                    contextLib.showContext({
                        id = name,
                        title = title,
                        options = getItemList(items, animation, prop)
                    })
                end
            }
        end
        return options
    end

    ---@class qbTargetOptions
    ---@field num number
    ---@field icon string
    ---@field label string
    ---@field canInteract fun()
    ---@field action fun()

    --- func desc
    ---@param self any
    ---@param entity number
    ---@param targetOptions qbTargetOptions
    targetLib.createEntityTargets = function(self, entity, targetOptions)
        exports['qb-target']:AddTargetEntity(entity, {
            options = targetOptions,
            distance = 2.5
        })
    end

    --- func desc
    ---@param self any
    ---@param sharedZoneOption sharedZoneOptions
    ---@param targetOptions qbTargetOptions
    targetLib.createBoxTargets = function(self, sharedZoneOption, targetOptions)
        exports['qb-target']:AddBoxZone(sharedZoneOption.name, sharedZoneOption.coords, sharedZoneOption.size.y, sharedZoneOption.size.x, {
            name = sharedZoneOption.name,
            heading = sharedZoneOption.rotation,
            debugPoly = sharedZoneOption.debug,
        }, {
            options = targetOptions,
            distance = 2.5
        })
        return sharedZoneOption.name
    end

    --- func desc
    ---@param self any
    ---@param entity number | table
    ---@param targetOptionNames targetOptionName[]
    targetLib.removeEntityTargets = function(self, entity, targetOptionNames)
        local optionNames = {}
        for index, value in ipairs(targetOptionNames) do
            optionNames[index] = value.label
        end
        exports['qb-target']:RemoveTargetEntity(entity, optionNames)
    end
end