local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("randol_vape:server:syncSmoke", function(pedNet, pos)
	for k, v in pairs(QBCore.Functions.GetPlayers()) do
		TriggerClientEvent("randol_vape:client:syncSmoke", v, pedNet, pos)
    end
end)

RegisterNetEvent('QBCore:Server:UpdateObject', function()
	if source ~= '' then return false end
	QBCore = exports['qb-core']:GetCoreObject()
end)

QBCore.Functions.CreateUseableItem("vape", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('randol_vape:client:useVape', src, item)
end)


QBCore.Functions.CreateUseableItem("emptyvape", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    QBCore.Functions.Notify(src, "This vape seems to be all out of juice.", "error")
end)

RegisterNetEvent('randol_vape:server:updateVape', function(vapesLeft, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if vapesLeft == 0 then
        Player.Functions.RemoveItem('vape', 1, data.slot)
        Player.Functions.AddItem('emptyvape', 1)
        QBCore.Functions.Notify(src, "Your vape is now out of juice.", "error")
    else
        Player.PlayerData.items[data.slot].info.uses = Player.PlayerData.items[data.slot].info.uses - 5
        Player.Functions.SetInventory(Player.PlayerData.items)
    end
end)

RegisterNetEvent('randol_vape:server:makeVape', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local info = {
        uses = 100
    }
    Player.Functions.RemoveItem('electronickit', 1)
    Player.Functions.RemoveItem('iron', 2)
    Player.Functions.RemoveItem('glass', 2)
    Player.Functions.AddItem('vape', 1, true, info)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["vape"], "add")
end)

RegisterNetEvent('randol_vape:server:fillVape', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if QBCore.Functions.HasItem(src, "emptyvape", 1) then
        if QBCore.Functions.HasItem(src, "vapejuice", 1) then
            local info = {
                uses = 100
            }
            Player.Functions.RemoveItem('emptyvape', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["emptyvape"], "remove")
            Player.Functions.RemoveItem('vapejuice', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["vapejuice"], "remove")
            Player.Functions.AddItem('vape', 1, true, info)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["vape"], "add")
        end
    end
end)