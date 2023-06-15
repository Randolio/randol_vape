local QBCore = exports['qb-core']:GetCoreObject() -- Core
local PlayerData = QBCore.Functions.GetPlayerData() or {}
local isVaping = false
local dragsLeft = 0

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    VapeCraft()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

	exports.ox_target:removeZone() -- Needs to return id number
	isVaping = false
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	PlayerData = QBCore.Functions.GetPlayerData()
    VapeCraft()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	PlayerData = {}
    exports.ox_target:removeZone() -- Needs to return id number
    isVaping = false
end)

function VapeCraft()
	exports.ox_target:addSphereZone({
		coords = vector3(-1167.97, -1573.82, 4.26),
		radius = 0.65,
		drawSprite = true,
		options = {
			{
				type = "client",
				icon = "fa-solid fa-screwdriver",
				event = "randol_vape:client:OpenCraft",
				label = "Craft Station",
				distance = 1.5
			},
			{
				icon = "fa-solid fa-basket-shopping",
				label = "Vape Store",
				onSelect = function()
					exports.ox_inventory:openInventory('shop', {type = 'vapeStore'})
				end,
				distance = 1.5
			},
		}
	})
end

RegisterNetEvent('randol_vape:client:OpenCraft', function()
    lib.registerContext({
		id = 'randol_craft_vape',
		title = 'Craft Station',
		options = {
			{
				title = "Craft Vape",
				description = "Requires:  \n2x Iron | 2x Glass | 1x Electronic Kit",
				icon = "fa-solid fa-square-up-right",
				event = "randol_vape:client:craftVape"
			},
			{
				title = "Refill Vape",
				description = "Requires:  \n1x Empty Vape | 1x Vape Juice",
				icon = "fa-solid fa-square-up-right",
				event = "randol_vape:client:refillVape"
			}
		}
    })
end)

RegisterNetEvent("randol_vape:client:useVape", function(ItemData)
	local pos = GetEntityCoords(cache.ped)
	local pedNet = PedToNet(cache.ped)
	local deadBozo = PlayerData.metadata.isdead
	if not deadBozo then
		if not isVaping then
			isVaping = true
			TriggerEvent('animations:client:EmoteCommandStart', {"hitvape"})
			TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10.0, "vaping", 0.3)
			if lib.progressCircle({
				duration = 5000,
				label = "Smoking vape..",
				position = 'bottom',
				useWhileDead = false,
				canCancel = false,
				disable = {
					combat = true,
				}
			}) then
				TriggerEvent('animations:client:EmoteCommandStart', {"hitvape"})
				Wait(250) -- My hacky way of removing the prop that gets stuck if you go into first person and come back out.
				TriggerEvent('animations:client:EmoteCommandStart', {"c"})
				TriggerServerEvent("randol_vape:server:syncSmoke", pedNet, pos)
				TriggerServerEvent('hud:server:RelieveStress', math.random(6, 8))
				dragsLeft = ItemData.metadata.vapeuses
				dragsLeftData = ItemData
				TriggerServerEvent('randol_vape:server:updateVape', dragsLeft)
				isVaping = false
			end
		else
			lib.notify({
				description = 'You already took a hit.',
				type = 'error'
			})
		end
	else
		lib.notify({
			description = 'You\'re dead broski..',
			type = 'error'
		})
	end
end)

RegisterNetEvent("randol_vape:client:syncSmoke", function(netPed, pos)
	local plyPos = GetEntityCoords(cache.ped)
	local pedNet = NetToPed(netPed)
	if #(plyPos - pos) < 150.0 then
		if not HasNamedPtfxAssetLoaded("core") then RequestNamedPtfxAsset("core") while not HasNamedPtfxAssetLoaded("core") do Wait(0) end end
		SetPtfxAssetNextCall("core")
		vapeClouds = StartParticleFxLoopedOnEntityBone("exp_grd_bzgas_smoke", pedNet, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(pedNet, 20279), 0.5, 0.0, 0.0, 0.0)
		SetParticleFxLoopedAlpha(vapeClouds, 1.0) -- Not sure if this actually makes it more visible?
		SetTimeout(5000, function()
			StopParticleFxLooped(vapeClouds, false)
			RemoveParticleFxFromEntity(pedNet)
			RemoveParticleFx("exp_grd_bzgas_smoke", true)
		end)
	end
end)

RegisterNetEvent('randol_vape:client:craftVape', function()
	local materials = exports.ox_inventory:Search('count', {'iron', 'glass', 'electronickit'})
	if materials and materials.iron >= 2 then
		if materials and materials.glass >= 2 then
			if materials and materials.electronickit >= 1 then
				TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
				if lib.progressCircle({
					duration = 5000,
					label = "Crafting a vape..",
					position = 'bottom',
					useWhileDead = false,
					canCancel = false,
					disable = {
						move = true,
						combat = true,
					}
				}) then
					TriggerServerEvent('randol_vape:server:makeVape')
				end
			else
				lib.notify({
					description = 'You need an electronic kit',
					type = 'error'
				})
			end
		else
			lib.notify({
				description = 'You don\'t have enough glass',
				type = 'error'
			})
		end
	else
		lib.notify({
			description = 'You don\'t have enough iron',
			type = 'error'
		})
	end
end)


RegisterNetEvent('randol_vape:client:refillVape', function()
	local gotStuff = exports.ox_inventory:Search('count', {'emptyvape', 'vapejuice'})
	if gotStuff and gotStuff.emptyvape >= 1 then
		if gotStuff and gotStuff.vapejuice >= 1 then
			TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
			if lib.progressCircle({
				duration = 5000,
				label = "Refilling vape..",
				position = 'bottom',
				useWhileDead = false,
				canCancel = false,
				disable = {
					move = true,
					combat = true
				}
			}) then
				TriggerServerEvent('randol_vape:server:fillVape')
			end
		else
			lib.notify({
				description = "You don't have any Vape Juice to refill.",
				type = "error"
			})
		end
	else
		lib.notify({
			description = "You need an empty vape.",
			type = 'error'
		})
	end
end)
