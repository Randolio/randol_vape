AddEventHandler('onServerResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:RegisterShop('vapeStore', {
            name = Config.Juice.label,
            inventory = Config.Juice.items
        })
    end
end)

RegisterNetEvent("randol_vape:server:syncSmoke", function(pedNet, pos)
	for _, v in pairs(QBCore.Functions.GetPlayers()) do
		TriggerClientEvent("randol_vape:client:syncSmoke", v, pedNet, pos)
    end
end)

QBCore.Functions.CreateUseableItem("vape", function(source, item)
    local src = source
    TriggerClientEvent('randol_vape:client:useVape', src, item, false)
end)


QBCore.Functions.CreateUseableItem("emptyvape", function(source, item)
    local src = source
    TriggerClientEvent('ox_lib:notify', src, {description = "This vape seems to be all out of juice.", type = 'error'})
end)

RegisterNetEvent('randol_vape:server:updateVape', function(item)
    local src = source

    if item.metadata.vapeuses == 0 then
        exports.ox_inventory:RemoveItem(src, 'vape', 1)
        exports.ox_inventory:AddItem(src, 'emptyvape', 1)
        TriggerClientEvent('ox_lib:notify', src, {description = "Your vape is now out of juice.", type = 'error'})
    else
        item.metadata.vapeuses -= 5
        exports.ox_inventory:SetMetadata(src, item.slot, item.metadata)
    end
end)

RegisterNetEvent('randol_vape:server:makeVape', function()
    local src = source

    local metadata = { vapeuses = 100 }
    exports.ox_inventory:RemoveItem(src, 'electronickit', 1)
    exports.ox_inventory:RemoveItem(src, 'iron', 2)
    exports.ox_inventory:RemoveItem(src, 'glass', 2)
    exports.ox_inventory:AddItem(src, 'vape', 1, metadata)
end)

RegisterNetEvent('randol_vape:server:fillVape', function()
    local src = source
    local hasItems = exports.ox_inventory:Search(src, 'count', {'emptyvape', 'vapejuice'})
    if hasItems and hasItems.emptyvape >= 1 then
        if hasItems and hasItems.vapejuice >= 1 then
            local metadata = { vapeuses = 100 }
            exports.ox_inventory:RemoveItem('emptyvape', 1)
            exports.ox_inventory:RemoveItem('vapejuice', 1)
            exports.ox_inventory:AddItem(src, 'vape', 1, metadata)
        end
    end
end)