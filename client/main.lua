local PlayerData = {}
local disableCollision = false
local blips = {}

local function GetDistance(pos1, pos2)
    if pos1 ~= nil and pos2 ~= nil then
        return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
    end
end

local function DeleteAllBlips()
    for _, blip in pairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
            blip = nil
        end
    end
    blips = {}
end

local function CreateBlipCircle(coords, text, radius, color, sprite)
    local blip = nil
	blip = AddBlipForRadius(coords.x, coords.y, coords.z, radius)
	SetBlipHighDetail(blip, true)
	SetBlipColour(blip, color)
	SetBlipAlpha(blip, 128)
	blip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipHighDetail(blip, true)
	SetBlipSprite(blip, sprite)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)
	blips[#blips + 1] = blip
end

local function CreateZones()
    DeleteAllBlips()
    for _, zone in pairs(Config.Zones) do
        if zone.displayBlip and zone.coords ~= nil then
            CreateBlipCircle(zone.coords, "Save Zone", zone.radius, 2, 197)
        end
    end
end

local function NoCollisionsForPlayersVehicles()
    for _, player in pairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        SetEntityNoCollisionEntity(GetPlayerPed(-1), GetVehiclePedIsIn(ped, false), true)
        SetEntityNoCollisionEntity(GetVehiclePedIsIn(ped, false), GetVehiclePedIsIn(GetPlayerPed(-1), false), true)
    end
end

local function NoCollisionsForNpsVehicles()
    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehicles = GetGamePool('CVehicle')
    for i = 1, #vehicles, 1 do
        SetEntityNoCollisionEntity(playerVehicle, vehicles[i], true)
        SetEntityNoCollisionEntity(vehicles[i], playerVehicle, true)
    end
end

local function NoCollisionsForWalkingNps()
    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local peds = GetGamePool('CPed')
    for i = 1, #peds, 1 do
        SetEntityNoCollisionEntity(playerVehicle, peds[i], true)
        SetEntityNoCollisionEntity(peds[i], playerVehicle, true)
    end
end

local function NoCollisionsForGasStations()
    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local coords = GetEntityCoords(playerVehicle)
    for hash in pairs(Config.PumpModels) do
		local pump = GetClosestObjectOfType(coords.x, coords.y, coords.z, 10.0, hash, false, true, true)
		if pump ~= 0 then
            SetEntityNoCollisionEntity(playerVehicle, pump, true)
            SetEntityNoCollisionEntity(pump, playerVehicle, true)
        end
	end
end

local function DisableControl()
    SetPlayerCanDoDriveBy(PlayerPedId(), false)
    DisableControlAction(2, 37, true)        -- Disable Weaponwheel
    DisablePlayerFiring(PlayerPedId(), true) -- Disable firing 
    DisableControlAction(0, 45, true)        -- Disable reloading
    DisableControlAction(0, 24, true)        -- Disable attacking
    DisableControlAction(0, 263, true)       -- Disable melee attack 1
    DisableControlAction(0, 140, true)       -- Disable light melee attack (r)
    DisableControlAction(0, 142, true)       -- Disable left mouse button (pistol whack etc)
    DisableControlAction(0, 264, true)       -- Disable melee
    DisableControlAction(0, 257, true)       -- Disable melee
    DisableControlAction(0, 141, true)       -- Disable melee
    DisableControlAction(0, 143, true)       -- Disable melee
    DisableControlAction(0, 24, true)        -- Attack
    DisableControlAction(0, 257, true)       -- Attack 2
    DisableControlAction(0, 25, true)        -- Aim
end

local function OnPart()
    PlayerData = {}
    isLoggedIn = false
end

local function OnJoin()
    PlayerData = GetPlayerData()
    isLoggedIn = true
    CreateZones()
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        OnJoin()
    end
end)

AddEventHandler(OnPlayerLoaded, function()
    OnJoin()
end)

RegisterNetEvent(OnPlayerUnload, function()
    OnPart()
end)

RegisterNetEvent(OnJobUpdate)
AddEventHandler(OnJobUpdate, function(job)
    PlayerData.job = job
end)

CreateThread(function()
    while true do
        Wait(1)
        local coords = GetEntityCoords(PlayerPedId())
        local enable = false
        local disableControl = false
        local ignoreJob = false
        for _, zone in pairs(Config.Zones) do
            local distance = GetDistance(zone.coords, coords)
            if distance < zone.radius then
                disableCollision = zone.disableCollision
                disableControl = zone.diableControl
                ignoreJob = zone.jobs[PlayerData.job.name]
                break
            elseif distance > zone.radius then
                disableCollision = false
                disableControl = false
                ignoreJob = false
            end
        end
        if disableCollision then
            NoCollisionsForPlayersVehicles()
            NoCollisionsForWalkingNps()
            NoCollisionsForNpsVehicles()
            NoCollisionsForGasStations()
            if disableControl and not ignoreJob then
                DisableControl()
            end
        end
    end
end)