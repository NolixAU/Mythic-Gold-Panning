local isPanning = false

local function CreateGoldPanningBlips()
    if not Blips or not GoldPanningConfig or not GoldPanningConfig.Locations or #GoldPanningConfig.Locations == 0 then
        return
    end

    local blipConfig = GoldPanningConfig.Blip or {}
    local label = blipConfig.label or 'Gold Panning'
    local sprite = tonumber(blipConfig.sprite) or 467
    local colour = tonumber(blipConfig.colour or blipConfig.color) or 5
    local scale = tonumber(blipConfig.scale) or 0.8
    local display = tonumber(blipConfig.display) or 2
    local category = blipConfig.category and tonumber(blipConfig.category) or nil
    local flashes = blipConfig.flashes

    for index = 1, #GoldPanningConfig.Locations do
        local location = GoldPanningConfig.Locations[index]
        Blips:Add(string.format('gold_panning_%d', index), label, location, sprite, colour, scale, display, category, flashes)
    end
end

AddEventHandler('GoldPanning:Shared:DependencyUpdate', RetrieveComponents)
function RetrieveComponents()
    Logger = exports['mythic-base']:FetchComponent('Logger')
    Callbacks = exports['mythic-base']:FetchComponent('Callbacks')
    Progress = exports['mythic-base']:FetchComponent('Progress')
    Notification = exports['mythic-base']:FetchComponent('Notification')
    Blips = exports['mythic-base']:FetchComponent('Blips')
end

AddEventHandler('Core:Shared:Ready', function()
    exports['mythic-base']:RequestDependencies('GoldPanning', {
        'Logger',
        'Callbacks',
        'Progress',
        'Notification',
        'Blips',
    }, function(error)
        if #error > 0 then
            return
        end

        RetrieveComponents()
        RegisterCallbacks()
        CreateGoldPanningBlips()
    end)
end)

AddEventHandler('Characters:Client:Spawn', CreateGoldPanningBlips)

local function CanGoldPanHere()
    local ped = LocalPlayer.state.ped
    local coords = GetEntityCoords(ped)

    if not GoldPanningConfig or not GoldPanningConfig.Locations then
        return false
    end

    local maxDistance = GoldPanningConfig.MaxDistance or 6.0
    local nearLocation = false

    for i = 1, #GoldPanningConfig.Locations do
        local location = GoldPanningConfig.Locations[i]
        if #(coords - location) <= maxDistance then
            nearLocation = true
            break
        end
    end

    if not nearLocation then
        return false
    end

    local hit, hitCoord = TestProbeAgainstAllWater(coords.x, coords.y, coords.z + 1.0, coords.x, coords.y, coords.z - 5.0, 19)
    if hit == 1 then
        local foundWater, waterHeight = GetWaterHeightNoWaves(hitCoord.x, hitCoord.y, hitCoord.z)
        if foundWater and coords.z - waterHeight <= 1.5 then
            return true
        end
    end

    return IsEntityInWater(ped)
end

function RegisterCallbacks()
    Callbacks:RegisterClientCallback('GoldPanning:AttemptPan', function(_, cb)
        if isPanning then
            Notification:Error('Already panning')
            return cb(false)
        end

        local hasLocations = GoldPanningConfig and GoldPanningConfig.Locations and #GoldPanningConfig.Locations > 0

        if not hasLocations then
            Logger:Warn('GoldPanning', 'Gold panning locations missing')
            return cb(false)
        end

        local ped = LocalPlayer.state.ped

        if IsPedInAnyVehicle(ped) then
            Notification:Error('Exit your vehicle to pan for gold')
            return cb(false)
        end

        if not CanGoldPanHere() then
            Notification:Error('You need to be in the river to pan for gold')
            return cb(false)
        end

        isPanning = true

        local progressData = GoldPanningConfig.Progress or { duration = 10000, label = 'Panning' }

        Progress:Progress({
            name = 'gold_panning',
            duration = progressData.duration,
            label = progressData.label,
            useWhileDead = false,
            canCancel = true,
            vehicle = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableCombat = true,
            },
            animation = {
                animDict = 'amb@world_human_bum_wash@male@high@idle_a',
                anim = 'idle_a',
                flags = 49,
            },
        }, function(cancelled)
            isPanning = false
            cb(not cancelled)
        end)
    end)
end