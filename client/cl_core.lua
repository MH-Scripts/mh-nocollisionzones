Framework, TriggerCallback, OnPlayerLoaded, OnPlayerUnload = nil, nil, nil, nil
OnJobUpdate, isLoggedIn, PlayerData = nil, false, {}
if GetResourceState("es_extended") ~= 'missing' then
    Framework = exports['es_extended']:getSharedObject()
    TriggerCallback = Framework.TriggerServerCallback
    OnPlayerLoaded = 'esx:playerLoaded'
    OnPlayerUnload = 'esx:playerUnLoaded'
    OnJobUpdate = 'esx:setJob'
    function GetPlayerData() TriggerCallback('esx:getPlayerData', function(data) PlayerData = data end) return PlayerData end
    function IsDead() return (GetEntityHealth(PlayerPedId()) <= 0) end
    function SetJob(job) PlayerData.job = job end
elseif GetResourceState("qb-core") ~= 'missing' then
    Framework = exports['qb-core']:GetCoreObject()
    TriggerCallback = Framework.Functions.TriggerCallback
    OnPlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
    OnPlayerUnload = 'QBCore:Client:OnPlayerUnload'
    OnJobUpdate = 'QBCore:Client:OnJobUpdate'
    function GetPlayerData() return Framework.Functions.GetPlayerData() end
    function IsDead() return Framework.Functions.GetPlayerData().metadata['isdead'] end
    function SetJob(job) PlayerData.job = job end
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(data) PlayerData = data end)
end