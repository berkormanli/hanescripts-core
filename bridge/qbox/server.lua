if GetResourceState('qbx-core') ~= 'started' then return
else
    --- Getting Framework object. You can call it what ever you want.
    local QBCore = exports['qb-core']:GetCoreObject()
    RegisterNetEvent('QBCore:Server:UpdateObject')
    AddEventHandler('QBCore:Server:UpdateObject', function()
        QBCore = exports['qb-core']:GetCoreObject()
    end)

    RegisterNetEvent('QBCore:Server:OnJobUpdate', function(source, currJob)
        TriggerClientEvent('hane-goldenpubjob:client:updatePlayerJob', source, currJob)
    end)

    --- Framework dependant function, Get all players that has this job and return them.
    ---@return table
    ---@return integer
    Framework.GetAllPlayersHasJob = function()
        local players = Framework.GetPlayers()
        local workerTable = {}
        local workerCount = 0
        for _, src in pairs(players) do
            local player = QBCore.Functions.GetPlayer(src)
            if player.PlayerData.job.name == 'goldenpub' then
                workerCount = workerCount + 1
                workerTable[src] = {
                    firstname = player.PlayerData.charinfo.firstname,
                    lastname = player.PlayerData.charinfo.lastname,
                }
            end
        end
        return workerTable, workerCount
    end

    Framework.RemoveItem = function(source, itemName, amount)
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.RemoveItem(itemName, amount)
    end

    Framework.GiveItem = function(source, itemName, amount)
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddItem(itemName, amount, nil, {})
    end

    Framework.GetBusinessMoney = function()
        return exports['qb-management']:GetAccount('goldenpub')
    end

    Framework.AddBusinessMoney = function(amount)
        exports['qb-management']:AddMoney('goldenpub', amount)
    end

    Framework.RemoveBusinessMoney = function(amount)
        local result = exports['qb-management']:RemoveMoney('goldenpub', amount)
        return result
    end

    Framework.CreateStash = function(stashName, label, slot, weight)
        exports.ox_inventory:RegisterStash(stashName, label, slot, weight, false)
    end

    Framework.RemovePlayerMoney = function(source, amount)
        local Player = QBCore.Functions.GetPlayer(source)
        local result = Player.Functions.RemoveMoney('cash', amount)
        return result
    end

    Framework.AddPlayerMoney = function(source, amount)
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddMoney('cash', amount)
    end

    Framework.CreateCallback = function(callbackName, callback)
        QBCore.Functions.CreateCallback(callbackName, callback)
    end

    Framework.SetTableInventory = function(items, tableNum)
        local tableNumber = tostring(tableNum)
        local isValid = exports.ox_inventory:GetInventory('hane-goldenpub-table-'..tableNumber, false)
        if not isValid then
            exports.ox_inventory:RegisterStash('hane-goldenpub-table-'..tableNumber, 'Table', 20, 20000, false)
        end
        for itemName, amount in pairs(items) do
            local success, response = exports.ox_inventory:AddItem('hane-goldenpub-table-'..tableNumber, itemName, amount)

            if not success then
                return print(response)
            end
        end
    end

    Framework.GetPlayerFullName = function(player)
        return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end

    Framework.GetPlayers = function()
        return QBCore.Functions.GetPlayers()
    end

    Framework.GetPlayer = function(source)
        return QBCore.Functions.GetPlayer(source)
    end

    Framework.HireEmployee = function(targetSource)
        local Target = QBCore.Functions.GetPlayer(targetSource)

        if Target and Target.Functions.SetJob('goldenpub', 0) then
            TriggerClientEvent('hane-goldenpubjob:client:notif', targetSource, 'You are hired as (?)!', 'primary', 5000)
        end
    end

    Framework.FireEmployee = function(targetSource)
        local Target = QBCore.Functions.GetPlayer(targetSource)

        if Target and Target.Functions.SetJob('unemployed', 0) then
            TriggerClientEvent('hane-goldenpubjob:client:notif', targetSource, 'You have been fired!', 'secondary', 5000)
        end
    end
end