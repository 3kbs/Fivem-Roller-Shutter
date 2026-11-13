local states = {}
local byId = {}

for _, shutter in ipairs(Config.Shutters) do
    byId[shutter.id] = shutter
    states[shutter.id] = shutter.open == true
end
GlobalState.rollerShutters = states

local function playerJob(src)
    local ok, player = pcall(function() return exports.qbx_core:GetPlayer(src) end)
    if not ok or not player then
        ok, player = pcall(function() return exports['qb-core']:GetCoreObject().Functions.GetPlayer(src) end)
    end
    return ok and player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name or nil
end

local function canToggle(src, shutter)
    if IsPlayerAceAllowed(src, Config.AdminAce) then return true end
    return shutter.job == nil or playerJob(src) == shutter.job
end

RegisterNetEvent('roller_shutter:toggle', function(id)
    local src = source
    local shutter = byId[id]
    if not shutter or not canToggle(src, shutter) then return end

    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)
    if #(pos - shutter.coords.xyz) > Config.InteractDistance + 3.0 then return end

    local now = GetGameTimer()
    if shutter.busyUntil and now < shutter.busyUntil then return end
    shutter.busyUntil = now + Config.AnimDuration

    local next = GlobalState.rollerShutters
    next[id] = not next[id]
    GlobalState.rollerShutters = next
end)

exports('SetOpen', function(id, open)
    if not byId[id] then return false end
    local next = GlobalState.rollerShutters
    next[id] = open == true
    GlobalState.rollerShutters = next
    return true
end)

exports('IsOpen', function(id)
    return GlobalState.rollerShutters[id] == true
end)
