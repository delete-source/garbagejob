local insidegarbageHQ = false
local pedSpawned = false
local activeJob = false
local vehicle
local lastDumpster = nil
local jobsDone = 0

local garbageHQPedHash = GetHashKey(Config.GarbageCenterPed)
local garbageTruckHash = GetHashKey(Config.GarbageTruck)
local dumpsterHash = GetHashKey(Config.DumpsterProp)

local garbageHQ = CircleZone:Create(Config.GarbageCenter, 50.0, {
    name = "circle_zone",
    debugPoly = Config.Debug,
})

garbageHQ:onPlayerInOut(function(isPointInside, point)
    insidegarbageHQ = isPointInside
end)

-- THREADS --

CreateThread(function()
    local ped = nil 
    local wait = 1000 

    while true do
        if insidegarbageHQ then
            if ped == nil then
                ped = CreatePed(1, garbageHQPedHash, Config.GarbageCenter.x, Config.GarbageCenter.y, Config.GarbageCenter.z-1, Config.GarbageCenterPedHeading, false, true)
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                SetPedFleeAttributes(ped, 0, false)
                SetPedCombatAttributes(ped, 46, true)
                SetPedCombatAttributes(ped, 5, true)
            end
        else
            if ped ~= nil then
                DeletePed(ped)
                ped = nil
            end
        end
        
        -- This part was in second thread but i put it here to have only one thread
        local playerCoords = GetEntityCoords(PlayerPedId()) 
        local distance = #(playerCoords - Config.GarbageCenter)
        
        if distance < 2.0 then
            ShowFloatingHelpNotification(Config.GarbageCenterPedText, vec3(Config.GarbageCenter.x, Config.GarbageCenter.y, Config.GarbageCenter.z+0.85))
            if IsControlJustReleased(0, 38) and not activeJob then
                activeJob = true
                StartJob()
            elseif IsControlJustReleased(0, 38) and vehicle then
                Notify(Instructions.CancelingJob, NotifyType.error)
                if jobsDone > 0 then
                    Notify(Instructions.PayCheck, NotifyType.success)
                    TriggerServerEvent('garbagejob:paycheck', (math.random(Config.DumpsterReward[1], Config.DumpsterReward[2]) * jobsDone))
                    jobsDone = 0
                end
                DeleteVehicle(vehicle)
                vehicle = nil
                activeJob = false
            end
            wait = 1
        elseif distance < 20.0 then
            wait = 250
        else
            wait = 2000
        end

        Wait(wait)

    end
end)


-- JOB FUNCTION --

StartJob = function()
    local dumpster = nil
    local dumpsterSpawned = false
    local pickedDumpster
    local lastDumpster = 0

    if IsPlaceClear(Config.GarbageCarSpawn, 10) then
        Notify(Instructions.StartedJob, NotifyType.info)
        SpawnTruck()
    else
        Notify(Instructions.BlockedSpawnpoint, NotifyType.error)
        activeJob = false
        return
    end

    while activeJob do
        if not dumpsterSpawned then
            pickedDumpster = math.random(1, #DumpsterLocations)
            lastDumpster = pickedDumpster

            while lastDumpster == pickedDumpster do -- Not having the same dumspter again
                pickedDumpster = math.random(1, #DumpsterLocations)
            end

            RequestModel(Config.DumpsterProp)
            while not HasModelLoaded(Config.DumpsterProp) do
                Wait(10)
                print('A')
            end

            dumpster = CreateObject(Config.DumpsterProp, DumpsterLocations[pickedDumpster][1].x, DumpsterLocations[pickedDumpster][1].y, DumpsterLocations[pickedDumpster][1].z-1, true, true, true)
            SetEntityHeading(prop, DumpsterLocations[pickedDumpster][2])
            dumpsterSpawned = true
            print(DumpsterLocations[pickedDumpster][1])
        end
        Wait(1000)
    end
end

-- FUNCTIONS --

SpawnTruck = function()
    RequestModel(Config.GarbageCar)
    while not HasModelLoaded(Config.GarbageCar) do
        Wait(10)
    end

    vehicle = CreateVehicle(Config.GarbageCar, Config.GarbageCarSpawn, Config.GarbageCarSpawnHeading, true, false)
    if DoesEntityExist(vehicle) then
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    end
end

ShowFloatingHelpNotification = function(msg, coords)
    AddTextEntry('FloatingHelpNotification', msg)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 5, -1, 3, 0)
    BeginTextCommandDisplayHelp('FloatingHelpNotification')
    EndTextCommandDisplayHelp(2, false, false, -1)
end

IsPlaceClear = function(coords, maxDistance)
    local entities = GetGamePool('CVehicle')
    local nearbyEntities = {}

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        coords = GetEntityCoords(PlayerPedId())
    end

    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = k or entity
        end
    end

    return #nearbyEntities == 0
end