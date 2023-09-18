function SeatBeltLoop()
    CreateThread(function()
        while true do
            if vehData.seatbelt or vehData.harness then
                DisableControlAction(2, 75)
            end
            if not vehData.active then
                Vehicle:setSeatbelt(false)
                Vehicle:setHarness(false)
                TriggerEvent("seatbelt:client:ToggleSeatbelt")
                break
            end
            if not vehData.seatbelt and not vehData.harness then break end
            Wait(5)
        end
    end)
end

function ToggleSeatbelt(isHarness)
    if isHarness then
        if vehData.harness and vehData.seatbelt then
            Vehicle:setSeatbelt(false)
            TriggerEvent("seatbelt:client:ToggleSeatbelt")
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "carunbuckle", 0.25)
        elseif not vehData.harness and not vehData.seatbelt then
            Vehicle:setSeatbelt(true)
            SeatBeltLoop()
            TriggerEvent("seatbelt:client:ToggleSeatbelt")
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "carbuckle", 0.25)
        end
        Vehicle:setHarness(not vehData.harness)
    else
        if not vehData.harness then
            if vehData.seatbelt then
                Vehicle:setSeatbelt(false)
                TriggerEvent("seatbelt:client:ToggleSeatbelt")
                TriggerServerEvent("InteractSound_SV:PlayOnSource", "carunbuckle", 0.25)
            else
                Vehicle:setSeatbelt(true)
                SeatBeltLoop()
                TriggerEvent("seatbelt:client:ToggleSeatbelt")
                TriggerServerEvent("InteractSound_SV:PlayOnSource", "carbuckle", 0.25)
            end
        else
            QBCore.Functions.Notify('You have a harness on!', 'error')
        end
    end
end

RegisterNetEvent('seatbelt:client:UseHarness', function(item) -- On Item Use (registered server side)
    if vehData.active and Vehicle:isClassDisabled() then
        if not vehData.harness then
            LocalPlayer.state:set("inv_busy", true, true)
            if Config.Progress == 'ox' then
                if lib.progressCircle({
                    label = 'Attaching Harness',
                    duration = 5000,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = false,
                    },
                }) then 
                    ToggleSeatbelt(true)
                end
            elseif Config.Progress == 'qb' then
                QBCore.Functions.Progressbar("harness_equip", "Attaching Harness", 5000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
                    ToggleSeatbelt(true)
                end)
            elseif Config.Progress == 'none' then
                ToggleSeatbelt(true)
            end
            LocalPlayer.state:set("inv_busy", false, true)
        else
            LocalPlayer.state:set("inv_busy", true, true)
            if Config.Progress == 'ox' then
                if lib.progressCircle({
                    label = 'Removing Harness',
                    duration = 5000,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = false,
                    },
                }) then
                    ToggleSeatbelt(true)
                    TriggerServerEvent('qb-vehiclehandler:server:deductHarnessUse', item) 
                end
            elseif Config.Progress == 'qb' then
                QBCore.Functions.Progressbar("harness_equip", "Removing Harness", 5000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
                    ToggleSeatbelt(true)
                    TriggerServerEvent('qb-vehiclehandler:server:deductHarnessUse', item) 
                end)
            elseif Config.Progress == 'none' then
                ToggleSeatbelt(true)
                TriggerServerEvent('qb-vehiclehandler:server:deductHarnessUse', item) 
            end
            LocalPlayer.state:set("inv_busy", false, true)
        end
    end
end)

RegisterCommand('toggleseatbelt', function()
    if not vehData.active or IsPauseMenuActive() then return end
    if not Vehicle:isClassDisabled() then return end
    ToggleSeatbelt(false)
end, false)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'B')