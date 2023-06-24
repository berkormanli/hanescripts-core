if GetResourceState('qb-core') ~= 'started' then return
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

    --- Framework Notification wrapper
    ---@param text string
    ---@param type "'info'" | "'error'" | "'success'"
    ---@param length number
    Framework.Notification = function(text, type, length)
        local ntype = ""
        if type == 'info' then ntype = 'primary'
        elseif type == 'error' then ntype = 'error'
        elseif type == 'success' then ntype = 'success' end
        TriggerEvent("QBCore:Notify", text, ntype, length)
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
        local invName = inventoryName:gsub("-", "_")
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', invName)
        TriggerEvent("inventory:client:SetCurrentStash", invName)
    end

    Framework.openTrayInventory = function()
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'goldenpub_tray')
        TriggerEvent("inventory:client:SetCurrentStash", 'goldenpub_tray')
    end

    Framework.openBarInventory = function()
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'goldenpub_backbar')
        TriggerEvent("inventory:client:SetCurrentStash", 'goldenpub_backbar')
    end

    Framework.TriggerCallback = function(callbackName, callback, args)
        if args then
            QBCore.Functions.TriggerCallback(callbackName, callback, table.unpack(args))
        else
            QBCore.Functions.TriggerCallback(callbackName, callback)
        end
    end
end