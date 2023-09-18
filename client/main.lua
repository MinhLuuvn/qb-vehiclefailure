vehData = Vehicle:createData()

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        local ped = PlayerPedId()
        if (DoesEntityExist(ped)) then
            local veh = GetVehiclePedIsIn(ped, false)
            if veh and veh > 0 then
                local seat
                local max = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
                for i=1,max do
                    local index = i-2
                    if GetPedInVehicleSeat(veh, index) == ped then
                        seat = index
                    end
                end
                vehData = Vehicle:setData(veh, seat, true)
                if Vehicle:isDriver() then
                    activateControlThread()
                end
                activateDamageThread()
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    vehData = Vehicle:resetData()
end)

RegisterNetEvent('QBCore:Client:VehicleInfo', function(data)
    if data.event == "Entered" then
        vehData = Vehicle:setData(data.vehicle, data.seat, true)
        if Vehicle:isDriver() then
            activateControlThread()
        end
        activateDamageThread()
    else
        vehData = Vehicle:setData(nil, nil, false)
    end
end)

RegisterNetEvent('qb-vehiclehandler:client:TyreSync', function(veh, tyre)
    SetVehicleTyreFixed(veh, tyre)
    SetVehicleWheelHealth(veh, tyre, 100)
end)

RegisterNetEvent('qb-vehiclehandler:client:SyncWash', function(veh)
    SetVehicleDirtLevel(veh, 0.1)
    SetVehicleUndriveable(veh, false)
    WashDecalsFromVehicle(veh, 1.0)
end)

RegisterNetEvent('qb-vehiclehandler:client:CleanVehicle', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh ~= nil and veh ~= 0 then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(veh)
        if #(pos - vehpos) < 3.0 and not IsPedInAnyVehicle(ped) then
            CleanVehicle(veh)
        end
    end
end)

RegisterNetEvent('qb-vehiclehandler:client:RepairVehicle', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    local engineHealth = GetVehicleEngineHealth(veh) --This is to prevent people from "repairing" a vehicle and setting engine health lower than what the vehicles engine health was before repairing.
    if veh ~= nil and veh ~= 0 and engineHealth < 500 then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(veh)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            local drawpos = GetOffsetFromEntityInWorldCoords(veh, 0, 2.5, 0)
            if (IsBackEngine(GetEntityModel(veh))) then
                drawpos = GetOffsetFromEntityInWorldCoords(veh, 0, -2.5, 0)
            end
            if #(pos - drawpos) < 2.0 and not IsPedInAnyVehicle(ped) then
                RepairVehicle(veh)
            end
        else
            if #(pos - vehpos) > 4.9 then
                QBCore.Functions.Notify("You are too far from the vehicle!", "error")
            else
                QBCore.Functions.Notify("You cannot repair a vehicle engine from the inside!", "error")
            end
        end
    else
        if veh == nil or veh == 0 then
            QBCore.Functions.Notify("You are not near a vehicle!", "error")
        else
            QBCore.Functions.Notify("Vehicle is too healthy and needs better tools!", "error")
        end
    end
end)

RegisterNetEvent('qb-vehiclehandler:client:RepairVehicleFull', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh ~= nil and veh ~= 0 then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(veh)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            local drawpos = GetOffsetFromEntityInWorldCoords(veh, 0, 2.5, 0)
            if (IsBackEngine(GetEntityModel(veh))) then
                drawpos = GetOffsetFromEntityInWorldCoords(veh, 0, -2.5, 0)
            end
            if #(pos - drawpos) < 2.0 and not IsPedInAnyVehicle(ped) then
                RepairVehicleFull(veh)
            end
        else
            if #(pos - vehpos) > 4.9 then
                QBCore.Functions.Notify("You are too far from the vehicle!", "error")
            else
                QBCore.Functions.Notify("You cannot repair a vehicle engine from the inside!", "error")
            end
        end
    else
        QBCore.Functions.Notify("You are not near a vehicle!", "error")
    end
end)

exports("HasHarness", function()
    return vehData.harness
end)