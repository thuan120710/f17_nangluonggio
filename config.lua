Config = {}

-- Vị trí trạm điện gió
Config.TurbineLocation = vector4(2319.23, 1608.74, 57.94, 357.2)

-- ============================================
-- HỆ THỐNG LỢI NHUẬN
-- ============================================
-- Lợi nhuận cơ bản: 5,000 IC/giờ = 1,250 IC/15 phút
Config.BaseSalary = 1250 -- IC/15 phút (5,000 IC/giờ)

-- Chu kỳ sinh tiền (ms)
Config.EarningCycle = 900000 -- 900 giây (15 phút)

-- Thời gian làm việc tối đa
Config.MaxDailyHours = 12 -- 12 giờ/ngày
Config.MaxWeeklyHours = 84 -- 84 giờ/tuần

-- ============================================
-- HỆ THỐNG PENALTY (GIẢM ĐỘ BỀN THEO GIỜ)
-- ============================================
-- Chu kỳ kiểm tra penalty (ms) - mỗi giờ
Config.PenaltyCycle = 3600000 -- 1 giờ = 3600 giây

-- Penalty theo thời gian hoạt động
Config.PenaltyRanges = {
    -- 0-2 giờ: Không penalty
    {
        minHours = 0,
        maxHours = 2,
        penalties = {}
    },
    -- 2-4 giờ
    {
        minHours = 2,
        maxHours = 4,
        penalties = {
            {chance = 80, systems = 1, damage = 10},  -- 80%: 1 bộ phận -10%
            {chance = 20, systems = {1, 2}, damage = 10}  -- 20%: 1-2 bộ phận -10%
        }
    },
    -- 4-8 giờ
    {
        minHours = 4,
        maxHours = 8,
        penalties = {
            {chance = 55, systems = {1, 2}, damage = 30},  -- 55%: 1-2 bộ phận -30%
            {chance = 30, systems = 1, damage = 20},  -- 30%: 1 bộ phận -20%
            {chance = 15, systems = 0, damage = 0}  -- 15%: Không bị gì
        }
    },
    -- 8-12 giờ
    {
        minHours = 8,
        maxHours = 12,
        penalties = {
            {chance = 40, systems = 1, damage = 25},  -- 40%: 1 bộ phận -25%
            {chance = 30, systems = {1, 2}, damage = 30},  -- 30%: 1-2 bộ phận -30%
            {chance = 20, systems = 1, damage = 40},  -- 20%: 1 bộ phận -40%
            {chance = 10, systems = 0, damage = 0}  -- 10%: Không bị gì
        }
    }
}

-- ============================================
-- HỆ THỐNG 5 CHỈ SỐ
-- ============================================
-- Giá trị khởi tạo hệ thống
Config.InitialSystemValue = 100

-- Mỗi chỉ số đóng góp 20% lợi nhuận
Config.SystemProfitContribution = 20 -- %

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
