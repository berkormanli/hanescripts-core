if GetResourceState('qbx-core') ~= 'started' then return
else
    local QBCore = exports['qb-core']:GetCoreObject()
    
    RegisterNetEvent('QBCore:Client:UpdateObject')
    AddEventHandler('QBCore:Client:UpdateObject', function()
        QBCore = exports['qb-core']:GetCoreObject()
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        PlayerJob = QBCore.Functions.GetPlayerData().job
        if PlayerJob.name == 'goldenpub' then
            HasJob = true
        else
            HasJob = false
        end
    end)

    Framework.GetPlayerJob = function()
        return QBCore.Functions.GetPlayerData().job
    end

    Framework.IsBoss = function()
        return PlayerJob.grade.level == 1
    end

    Framework.Notification = function(text, type, length)
        TriggerEvent("QBCore:Notify", text, type, length)
    end

    Framework.GetItemLabel = function(itemName)
        return QBCore.Shared.Items[itemName].label
    end

    Framework.GetItemDescription = function(itemName)
        return QBCore.Shared.Items[itemName].description
    end

    Framework.GetPlayerCashMoney = function()
        return QBCore.Functions.GetPlayerData().money['cash']
    end

    Framework.CheckIfAllIngredients = function(ingredients, input)
        input = tonumber(input)
        local PlayerData = QBCore.Functions.GetPlayerData()
        local checkedIngredients = {}
        for _, ingredient in pairs(ingredients) do
            checkedIngredients[_] = false
        end
        for _, item in pairs(PlayerData.items) do
            if ingredients[item.name] then
                if item.amount >= ingredients[item.name].amount * input then
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
        local PlayerData = QBCore.Functions.GetPlayerData()
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
            QBCore.Functions.TriggerCallback(callbackName, callback, table.unpack(args))
        else
            QBCore.Functions.TriggerCallback(callbackName, callback)
        end
    end
end