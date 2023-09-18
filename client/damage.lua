local lastVehicle
local pedInSameVehicleLast = false
local fCollisionDamageMult = 0.0
local fDeformationDamageMult = 0.0
local fEngineDamageMult = 0.0
local fBrakeForce = 1.0
local healthEngineLast = 1000.0
local healthEngineCurrent = 1000.0
local healthEngineNew = 1000.0
local healthEngineDelta = 0.0
local healthEngineDeltaScaled = 0.0
local healthBodyLast = 1000.0
local healthBodyCurrent = 1000.0
local healthBodyNew = 1000.0
local healthBodyDelta = 0.0
local healthBodyDeltaScaled = 0.0
local healthPetrolTankLast = 1000.0
local healthPetrolTankCurrent = 1000.0
local healthPetrolTankNew = 1000.0
local healthPetrolTankDelta = 0.0
local healthPetrolTankDeltaScaled = 0.0
local speedBuffer, velBuffer  = {0.0,0.0}, {}

RegisterNetEvent('qb-vehiclehandler:client:adminRepair', function()
    local ped = PlayerPedId()
    if vehData.active or IsPedInAnyPlane(ped) then
        SetVehicleUndriveable(vehData.ref, false)
        SetVehicleBodyHealth(vehData.ref, 1000)
        SetVehicleDeformationFixed(vehData.ref)
        SetVehicleEngineHealth(vehData.ref, 1000)
        SetVehicleFixed(vehData.ref)
        SetVehicleFuelLevel(vehData.ref, 100.0)
        SetVehicleEngineOn(vehData.ref, true, true)
        healthBodyLast = 1000.0
        healthEngineLast = 1000.0
        healthPetrolTankLast = 1000.0
    end
end)

RegisterNetEvent('qb-vehiclehandler:client:EjectPlayer', function(velocity, difference)
    if not vehData.harness then
        if not vehData.seatbelt or vehData.seatbelt and difference >= Config.Triggers.speed.override then
            local ped = PlayerPedId()
            local co = GetEntityCoords(ped)
            local fw = getForwardVec(ped)
            SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z + 0.5, true, true, true)
            Wait(1)
            SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
            SetEntityVelocity(ped, velocity.x, velocity.y, 0.0) 
            local ejectspeed = math.ceil(GetEntitySpeed(ped))
            if(GetEntityHealth(ped) - ejectspeed) > 0 then
                SetEntityHealth(ped, (GetEntityHealth(ped) - ejectspeed) )
            elseif GetEntityHealth(ped) ~= 0 then
                SetEntityHealth(ped, 0)
            end
            Vehicle:setSeatbelt(false) 
        end
    end
end)

local function EjectSeatedPassengers(speedDifference)
    local seatPlayerId = {}
    for i=1, vehData.maxSeats do
        if not IsVehicleSeatFree(vehData.ref, i-2) then 
            local otherPlayerId = GetPedInVehicleSeat(vehData.ref, i-2) 
            local playerHandle = NetworkGetPlayerIndexFromPed(otherPlayerId)
            local playerServerId = GetPlayerServerId(playerHandle)
            table.insert(seatPlayerId, playerServerId)
        end
    end
    if #seatPlayerId > 0 then TriggerServerEvent("qb-vehiclehandler:server:EjectPlayers", seatPlayerId, velBuffer[2], speedDifference) end
end

function activateControlThread()
    CreateThread(function()
        while vehData.active do
            Wait(0)
            if Config.Settings.torqueMultiplierEnabled or Config.Settings.limpMode then
                if pedInSameVehicleLast then
                    local factor = 1.0
                    if Config.Settings.torqueMultiplierEnabled and healthEngineNew < 900 then
                        factor = (healthEngineNew+200.0) / 1100
                    end
                    if Config.Settings.limpMode == true and healthEngineNew < Config.Settings.engineSafeGuard + 5 then
                        factor = Config.Settings.limpModeMultiplier
                    end
                    SetVehicleEngineTorqueMultiplier(vehData.ref, factor)
                end
            end
            if Config.Settings.preventVehicleFlip then
                local roll = GetEntityRoll(vehData.ref)
                if (roll > 75.0 or roll < -75.0) and speedBuffer[1] < 2 or IsEntityInAir(vehData.ref) and Vehicle:isClassDisabled() then
                    DisableControlAction(2, 59, true) -- Disable left/right
                    DisableControlAction(2, 60, true) -- Disable up/down
                end
            end
        end
    end)
end

function activateDamageThread()
    CreateThread(function()
        while vehData.active do
            if Vehicle:isDriver() then
                healthEngineCurrent = GetVehicleEngineHealth(vehData.ref)
                if healthEngineCurrent == 1000 then healthEngineLast = 1000.0 end
                healthEngineNew = healthEngineCurrent
                healthEngineDelta = healthEngineLast - healthEngineCurrent
                healthEngineDeltaScaled = healthEngineDelta * Config.Settings.damageFactorEngine * Config.Settings.classDamageMultiplier[vehData.class]
    
                healthBodyCurrent = GetVehicleBodyHealth(vehData.ref)
                if healthBodyCurrent == 1000 then healthBodyLast = 1000.0 end
                healthBodyNew = healthBodyCurrent
                healthBodyDelta = healthBodyLast - healthBodyCurrent
                healthBodyDeltaScaled = healthBodyDelta * Config.Settings.damageFactorBody * Config.Settings.classDamageMultiplier[vehData.class]
    
                healthPetrolTankCurrent = GetVehiclePetrolTankHealth(vehData.ref)
                if Config.Settings.compatibilityMode and healthPetrolTankCurrent < 1 then
                    healthPetrolTankLast = healthPetrolTankCurrent
                end
                if healthPetrolTankCurrent == 1000 then healthPetrolTankLast = 1000.0 end
                healthPetrolTankNew = healthPetrolTankCurrent
                healthPetrolTankDelta = healthPetrolTankLast-healthPetrolTankCurrent
                healthPetrolTankDeltaScaled = healthPetrolTankDelta * Config.Settings.damageFactorPetrolTank * Config.Settings.classDamageMultiplier[vehData.class]
    
                if healthEngineCurrent > Config.Settings.engineSafeGuard+1 then
                    SetVehicleUndriveable(vehData.ref, false)
                end
    
                if healthEngineCurrent <= Config.Settings.engineSafeGuard+1 and Config.Settings.limpMode == false or healthPetrolTankCurrent <= 0.0 then
                    local vehpos = GetEntityCoords(vehData.ref)
                    StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", vehpos.x, vehpos.y, vehpos.z-0.7, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    SetVehicleUndriveable(vehData.ref, true)
                end

                speedBuffer[2] = speedBuffer[1]
                speedBuffer[1] = GetEntitySpeed(vehData.ref) * 2.23694
                local speedDiff = speedBuffer[2] - speedBuffer[1]
                if speedDiff >= Config.Triggers.speed.activation then
                    local frameChange = healthBodyLast - healthBodyNew
                    if frameChange >= Config.Triggers.frame then
                        local chance = math.random(0,1)
                        BreakOffVehicleWheel(vehData.ref,chance,true,false,true,false)
                        EjectSeatedPassengers(speedDiff)
                        speedBuffer, velBuffer  = {0.0,0.0}, {}
                        -- print('Seatbelt: '..tostring(vehData.seatbelt))
                        -- print('Frame: '..frameChange)
                        -- print('Speed Diff: '..speedDiff)
                    end
                end

                velBuffer[2] = velBuffer[1]
	        	velBuffer[1] = GetEntityVelocity(vehData.ref)
    
                -- If ped spawned a new vehicle while in a vehicle or teleported from one vehicle to another, handle as if we just entered the car
                if vehData.ref ~= lastVehicle then
                    pedInSameVehicleLast = false
                end

                if pedInSameVehicleLast == true then
                    -- Damage happened while in the car = can be multiplied
    
                    -- Only do calculations if any damage is present on the car. Prevents weird behavior when fixing using trainer or other script
                    if healthEngineCurrent ~= 1000.0 or healthBodyCurrent ~= 1000.0 or healthPetrolTankCurrent ~= 1000.0 then
    
                        -- Combine the delta values (Get the largest of the three)
                        local healthEngineCombinedDelta = math.max(healthEngineDeltaScaled, healthBodyDeltaScaled, healthPetrolTankDeltaScaled)
    
                        -- If huge damage, scale back a bit
                        if healthEngineCombinedDelta > (healthEngineCurrent - Config.Settings.engineSafeGuard) then
                            healthEngineCombinedDelta = healthEngineCombinedDelta * 0.7
                        end
    
                        -- If complete damage, but not catastrophic (ie. explosion territory) pull back a bit, to give a couple of seconds og engine runtime before dying
                        if healthEngineCombinedDelta > healthEngineCurrent then
                            healthEngineCombinedDelta = healthEngineCurrent - (Config.Settings.cascadingFailureThreshold / 5)
                        end
    
    
                        ------- Calculate new value
    
                        healthEngineNew = healthEngineLast - healthEngineCombinedDelta
    
    
                        ------- Sanity Check on new values and further manipulations
    
                        -- If somewhat damaged, slowly degrade until slightly before cascading failure sets in, then stop
    
                        if healthEngineNew > (Config.Settings.cascadingFailureThreshold + 5) and healthEngineNew < Config.Settings.degradingFailureThreshold then
                            healthEngineNew = healthEngineNew-(0.038 * Config.Settings.degradingHealthSpeedFactor)
                        end
    
                        -- If Damage is near catastrophic, cascade the failure
                        if healthEngineNew < Config.Settings.cascadingFailureThreshold then
                            healthEngineNew = healthEngineNew-(0.1 * Config.Settings.cascadingFailureSpeedFactor)
                        end
    
                        -- Prevent Engine going to or below zero. Ensures you can reenter a damaged car.
                        if healthEngineNew < Config.Settings.engineSafeGuard then
                            healthEngineNew = Config.Settings.engineSafeGuard
                        end
    
                        -- Prevent Explosions
                        if Config.Settings.compatibilityMode == false and healthPetrolTankCurrent < 750 then
                            healthPetrolTankNew = 750.0
                        end
    
                        -- Prevent negative body damage.
                        if healthBodyNew < 0  then
                            healthBodyNew = 0.0
                        end
                    end
                else
                    -- Just got in the vehicle. Damage can not be multiplied this round
                    -- Set vehicle handling data
                    fDeformationDamageMult = GetVehicleHandlingFloat(vehData.ref, 'CHandlingData', 'fDeformationDamageMult')
                    fBrakeForce = GetVehicleHandlingFloat(vehData.ref, 'CHandlingData', 'fBrakeForce')
                    local newFDeformationDamageMult = fDeformationDamageMult ^ Config.Settings.deformationExponent    -- Pull the handling file value closer to 1
                    if Config.Settings.deformationMultiplier ~= -1 then SetVehicleHandlingFloat(vehData.ref, 'CHandlingData', 'fDeformationDamageMult', newFDeformationDamageMult * Config.Settings.deformationMultiplier) end  -- Multiply by our factor
                    if Config.Settings.weaponsDamageMultiplier ~= -1 then SetVehicleHandlingFloat(vehData.ref, 'CHandlingData', 'fWeaponDamageMult', Config.Settings.weaponsDamageMultiplier/Config.Settings.damageFactorBody) end -- Set weaponsDamageMultiplier and compensate for damageFactorBody
    
                    --Get the CollisionDamageMultiplier
                    fCollisionDamageMult = GetVehicleHandlingFloat(vehData.ref, 'CHandlingData', 'fCollisionDamageMult')
                    --Modify it by pulling all number a towards 1.0
                    local newFCollisionDamageMultiplier = fCollisionDamageMult ^ Config.Settings.collisionDamageExponent    -- Pull the handling file value closer to 1
                    SetVehicleHandlingFloat(vehData.ref, 'CHandlingData', 'fCollisionDamageMult', newFCollisionDamageMultiplier)
    
                    --Get the EngineDamageMultiplier
                    fEngineDamageMult = GetVehicleHandlingFloat(vehData.ref, 'CHandlingData', 'fEngineDamageMult')
                    --Modify it by pulling all number a towards 1.0
                    local newFEngineDamageMult = fEngineDamageMult ^ Config.Settings.engineDamageExponent    -- Pull the handling file value closer to 1
                    SetVehicleHandlingFloat(vehData.ref, 'CHandlingData', 'fEngineDamageMult', newFEngineDamageMult)
    
                    -- If body damage catastrophic, reset somewhat so we can get new damage to multiply
                    if healthBodyCurrent < Config.Settings.cascadingFailureThreshold then
                        healthBodyNew = Config.Settings.cascadingFailureThreshold
                    end
                    pedInSameVehicleLast = true
                end
    
                -- set the actual new values
                if healthEngineNew ~= healthEngineCurrent then
                    SetVehicleEngineHealth(vehData.ref, healthEngineNew)
                    local dmgFactr = (healthEngineCurrent - healthEngineNew)
                    if dmgFactr > 0.8 then
                        -- DamageRandomComponent()
                    end
                end
                if healthBodyNew ~= healthBodyCurrent then
                    SetVehicleBodyHealth(vehData.ref, healthBodyNew)
                    -- DamageRandomComponent()
                end
                if healthPetrolTankNew ~= healthPetrolTankCurrent then
                    SetVehiclePetrolTankHealth(vehData.ref, healthPetrolTankNew)
                end
    
                -- Store current values, so we can calculate delta next time around
                healthEngineLast = healthEngineNew
                healthBodyLast = healthBodyNew
                healthPetrolTankLast = healthPetrolTankNew
                lastVehicle=vehData.ref
            else
                if pedInSameVehicleLast == true then
                    lastvehicle = vehData.ref
                    if Config.Settings.deformationMultiplier ~= -1 then SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fDeformationDamageMult', fDeformationDamageMult) end -- Restore deformation multiplier
                    SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fBrakeForce', fBrakeForce)  -- Restore Brake Force multiplier
                    if Config.Settings.weaponsDamageMultiplier ~= -1 then SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fWeaponDamageMult', Config.Settings.weaponsDamageMultiplier) end    -- Since we are out of the vehicle, we should no longer compensate for bodyDamageFactor
                    SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fCollisionDamageMult', fCollisionDamageMult) -- Restore the original CollisionDamageMultiplier
                    SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fEngineDamageMult', fEngineDamageMult) -- Restore the original EngineDamageMultiplier
                end
                pedInSameVehicleLast = false
            end
            Wait(50)
        end
    end)
end
