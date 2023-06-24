if GetResourceState('es_extended') ~= 'started' then return
else
    local ESX = exports['es_extended']:getSharedObject()

    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
        ESX.PlayerData = xPlayer
        if ESX.PlayerData.job.name == 'goldenpub' then
            HasJob = true
        else
            HasJob = false
        end
    end)

    Framework.GetPlayerJob = function()
        return ESX.PlayerData.job
    end

    Framework.IsBoss = function()
        return PlayerJob.grade == 1
    end

    --- Framework Notification wrapper
    ---@param text string
    ---@param type "'info'" | "'error'" | "'success'"
    ---@param length number
    Framework.Notification = function(text, type, length)
        local ntype = ""
        if type == 'info' then ntype = 'inform'
        elseif type == 'error' then ntype = 'error'
        elseif type == 'success' then ntype = 'success' end
        lib.notify({
            title =  text,
            type = type,
            duration = length
        })
    end

    local items = exports.ox_inventory:Items()

    Framework.GetItemLabel = function(itemName)
        return items[itemName].label
    end

    Framework.GetItemDescription = function(itemName)
        return items[itemName].description
    end

    Framework.GetPlayerCashMoney = function()
        return ESX.PlayerData.money
    end

    Framework.CheckIfAllIngredients = function(ingredients, input)
        input = tonumber(input)
        local PlayerData = ESX.PlayerData
        local checkedIngredients = {}
        for _, ingredient in pairs(ingredients) do
            checkedIngredients[_] = false
        end
        for _, item in pairs(PlayerData.items) do
            if ingredients[item.name] then
                if item.count >= ingredients[item.name].amount * input then
                    checkedIngredients[item.name] = true
                end
            end
        end
        for _, has in pairs(checkedIngredients) do
            if not has then
                return false
            end
        end
        return true
    end

    Framework.DeleteItemsFromPlayer = function(ingredients, input)
        local PlayerData = ESX.PlayerData
        for _, item in pairs(PlayerData.items) do
            if ingredients[item.name] then
                TriggerServerEvent('hane-goldenpubjob:server:removeItem', item.name, ingredients[item.name].amount * input)
            end
        end
    end

    Framework.GiveItemToPlayer = function(itemName, value)
        TriggerServerEvent('hane-goldenpubjob:server:giveItem', itemName, value)
    end

    Framework.openTableInventory = function(inventoryName)
        if exports.ox_inventory:openInventory('stash', inventoryName) == false then
            TriggerServerEvent('hane-goldenpub:server:createStash', inventoryName, 'Table', 20, 20000)
        end
    end

    Framework.openTrayInventory = function()
        if exports.ox_inventory:openInventory('stash', 'goldenpub-tray') == false then
            TriggerServerEvent('hane-goldenpub:server:createStash', 'goldenpub-tray', 'Tray', 20, 20000)
        end
    end

    Framework.openBarInventory = function()
        if exports.ox_inventory:openInventory('stash', 'goldenpub-backbar') == false then
            TriggerServerEvent('hane-goldenpub:server:createStash', 'goldenpub-backbar', 'Back Bar', 20, 20000)
        end
    end

    Framework.TriggerCallback = function(callbackName, callback, args)
        if args then
            ESX.TriggerServerCallback(callbackName, callback, table.unpack(args))
        else
            ESX.TriggerServerCallback(callbackName, callback)
        end
    end
end