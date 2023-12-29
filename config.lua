Config = {
    Debug = false,

    GarbageCenter = vec3(-322.2233, -1545.9214, 31.0199),
    GarbageCenterPedHeading = 289.8542,
    GarbageCenterPed = 'cs_josef',
    GarbageCenterPedText = '~INPUT_PICKUP~ Talk to Boss',

    GarbageCar = 'trash',
    GarbageCarSpawn = vec3(-343.4472, -1531.2616, 27.4266),
    GarbageCarSpawnHeading = 269.7216,

    DumpsterProp = 'prop_dumpster_4a',
    DumpsterReward = {100, 200} -- Random ammount {from, to} this will be reward from one Dumpster
}

DumpsterLocations = {-- Format: {coords, heading}
    {vec3(-245.7088, -1331.7692, 31.2810), 176.8257},
    {vec3(-245.7088, -1331.7692, 31.2810), 176.8257},
    {vec3(-354.2574, -1372.6558, 31.1898), 338.1384},
    {vec3(-245.7088, -1331.7692, 31.2810), 176.8257}
}

Instructions = { -- Instructions given by notifications
    BlockedSpawnpoint = 'The spawnpoint is blocked! Canceling the job.',
    StartedJob = 'Enjoy your ~y~route~s~.',
    CancelingJob = 'Canceling your job ~r~now~s~.',
    PayCheck = 'Here is you ~g~paycheck~s~!'
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

