Config = {}

-- Vị trí trạm điện gió
Config.TurbineLocation = vector4(2319.23, 1608.74, 57.94, 357.2)

-- Lương cơ bản ($/phút)
Config.BaseSalary = 100

-- Chu kỳ sinh tiền (ms)
Config.EarningCycle = 60000 -- 60 giây

-- Chu kỳ giảm hệ thống (ms)
Config.DegradeCycle = 120000 -- 2 phút

-- Giảm ngẫu nhiên mỗi chu kỳ
Config.DegradeMin = 1
Config.DegradeMax = 3

-- Giá trị khởi tạo hệ thống
Config.InitialSystemValue = 70

-- Cấu hình minigame cho từng hệ thống
Config.MinigameSettings = {
    stability = {
        title = "Sửa chữa cánh quạt",
        type = "fan", -- Minigame đặc biệt cho stability
        speed = 1.2,
        zoneSize = 0.22,
        rounds = 1
    },
    electric = {
        title = "Sửa chữa hệ thống điện",
        type = "circuit", -- Minigame đặc biệt cho electrical
        speed = 1.3,
        zoneSize = 0.2,
        rounds = 1
    },
    lubrication = {
        title = "Bơm dầu bôi trơn",
        type = "bar",
        speed = 1.1,
        zoneSize = 0.25,
        rounds = 1
    },
    blades = {
        title = "Sửa chữa thân tháp",
        type = "crack", -- Minigame đặc biệt cho blades
        speed = 1.4,
        zoneSize = 0.18,
        rounds = 1
    },
    safety = {
        title = "Kiểm tra an toàn",
        type = "bar",
        speed = 1.0,
        zoneSize = 0.28,
        rounds = 1
    }
}

-- Phần thưởng sửa chữa
Config.RepairRewards = {
    perfect = 20,
    good = 10,
    fail = -5
}
