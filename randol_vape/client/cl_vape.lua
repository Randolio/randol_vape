local QBCore = exports['qb-core']:GetCoreObject() -- Core
local isVaping = false
local dragsLeft = 0

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        VapeCraft()
    end
end)

AddEventHandler('onResourceStop', function(resourceName) 
    if GetCurrentResourceName() == resourceName then
	exports['qb-target']:RemoveZone("vapeStuff")
	isVaping = false
    end 
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    VapeCraft()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    exports['qb-target']:RemoveZone("vapeStuff")
    isVaping = false
end)

function VapeCraft()
	exports['qb-target']:AddCircleZone("vapeStuff", vector3(-1167.97, -1573.82, 4.26), 0.65, {
		name="vapeStuff",
		useZ=true,
		}, {
			options = {
				{
					type = "client",
					icon = "fa-solid fa-screwdriver",
					event = "randol_vape:client:OpenCraft",
					label = "Craft Station",
				},
				{
					type = "client",
					icon = "fa-solid fa-basket-shopping",
					event = "randol_vape:client:supplies",
					label = "Vape Store",
				},
			},
		distance = 1.5
	})
end

RegisterNetEvent("randol_vape:client:supplies", function()
	TriggerServerEvent("inventory:server:OpenInventory", "shop", "Vape", Config.Juice)
end)

RegisterNetEvent('randol_vape:client:OpenCraft', function()
    exports['qb-menu']:openMenu({
        {
            id = 0,
            header = "Craft Station",
            icon = "fa-solid fa-toolbox",
            isMenuHeader = true,
        },
        {
            id = 1,
            header = "Craft Vape",
            txt = "Requires:</p>2x Iron | 2x Glass | 1x Electronic Kit",
            icon = "fa-solid fa-square-up-right",
            params = {
                event = "randol_vape:client:craftVape"
            }
        },
		{
            id = 2,
            header = "Refill Vape",
            txt = "Requires:</p>1x Empty Vape | 1x Vape Juice",
            icon = "fa-solid fa-square-up-right",
            params = {
                event = "randol_vape:client:refillVape"
            }
        },
        {
            id = 3,
            header = "Close Menu",
            txt = "",
            icon = "fa-solid fa-angle-left",
            params = {
                event = "qb-menu:closeMenu"
            }
        },
    })
end)

RegisterNetEvent("randol_vape:client:useVape", function(ItemData)
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	local pedNet = PedToNet(ped)
	local deadBozo = QBCore.Functions.GetPlayerData().metadata["isdead"]
	if not deadBozo then 
		if not isVaping then
			isVaping = true
			TriggerEvent('animations:client:EmoteCommandStart', {"hitvape"})
			TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10.0, "vaping", 0.3)
			QBCore.Functions.Progressbar("isVaping_lol", "Smoking vape..", 5000, false, false, {
				disableMovement = false,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			}, {}, {}, {}, function() -- Done
				TriggerEvent('animations:client:EmoteCommandStart', {"hitvape"})
				Wait(250) -- My hacky way of removing the prop that gets stuck if you go into first person and come back out.
				TriggerEvent('animations:client:EmoteCommandStart', {"c"})
				TriggerServerEvent("randol_vape:server:syncSmoke", pedNet, pos)
				TriggerServerEvent('hud:server:RelieveStress', math.random(6, 8))
				dragsLeft = ItemData.info.uses
				dragsLeftData = ItemData
				dragsLeft = dragsLeft - 5 -- -5% juice
				TriggerServerEvent('randol_vape:server:updateVape', dragsLeft, dragsLeftData)
				isVaping = false
			end)
		else
			QBCore.Functions.Notify("You already took a hit.", "error")
		end
	else
		QBCore.Functions.Notify("You're dead broski..", "error")
	end
end)

RegisterNetEvent("randol_vape:client:syncSmoke", function(netPed, pos)
	local ped = PlayerPedId()
	local plyPos = GetEntityCoords(ped)
	local pedNet = NetToPed(netPed)
	if #(plyPos - pos) < 150.0 then
		if not HasNamedPtfxAssetLoaded("core") then RequestNamedPtfxAsset("core") while not HasNamedPtfxAssetLoaded("core") do Wait(0) end end
		SetPtfxAssetNextCall("core")
		vapeClouds = StartParticleFxLoopedOnEntityBone("exp_grd_bzgas_smoke", pedNet, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(pedNet, 20279), 0.5, 0.0, 0.0, 0.0)
		SetParticleFxLoopedAlpha(vapeClouds, 1.0) -- Not sure if this actually makes it more visible?
		SetTimeout(5000, function()
			StopParticleFxLooped(vapeClouds, 0)
			RemoveParticleFxFromEntity(pedNet)
			RemoveParticleFx("exp_grd_bzgas_smoke", true)
		end)
	end
end)

RegisterNetEvent('randol_vape:client:craftVape', function()
    local iron = QBCore.Functions.HasItem("iron", 2)
    local glass = QBCore.Functions.HasItem("glass", 2)
    local elec = QBCore.Functions.HasItem("electronickit", 1)
	if iron then
		if glass then
			if elec then 
				TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
				QBCore.Functions.Progressbar("vape_craft", "Crafting a vape..", 5000, false, false, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = true,
				}, {}, {}, {}, function() -- Done
					TriggerServerEvent('randol_vape:server:makeVape')
				end)
			else
				QBCore.Functions.Notify("You need an electronic kit.", "error")
			end
		else
			QBCore.Functions.Notify("You dont have enough glass.", "error")
		end
	else
		QBCore.Functions.Notify("You dont have enough iron.", "error")
	end
end)


RegisterNetEvent('randol_vape:client:refillVape', function()
	local gotVape = QBCore.Functions.HasItem("emptyvape")
	local gotJuice = QBCore.Functions.HasItem("vapejuice")
	if gotVape then
		if gotJuice then
			TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
			QBCore.Functions.Progressbar("vape_craft", "Refilling vape..", 5000, false, false, {
				disableMovement = true,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			}, {}, {}, {}, function() -- Done
				TriggerServerEvent('randol_vape:server:fillVape')
			end)
		else
			QBCore.Functions.Notify("You don't have any Vape Juice to refill.", "error")
		end
	else
		QBCore.Functions.Notify("You need an empty vape.", "error")
	end
end)
