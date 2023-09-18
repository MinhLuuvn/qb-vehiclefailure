RegisterNetEvent('qb-vehiclehandler:removeItem', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, 1)
end)

RegisterNetEvent('qb-vehiclehandler:server:removewashingkit', function(veh)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem("cleaningkit", 1)
    TriggerClientEvent('qb-vehiclehandler:client:SyncWash', -1, veh)
end)

RegisterNetEvent('qb-vehiclehandler:server:EjectPlayers', function(table, velocity, speed)
    for i=1, #table do
        if table[i] then
            if tonumber(table[i]) ~= 0 then
                TriggerClientEvent("qb-vehiclehandler:client:EjectPlayer", table[i], velocity, speed)
            end
        end
    end
end)

RegisterNetEvent('qb-vehiclehandler:server:deductHarnessUse', function(item)
    local src = source
    if not src then return end

    if Config.Inventory == 'ox' then
        if not item.metadata.uses then
            item.metadata.uses = 19
            item.metadata.description = "Uses: "..item.metadata.uses
            exports.ox_inventory:SetMetadata(src, item.slot, item.metadata)
        elseif item.metadata.uses == 1 then
            exports.ox_inventory:RemoveItem(src, 'harness', 1)
        else
            item.metadata.uses -= 1
            item.metadata.description = "Uses: "..item.metadata.uses
            exports.ox_inventory:SetMetadata(src, item.slot, item.metadata)
        end
    elseif Config.Inventory == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)

        if not Player then return end
        if not Player.PlayerData.items[item.slot].info.uses then
            Player.PlayerData.items[item.slot].info.uses = 19
            Player.Functions.SetInventory(Player.PlayerData.items)
        elseif Player.PlayerData.items[item.slot].info.uses == 1 then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items['harness'], "remove")
            Player.Functions.RemoveItem('harness', 1)
        else
            Player.PlayerData.items[item.slot].info.uses -= 1
            Player.Functions.SetInventory(Player.PlayerData.items)
        end
    end
end)

QBCore.Functions.CreateUseableItem("repairkit", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("qb-vehiclehandler:client:RepairVehicle", src)
    end
end)

QBCore.Functions.CreateUseableItem("cleaningkit", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("qb-vehiclehandler:client:CleanVehicle", src)
    end
end)

QBCore.Functions.CreateUseableItem("advancedrepairkit", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("qb-vehiclehandler:client:RepairVehicleFull", src)
    end
end)

QBCore.Commands.Add("fix", "Repair your vehicle (Admin Only)", {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-vehiclehandler:client:adminRepair', src)
end, "admin")
