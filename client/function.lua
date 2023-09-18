function getForwardVec(entity)  
    local hr = GetEntityHeading(entity) + 90.0
    if hr < 0.0 then hr = 360.0 + hr end
    hr = hr * 0.0174533
    return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

function fscale(inputValue, originalMin, originalMax, newBegin, newEnd, curve)
    local OriginalRange
    local NewRange
    local zeroRefCurVal
    local normalizedCurVal
    local rangedValue
    local invFlag = 0

    if (curve > 10.0) then curve = 10.0 end
    if (curve < -10.0) then curve = -10.0 end

    curve = (curve * -.1)
    curve = 10.0 ^ curve

    if (inputValue < originalMin) then
        inputValue = originalMin
    end
    if inputValue > originalMax then
        inputValue = originalMax
    end

    OriginalRange = originalMax - originalMin

    if (newEnd > newBegin) then
        NewRange = newEnd - newBegin
    else
        NewRange = newBegin - newEnd
        invFlag = 1
    end

    zeroRefCurVal = inputValue - originalMin
    normalizedCurVal  =  zeroRefCurVal / OriginalRange

    if (originalMin > originalMax ) then
        return 0
    end

    if (invFlag == 0) then
        rangedValue =  ((normalizedCurVal ^ curve) * NewRange) + newBegin
    else
        rangedValue =  newBegin - ((normalizedCurVal ^ curve) * NewRange)
    end

    return rangedValue
end

local function IsBackEngine(vehModel)
    if Config.BackEngine[vehModel] then return true else return false end
end

function CleanVehicle(veh)
    local ped = PlayerPedId()
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_MAID_CLEAN", 0, true)

    if lib.progressCircle({
        label = Lang:t("progress.clean_veh"),
        duration = math.random(10000, 20000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
    }) then
        SetVehicleDirtLevel(veh, 0.1)
        SetVehicleUndriveable(veh, false)
        WashDecalsFromVehicle(veh, 1.0)
        TriggerServerEvent('qb-vehiclehandler:server:removewashingkit', veh)
        ClearAllPedProps(ped)
        ClearPedTasks(ped)
    else 
        ClearAllPedProps(ped)
        ClearPedTasks(ped)
    end
end

function RepairVehicleFull(veh)
    if (IsBackEngine(GetEntityModel(veh))) then
        SetVehicleDoorOpen(veh, 5, false, false)
    else
        SetVehicleDoorOpen(veh, 4, false, false)
    end

    if lib.progressCircle({
        label = Lang:t("progress.repair_veh"),
        duration = math.random(20000, 30000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {
            dict = "mini@repair",
            clip = "fixing_a_player"
        },
    }) then
        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleEngineOn(veh, true, false)
        for i = 0, 5 do
            SetVehicleTyreFixed(veh, i)
            TriggerEvent('qb-vehiclehandler:client:TyreSync', veh, i)
        end
        if (IsBackEngine(GetEntityModel(veh))) then
            SetVehicleDoorShut(veh, 5, false)
        else
            SetVehicleDoorShut(veh, 4, false)
        end
        TriggerServerEvent('qb-vehiclehandler:removeItem', "advancedrepairkit")
    else 
        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        if (IsBackEngine(GetEntityModel(veh))) then
            SetVehicleDoorShut(veh, 5, false)
        else
            SetVehicleDoorShut(veh, 4, false)
        end
    end
end

function RepairVehicle(veh)
    if (IsBackEngine(GetEntityModel(veh))) then
        SetVehicleDoorOpen(veh, 5, false, false)
    else
        SetVehicleDoorOpen(veh, 4, false, false)
    end

    if lib.progressCircle({
        label = Lang:t("progress.repair_veh"),
        duration = math.random(10000, 20000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {
            dict = "mini@repair",
            clip = "fixing_a_player"
        },
    }) then
        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        SetVehicleEngineHealth(veh, 500.0)
        SetVehicleEngineOn(veh, true, false)
        for i = 0, 5 do
            SetVehicleTyreFixed(veh, i)
            TriggerEvent('qb-vehiclehandler:client:TyreSync', veh, i)
        end
        if (IsBackEngine(GetEntityModel(veh))) then
            SetVehicleDoorShut(veh, 5, false)
        else
            SetVehicleDoorShut(veh, 4, false)
        end
        TriggerServerEvent('qb-vehiclehandler:removeItem', "repairkit")
    else 
        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        if (IsBackEngine(GetEntityModel(veh))) then
            SetVehicleDoorShut(veh, 5, false)
        else
            SetVehicleDoorShut(veh, 4, false)
        end
    end
end