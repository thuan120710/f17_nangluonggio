QBCore = exports['qb-core']:GetCoreObject()

local playerData = {}

-- Khởi tạo dữ liệu player
local function InitPlayerData(playerId)
    playerData[playerId] = {
        onDuty = false,
        systems = {
            stability = Config.InitialSystemValue,
            electric = Config.InitialSystemValue,
            lubrication = Config.InitialSystemValue,
            blades = Config.InitialSystemValue,
            safety = Config.InitialSystemValue
        },
        earningsPool = 0,
        lastEarning = 0,
        lastDegrade = 0
    }
end

-- Tính hiệu suất tổng
local function CalculateEfficiency(playerId)
    if not playerData[playerId] then return 0 end
    
    local systems = playerData[playerId].systems
    local total = systems.stability + systems.electric + systems.lubrication + 
                  systems.blades + systems.safety
    
    return total / 5
end

-- Kiểm tra điều kiện sinh tiền
local function CanEarnMoney(playerId)
    if not playerData[playerId] then return false end
    
    local systems = playerData[playerId].systems
    local below30 = 0
    local below50 = 0
    
    for _, value in pairs(systems) do
        if value < 30 then below30 = below30 + 1 end
        if value < 50 then below50 = below50 + 1 end
    end
    
    -- ≥ 3 thanh < 50% → ngừng sinh tiền
    if below50 >= 3 then return false end
    
    return true
end

-- Tính tiền sinh ra
local function CalculateEarnings(playerId)
    if not playerData[playerId] or not playerData[playerId].onDuty then return 0 end
    if not CanEarnMoney(playerId) then return 0 end
    
    local efficiency = CalculateEfficiency(playerId)
    local earnPerMinute = Config.BaseSalary * (efficiency / 100)
    
    -- Giảm tiền nếu có thanh < 30%
    local systems = playerData[playerId].systems
    local below30 = 0
    
    for _, value in pairs(systems) do
        if value < 30 then below30 = below30 + 1 end
    end
    
    if below30 == 1 then
        earnPerMinute = earnPerMinute * 0.7 -- Giảm 30%
    elseif below30 >= 2 then
        earnPerMinute = earnPerMinute * 0.4 -- Giảm 60%
    end
    
    return earnPerMinute
end

-- Giảm hệ thống
local function DegradeSystems(playerId)
    if not playerData[playerId] or not playerData[playerId].onDuty then return end
    
    for system, value in pairs(playerData[playerId].systems) do
        local degrade = math.random(Config.DegradeMin, Config.DegradeMax)
        playerData[playerId].systems[system] = math.max(0, value - degrade)
    end
    
    TriggerClientEvent('windturbine:updateSystems', playerId, playerData[playerId].systems)
    TriggerClientEvent('windturbine:updateEfficiency', playerId, CalculateEfficiency(playerId))
end

-- Event: Bắt đầu ca
RegisterNetEvent('windturbine:startDuty')
AddEventHandler('windturbine:startDuty', function()
    local playerId = source
    
    if not playerData[playerId] then
        InitPlayerData(playerId)
    end
    
    playerData[playerId].onDuty = true
    playerData[playerId].lastEarning = os.time()
    playerData[playerId].lastDegrade = os.time()
    
    TriggerClientEvent('windturbine:updateSystems', playerId, playerData[playerId].systems)
    TriggerClientEvent('windturbine:updateEfficiency', playerId, CalculateEfficiency(playerId))
    TriggerClientEvent('windturbine:updateEarningsPool', playerId, playerData[playerId].earningsPool)
    
    print(('[Wind Turbine] Player %s started duty'):format(playerId))
end)

-- Event: Kết thúc ca
RegisterNetEvent('windturbine:stopDuty')
AddEventHandler('windturbine:stopDuty', function()
    local playerId = source
    
    if playerData[playerId] then
        playerData[playerId].onDuty = false
        TriggerClientEvent('windturbine:stopTurbine', playerId)
    end
    
    print(('[Wind Turbine] Player %s stopped duty'):format(playerId))
end)

-- Event: Sửa chữa hệ thống
RegisterNetEvent('windturbine:repairSystem')
AddEventHandler('windturbine:repairSystem', function(system, result)
    local playerId = source
    
    if not playerData[playerId] or not playerData[playerId].onDuty then return end
    if not playerData[playerId].systems[system] then return end
    
    local reward = 0
    
    if result == 'perfect' then
        reward = Config.RepairRewards.perfect
    elseif result == 'good' then
        reward = Config.RepairRewards.good
    else
        reward = Config.RepairRewards.fail
    end
    
    playerData[playerId].systems[system] = math.min(100, playerData[playerId].systems[system] + reward)
    
    TriggerClientEvent('windturbine:updateSystems', playerId, playerData[playerId].systems)
    TriggerClientEvent('windturbine:updateEfficiency', playerId, CalculateEfficiency(playerId))
    
    print(('[Wind Turbine] Player %s repaired %s: %s (+%d%%)'):format(playerId, system, result, reward))
end)

-- Event: Rút tiền
RegisterNetEvent('windturbine:withdrawEarnings')
AddEventHandler('windturbine:withdrawEarnings', function()
    local playerId = source
    
    if not playerData[playerId] then return end
    
    local amount = math.floor(playerData[playerId].earningsPool)
    
    if amount <= 0 then
        TriggerClientEvent('QBCore:Notify', playerId, 'Không có tiền để rút!', 'error')
        return
    end
    
    -- QBCore: Thêm tiền vào ví
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then
        Player.Functions.AddMoney('cash', amount)
        TriggerClientEvent('QBCore:Notify', playerId, string.format('Đã rút $%d từ quỹ!', amount), 'success')
        
        playerData[playerId].earningsPool = 0
        TriggerClientEvent('windturbine:updateEarningsPool', playerId, 0)
        
        print(('[Wind Turbine] Player %s withdrew $%d'):format(playerId, amount))
    else
        TriggerClientEvent('QBCore:Notify', playerId, 'Lỗi hệ thống!', 'error')
    end
end)

-- Thread: Sinh tiền và giảm hệ thống
CreateThread(function()
    while true do
        Wait(1000)
        
        local currentTime = os.time()
        
        for playerId, data in pairs(playerData) do
            if data.onDuty then
                -- Sinh tiền mỗi chu kỳ
                if currentTime - data.lastEarning >= (Config.EarningCycle / 1000) then
                    local earnings = CalculateEarnings(playerId)
                    data.earningsPool = data.earningsPool + earnings
                    data.lastEarning = currentTime
                    
                    TriggerClientEvent('windturbine:updateEarningsPool', playerId, data.earningsPool)
                end
                
                -- Giảm hệ thống mỗi chu kỳ
                if currentTime - data.lastDegrade >= (Config.DegradeCycle / 1000) then
                    DegradeSystems(playerId)
                    data.lastDegrade = currentTime
                end
            end
        end
    end
end)

-- Cleanup khi player disconnect
AddEventHandler('playerDropped', function()
    local playerId = source
    if playerData[playerId] then
        playerData[playerId] = nil
    end
end)
