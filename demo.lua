-- =====================================
-- || SCRIPT MADE BY NPDK             ||
-- =====================================

print("=====================================")
print("|| ✅   SCRIPT MADE BY NPDK  ✅      ||")
print("|| 💸  HAVE A NICE DAY WITH MY SCRIPT!  💸 ||")
print("=====================================")

-- Tải script từ GitHub với getgenv và loadstring
getgenv().TargetLevel = 100 -- Cấp độ mục tiêu
getgenv().Delay = 1 -- Thời gian chờ giữa các lần kiểm tra (tính bằng giây)

-- Tự động tăng TargetLevel theo thời gian
spawn(function()
    while true do
        wait(60) -- Thời gian tăng cấp độ mục tiêu (tính bằng giây)
        getgenv().TargetLevel = getgenv().TargetLevel + 10 -- Tăng 10 cấp mỗi phút
        print("[Thông báo] Cấp độ mục tiêu mới: " .. getgenv().TargetLevel)
    end
end)

-- Hàm tạo bảng hiển thị giữa màn hình
local function createDisplay()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0.3, 0, 0.1, 0)
    Frame.Position = UDim2.new(0.35, 0, 0.45, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.5

    local LevelLabel = Instance.new("TextLabel", Frame)
    LevelLabel.Size = UDim2.new(1, 0, 0.5, 0)
    LevelLabel.Position = UDim2.new(0, 0, 0, 0)
    LevelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LevelLabel.TextScaled = true
    LevelLabel.Text = "Current Level: 0"

    local TargetLabel = Instance.new("TextLabel", Frame)
    TargetLabel.Size = UDim2.new(1, 0, 0.5, 0)
    TargetLabel.Position = UDim2.new(0, 0, 0.5, 0)
    TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetLabel.TextScaled = true
    TargetLabel.Text = "Target Level: " .. getgenv().TargetLevel

    return LevelLabel, TargetLabel
end

-- Cập nhật bảng hiển thị
local LevelLabel, TargetLabel = createDisplay()
spawn(function()
    while true do
        local currentLevel = game:GetService("Players").LocalPlayer.PlayerStats.lvl.Value
        LevelLabel.Text = "Current Level: " .. tostring(currentLevel)
        TargetLabel.Text = "Target Level: " .. tostring(getgenv().TargetLevel)
        wait(1)
    end
end)

