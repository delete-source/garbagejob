RegisterNetEvent('garbageJob:paycheck')
AddEventHandler('garbageJob:paycheck', function(amount)
    if #(GetEntityCoords(GetPlayerPed(source)) - Config.GarbageCenter) > 5 then
        print('Player with ID: ' .. source .. ' is probably cheating')
        return
    else
        exports.ox_inventory:AddItem(source, 'money', amount)
    end
end)