if GetResourceState('es_extended') ~= 'started' then return
else
    --- Getting Framework object. You can call it what ever you want.
    local ESX = exports['es_extended']:getSharedObject()

    RegisterServerEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(source, currJob, lastJob)
        TriggerClientEvent('hane-goldenpubjob:client:updatePlayerJob', source, currJob)
    end)

    --- Framework dependant function, Get all players that has this job and return them.
    ---@return table
    ---@return integer
    Framework.GetAllPlayersHasJob = function()
        local xPlayers = ESX.GetExtendedPlayers('job', 'goldenpub')
        local workerTable = {}
        local workerCount = 0
        for _, xPlayer in pairs(xPlayers) do
            workerCount = workerCount + 1
            workerTable[src] = {
                firstname = xPlayer.get('firstname'),
                lastname = player.get('lastname'),
            }
        end
        return workerTable, workerCount
    end

    Framework.RemoveItem = function(source, itemName, amount)
        exports.ox_inventory:RemoveItem(source, itemName, amount)
    end

    Framework.GiveItem = function(source, itemName, amount)
        exports.ox_inventory:AddItem(source, itemName, amount)
    end

    Framework.GetBusinessMoney = function()
        -- You need to implement as your liking
        -- This below is one of the QB implementation
        -- local businessMoney = exports['qb-management']:GetAccount('goldenpub')
    end

    Framework.AddBusinessMoney = function(amount)
        -- You need to implement as your liking
        -- This below is one of the QB implementation
        -- exports['qb-management']:AddMoney('goldenpub', amount)
    end

    Framework.RemoveBusinessMoney = function(amount)
        -- You need to implement as your liking
        -- This below is one of the QB implementation
        -- local result = exports['qb-management']:RemoveMoney('goldenpub', amount)
        --return result
    end

    Framework.CreateStash = function(stashName, label, slot, weight)
        exports.ox_inventory:RegisterStash(stashName, label, slot, weight, false)
    end

    Framework.RemovePlayerMoney = function(source, amount)
        local Player = ESX.GetPlayerFromId(source)
        local result = Player.removeMoney(amount, 'goldenpub')
        return result
    end

    Framework.AddPlayerMoney = function(source, amount)
        local Player = ESX.GetPlayerFromId(source)
        Player.addMoney(amount)
    end

    Framework.CreateCallback = function(callbackName, callback)
        ESX.RegisterServerCallback(callbackName, callback)
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
        return player.getName()
    end

    Framework.GetPlayers = function()
        return ESX.GetExtendedPlayers()
    end

    Framework.GetPlayer = function(source)
        return ESX.GetPlayerFromId(source)
    end

    Framework.HireEmployee = function(targetSource)
        local Target = ESX.GetPlayerFromId(targetSource)

        if Target then
            Target.setJob('goldenpub', 0)
            TriggerClientEvent('hane-goldenpubjob:client:notif', targetSource, Lang:t('frameworksv.hired'), 'info', 5000)
        end
    end

    Framework.FireEmployee = function(targetSource)
        local Target = ESX.GetPlayerFromId(targetSource)

        if Target then
            Target.setJob('unemployed', 0)
            TriggerClientEvent('hane-goldenpubjob:client:notif', targetSource, Lang:t('frameworksv.fired'), 'info', 5000)
        end
    end
end