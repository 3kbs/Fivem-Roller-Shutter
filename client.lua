local spawned = {}   -- id -> { obj = entity, open = bool }
local useTarget = false

local function loadAssets()
    RequestModel(Config.Model)
    RequestAnimDict(Config.AnimDict)
    local timeout = GetGameTimer() + 10000
    while not (HasModelLoaded(Config.Model) and HasAnimDictLoaded(Config.AnimDict)) do
        if GetGameTimer() > timeout then
            print('^1[roller_shutter] could not load prop_roller_shutter model or clip dictionary^7')
            return false
        end
        Wait(0)
    end
    return true
end

-- Hold a pose, or play the transition when `animate` is true.
local function applyState(entry, open, animate)
    local obj = entry.obj
    entry.open = open
    if animate then
        PlayEntityAnim(obj, open and 'open' or 'close', Config.AnimDict, 4.0, false, true, false, 0.0, 0)
        if not open then SetEntityCollision(obj, true, true) end
        SetTimeout(Config.AnimDuration, function()
            if spawned[entry.id] ~= entry or entry.open ~= open then return end
            PlayEntityAnim(obj, open and 'opened' or 'closed', Config.AnimDict, 1000.0, true, true, false, 0.0, 0)
            if open then SetEntityCollision(obj, false, false) end
        end)
    else
        PlayEntityAnim(obj, open and 'opened' or 'closed', Config.AnimDict, 1000.0, true, true, false, 0.0, 0)
        SetEntityCollision(obj, not open, not open)
    end
end

local function toggle(id)
    TriggerServerEvent('roller_shutter:toggle', id)
end

local function spawnShutter(shutter)
    local c = shutter.coords
    local obj = CreateObjectNoOffset(Config.Model, c.x, c.y, c.z, false, false, false)
    SetEntityHeading(obj, c.w)
    FreezeEntityPosition(obj, true)
    SetEntityLodDist(obj, 200)
    local entry = { id = shutter.id, obj = obj, open = false }
    spawned[shutter.id] = entry
    applyState(entry, GlobalState.rollerShutters and GlobalState.rollerShutters[shutter.id] == true, false)
    if useTarget then
        exports.ox_target:addLocalEntity(obj, {
            {
                name = 'roller_shutter_toggle',
                icon = 'fa-solid fa-store',
                label = 'Open / close shutter',
                distance = Config.InteractDistance,
                onSelect = function() toggle(shutter.id) end,
            },
        })
    end
end

local function despawnShutter(id)
    local entry = spawned[id]
    if not entry then return end
    if useTarget then exports.ox_target:removeLocalEntity(entry.obj) end
    DeleteEntity(entry.obj)
    spawned[id] = nil
end

AddStateBagChangeHandler('rollerShutters', 'global', function(_, _, value)
    if not value then return end
    for id, entry in pairs(spawned) do
        local open = value[id] == true
        if open ~= entry.open then applyState(entry, open, true) end
    end
end)

local function showHelp(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, false, -1)
end

CreateThread(function()
    useTarget = Config.UseOxTarget and GetResourceState('ox_target') == 'started'
    if not loadAssets() then return end
    while true do
        local sleep = 1000
        local pos = GetEntityCoords(PlayerPedId())
        for _, shutter in ipairs(Config.Shutters) do
            local dist = #(pos - shutter.coords.xyz)
            if dist < Config.SpawnDistance and not spawned[shutter.id] then
                spawnShutter(shutter)
            elseif dist > Config.SpawnDistance + 10.0 and spawned[shutter.id] then
                despawnShutter(shutter.id)
            end
            if not useTarget and spawned[shutter.id] and dist < Config.InteractDistance + 1.0 then
                sleep = 0
                local centre = shutter.coords.xyz + vector3(0.0, 0.0, 1.0)
                if #(pos - centre) < Config.InteractDistance + 0.5 then
                    showHelp(('~INPUT_CONTEXT~ %s shutter'):format(spawned[shutter.id].open and 'Close' or 'Open'))
                    if IsControlJustReleased(0, Config.Key) then toggle(shutter.id) end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Prints a config line for the doorway you are standing in (stand outside, facing the shop).
RegisterCommand('shutter_here', function()
    local ped = PlayerPedId()
    local p = GetEntityCoords(ped)
    local ground, z = GetGroundZFor_3dCoord(p.x, p.y, p.z, false)
    local heading = (GetEntityHeading(ped) + 180.0) % 360.0
    local line = ("{ id = 'shop_%d', coords = vector4(%.2f, %.2f, %.2f, %.1f), job = nil, open = false },")
        :format(GetGameTimer() % 100000, p.x, p.y, ground and z or p.z - 1.0, heading)
    print(line)
    TriggerEvent('chat:addMessage', { args = { 'roller_shutter', 'Config line printed to F8 console' } })
end, false)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for id in pairs(spawned) do despawnShutter(id) end
end)
