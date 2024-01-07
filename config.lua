Config = {
    Debug = true, -- Debug mode, will print some stuff to console

    UseBlip = true, -- Use blip for garbage Center
    BlipName = 'Garbage Center',
    BlipSettings = { -- Blip settings
        Sprite = 318,
        Display = 4,
        Scale = 0.8,
        Color = 5,
    },

    RouteSettings = { -- Works same as blip settings
        blipName = 'Dumpster',
        blipColor = 5, -- Color of the blip for the dumpster
        blipSprite = 318, -- Sprite of the blip for the dumpster
        blipScale = 0.7, -- Scale of the blip for the dumpster
        routeColor = 5, -- Color of the route to the dumpster
        shortRange = true
    },

    GarbageCenter = vec3(-322.2233, -1545.9214, 31.0199),
    GarbageCenterPedHeading = 289.8542,
    GarbageCenterPed = 'cs_josef',
    GarbageCenterPedText = '~INPUT_PICKUP~ Talk to Boss',

    GarbageCar = 'trash',
    GarbageCarSpawn = vec3(-343.4472, -1531.2616, 27.4266),
    GarbageCarSpawnHeading = 269.7216,

    DumpsterProp = 'prop_dumpster_4a',
    DumpsterReward = {100, 200}, -- Random amount {from, to} this will be reward from one Dumpster
    DumpsterActions = '~INPUT_PICKUP~ Pick up trash', -- Text that will be shown when you are near the dumpster

    TrashProp = 'prop_ld_rub_binbag_01',
    TakingTrashAnimation = {
        animDict = 'random@hitch_lift',
        animation = 'idle_f'
    }
}

DumpsterLocations = {-- Format: {coords, heading}
    {vec3(-354.2574, -1372.6558, 31.1898), 338.1384},
    {vec3(-245.7088, -1331.7692, 31.2810), 176.8257}
}

Instructions = { -- Instructions given by notifications
    BlockedSpawnPoint = 'The spawnpoint is blocked! Canceling the job.',
    StartedJob = 'Enjoy your ~y~route~s~.',
    CancelingJob = 'Canceling your job ~r~now~s~.',
    PayCheck = 'Here is you ~g~paycheck~s~!',
    NextJobOrCancel = 'Go to the next ~y~dumpster~s~ or ~r~cancel~s~ the job in HQ.',
    ThrowTrashIntoTruck = '~INPUT_PICKUP~ to throw trash into the truck'
}

Notify = function(text, type) -- Can edit for custom notifications
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, true)
end

NotifyType = { -- Can edit notification types (these 4 are used)
    warning = 'warning',
    error = 'error',
    success = 'success',
    info = 'inform'
}

