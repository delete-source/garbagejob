local activeJob = false
local vehicle
local jobsDone = 0
local dumpsterSpawned
local propEntity

local garbageHQPedHash = GetHashKey(Config.GarbageCenterPed)
local trashBagHash = GetHashKey(Config.TrashProp)
local animDict = Config.TakingTrashAnimation.animDict
local animation = Config.TakingTrashAnimation.animation

-- THREADS --

CreateThread(function()
    local ped
    local wait = 1000

    if Config.UseBlip then
        local blip = AddBlipForCoord(Config.GarbageCenter)
        SetBlipSprite(blip, Config.BlipSettings.Sprite)
        SetBlipDisplay(blip, Config.BlipSettings.Display)
        SetBlipScale(blip, Config.BlipSettings.Scale)
        SetBlipColour(blip, Config.BlipSettings.Color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.BlipName)
        EndTextCommandSetBlipName(blip)
    end

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId()) 
        local distance = #(playerCoords - Config.GarbageCenter)
        
        if distance < 2.0 then
            ShowFloatingHelpNotification(Config.GarbageCenterPedText, vec3(Config.GarbageCenter.x, Config.GarbageCenter.y, Config.GarbageCenter.z+0.85))
            if IsControlJustReleased(0, 38) and not activeJob then
                activeJob = true
                if Config.Debug then
                    print('Starting job')
                end
                TriggerEvent('garbagejob:startjob', source)
            elseif IsControlJustReleased(0, 38) and vehicle then
                Notify(Instructions.CancelingJob, NotifyType.error)
                if jobsDone > 0 then
                    Notify(Instructions.PayCheck, NotifyType.success)
                    TriggerServerEvent('garbageJob:paycheck', (math.random(Config.DumpsterReward[1], Config.DumpsterReward[2]) * jobsDone))
                    jobsDone = 0
                end
                DeleteObject(dumpster)
                DeleteVehicle(vehicle)
                TriggerEvent('garbagejob:stoproute')
                dumpsterSpawned = false
                vehicle = nil
                activeJob = false
            end
            wait = 1
        elseif distance < 50.0 then
            if ped == nil then
                ped = CreatePed(1, garbageHQPedHash, Config.GarbageCenter.x, Config.GarbageCenter.y, Config.GarbageCenter.z-1, Config.GarbageCenterPedHeading, false, true)
                if Config.Debug then
                    print('Ped created')
                end
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                SetPedFleeAttributes(ped, 0, false)
                SetPedCombatAttributes(ped, 46, true)
                SetPedCombatAttributes(ped, 5, true)
            end
            wait = 250
        else
            if ped ~= nil then
                DeletePed(ped)
                if Config.Debug then
                    print('Ped deleted')
                end
                ped = nil
            end
            wait = 2000
        end

        Wait(wait)

    end
end)


-- JOB FUNCTION --

RegisterNetEvent('garbagejob:startjob')
AddEventHandler('garbagejob:startjob', function()
    local isClose = (#(GetEntityCoords(PlayerPedId()) - Config.GarbageCenter) < 2.0) and true or false
    if not isClose then
        activeJob = false
        return
    end
    StartJob()
end)

StartJob = function()
    local dumpster
    dumpsterSpawned = false
    local pickedDumpster
    local lastDumpster = 0

    if IsPlaceClear(Config.GarbageCarSpawn, 10) then
        Notify(Instructions.StartedJob, NotifyType.info)
        SpawnTruck()
    else
        Notify(Instructions.BlockedSpawnPoint, NotifyType.error)
        activeJob = false
        return
    end

    local time = 1000
    while activeJob do
        if not dumpsterSpawned then
            pickedDumpster = math.random(1, #DumpsterLocations)

            while lastDumpster == pickedDumpster do -- Not having the same dumpster again
                pickedDumpster = math.random(1, #DumpsterLocations)
            end

            lastDumpster = pickedDumpster

            RequestModel(Config.DumpsterProp)
            while not HasModelLoaded(Config.DumpsterProp) do
                Wait(10)
            end

            dumpster = CreateObject(Config.DumpsterProp, DumpsterLocations[pickedDumpster][1].x, DumpsterLocations[pickedDumpster][1].y, DumpsterLocations[pickedDumpster][1].z-1, true, true, true)
            SetEntityHeading(prop, DumpsterLocations[pickedDumpster][2])
            dumpsterSpawned = true
            if Config.Debug then
                print('Spawned dumpster at: ' .. DumpsterLocations[pickedDumpster][1])
            end
            if Config.Debug then
                print('Started route to dumpster')
            end
            TriggerEvent('garbagejob:startroute', DumpsterLocations[pickedDumpster][1])
            time = 1000
        else
            while dumpsterSpawned do
                playerCoords = GetEntityCoords(PlayerPedId())
                local radius = #(playerCoords - DumpsterLocations[pickedDumpster][1])

                if radius < 50.0 and radius > 2.0 then
                    Wait(1)
                    DrawMarkers(DumpsterLocations[pickedDumpster][1], 0, 1.0)
                elseif radius < 2.0 then
                    Wait(1)
                    ShowFloatingHelpNotification(Config.DumpsterActions, vec3(DumpsterLocations[pickedDumpster][1].x, DumpsterLocations[pickedDumpster][1].y, DumpsterLocations[pickedDumpster][1].z+0.85))
                    if IsControlJustReleased(0, 38) then
                        SetPropAndAnimation()
                        ThrowTrashIntoTruck()
                        while trashInHand do
                            Wait(500)
                        end
                        DeleteObject(dumpster)
                        dumpsterSpawned = false
                        jobsDone = jobsDone + 1
                        Notify(Instructions.NextJobOrCancel, NotifyType.info)
                        TriggerEvent('garbagejob:stoproute')
                        if Config.Debug then
                            print('Picked up dumpster at: ' .. DumpsterLocations[pickedDumpster][1])
                        end
                    end
                else
                    Wait(1000)
                end
            end
        end
        Wait(time)
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

DrawMarkers = function(coords, type, scale)
    DrawMarker(type, coords.x, coords.y, coords.z+3, 0.0, 0.0, 0.0, 0, 0.0, 0.0, scale, scale, scale, 235, 241, 12, 155, false, true, 2, false, false, false, false)
end

RegisterNetEvent('garbagejob:startroute')
AddEventHandler('garbagejob:startroute', function(DumpsterCoords)
    DumpsterBlip = AddBlipForCoord(DumpsterCoords)
    SetBlipColour(DumpsterBlip, Config.RouteSettings.blipColor)
    SetBlipSprite(DumpsterBlip, Config.RouteSettings.blipSprite)
    SetBlipRoute(DumpsterBlip, true)
    SetBlipRouteColour(DumpsterBlip, Config.RouteSettings.routeColor)
    SetBlipScale(DumpsterBlip, Config.RouteSettings.blipScale)
    SetBlipAsShortRange(DumpsterBlip, Config.RouteSettings.shortRange)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.RouteSettings.blipName)
    EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent('garbagejob:stoproute')
AddEventHandler('garbagejob:stoproute', function()
    if DumpsterBlip then
        if Config.Debug then
            print('Removed blip')
        end
        RemoveBlip(DumpsterBlip)
        DumpsterBlip = nil
    end
end)

SetPropAndAnimation = function()
    RequestModel(trashBagHash)
    RequestAnimDict(animDict)

    while not HasModelLoaded(trashBagHash) or not HasAnimDictLoaded(animDict) do
        Wait(100)
        RequestModel(trashBagHash)
        RequestAnimDict(animDict)
    end

    local prop = CreateObject(trashBagHash, GetEntityCoords(PlayerPedId()), true, true, true)
    TaskPlayAnim(PlayerPedId(), animDict, animation, 8.0, -8.0, -1, 51, 0, false, false, false)
    AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, -0.31, -0.01, -97.0, 0.0, 0.0, true, true, false, false, 1, true)
    propEntity = prop
end

ReleasePropAndAnimation = function()
    DeleteEntity(propEntity)
    propEntity = nil
    ClearPedTasksImmediately(PlayerPedId())
end

ThrowTrashIntoTruck = function()
    local TrunkPos = GetEntityCoords(vehicle)
    local TrunkForward = GetEntityForwardVector(vehicle)
    local ScaleFactor = 4.5
    trashInHand = true

    TrunkPos = TrunkPos - (TrunkForward * ScaleFactor)
    TrunkHeight = TrunkPos.z
    TrunkHeight = TrunkPos.z + 0.7

    while trashInHand do
        local radiusFromTruck = #(GetEntityCoords(PlayerPedId())  - vec3(TrunkPos.x, TrunkPos.y, TrunkHeight))
        DrawMarkers(vec3(TrunkPos.x, TrunkPos.y, TrunkHeight), 0, 1.0)
        if radiusFromTruck < 5.0 then
            ShowFloatingHelpNotification(Instructions.ThrowTrashIntoTruck, TrunkPos)
            if IsControlJustReleased(0, 38) then
                trashInHand = false
                ReleasePropAndAnimation()
                if Config.Debug then
                    print('Trash thrown into truck')
                end
            end
        end
        Wait(1)
    end
end
