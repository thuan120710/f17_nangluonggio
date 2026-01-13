QBCore = exports['qb-core']:GetCoreObject()

local isOnDuty = false
local isNearTurbine = false
local currentSystems = {}
local currentEfficiency = 0
local currentEarnings = 0

-- Mở UI chính
local function OpenMainUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showMainUI',
        systems = currentSystems,
        efficiency = currentEfficiency,
        earnings = currentEarnings
    })
end

-- Đóng UI
local function CloseUI()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideUI'
    })
end

-- Mở minigame
local function OpenMinigame(system)
    local settings = Config.MinigameSettings[system]
    if not settings then return end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showMinigame',
        system = system,
        title = settings.title,
        speed = settings.speed,
        zoneSize = settings.zoneSize,
        rounds = settings.rounds
    })
end

-- Mở UI quỹ tiền
local function OpenEarningsUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showEarningsUI',
        earnings = currentEarnings,
        efficiency = currentEfficiency
    })
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('startDuty', function(data, cb)
    TriggerServerEvent('windturbine:startDuty')
    isOnDuty = true
    cb('ok')
end)

RegisterNUICallback('stopDuty', function(data, cb)
    TriggerServerEvent('windturbine:stopDuty')
    isOnDuty = false
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('repair', function(data, cb)
    if data.system then
        OpenMinigame(data.system)
    end
    cb('ok')
end)

RegisterNUICallback('minigameResult', function(data, cb)
    TriggerServerEvent('windturbine:repairSystem', data.system, data.result)
    
    -- Đợi 2.5 giây trước khi đóng và mở lại UI
    Wait(2500)
    CloseUI()
    Wait(300)
    OpenMainUI()
    cb('ok')
end)

RegisterNUICallback('openEarnings', function(data, cb)
    OpenEarningsUI()
    cb('ok')
end)

RegisterNUICallback('withdrawEarnings', function(data, cb)
    TriggerServerEvent('windturbine:withdrawEarnings')
    cb('ok')
end)

RegisterNUICallback('backToMain', function(data, cb)
    OpenMainUI()
    cb('ok')
end)

-- Server Events
RegisterNetEvent('windturbine:updateSystems')
AddEventHandler('windturbine:updateSystems', function(systems)
    currentSystems = systems
    SendNUIMessage({
        action = 'updateSystems',
        systems = systems
    })
end)

RegisterNetEvent('windturbine:updateEfficiency')
AddEventHandler('windturbine:updateEfficiency', function(efficiency)
    currentEfficiency = efficiency
    SendNUIMessage({
        action = 'updateEfficiency',
        efficiency = efficiency
    })
end)

RegisterNetEvent('windturbine:updateEarningsPool')
AddEventHandler('windturbine:updateEarningsPool', function(earnings)
    currentEarnings = earnings
    SendNUIMessage({
        action = 'updateEarnings',
        earnings = earnings
    })
end)

RegisterNetEvent('windturbine:stopTurbine')
AddEventHandler('windturbine:stopTurbine', function()
    isOnDuty = false
    CloseUI()
end)

-- Thread: Kiểm tra khoảng cách
CreateThread(function()
    while true do
        Wait(1000)
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local turbineCoords = Config.TurbineLocation
        local distance = math.sqrt(
            math.pow(playerCoords.x - turbineCoords.x, 2) +
            math.pow(playerCoords.y - turbineCoords.y, 2) +
            math.pow(playerCoords.z - turbineCoords.z, 2)
        )
        
        isNearTurbine = distance < 5.0
    end
end)

-- Thread: Hiển thị marker và text
CreateThread(function()
    while true do
        Wait(0)
        
        if isNearTurbine then
            DrawMarker(1, Config.TurbineLocation.x, Config.TurbineLocation.y, Config.TurbineLocation.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
            
            if not isOnDuty then
                DrawText3D(Config.TurbineLocation.x, Config.TurbineLocation.y, Config.TurbineLocation.z,
                    "[~g~E~w~] Bắt đầu ca làm việc")
                
                if IsControlJustReleased(0, 38) then -- E
                    OpenMainUI()
                end
            else
                DrawText3D(Config.TurbineLocation.x, Config.TurbineLocation.y, Config.TurbineLocation.z,
                    "[~g~E~w~] Mở bảng điều khiển")
                
                if IsControlJustReleased(0, 38) then -- E
                    OpenMainUI()
                end
            end
        end
    end
end)

-- Helper: Draw 3D Text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end
