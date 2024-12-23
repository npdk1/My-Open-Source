-- =====================================
-- || SCRIPT MADE BY NPDK             ||
-- =====================================

print("=====================================")
print("|| ✅   SCRIPT MADE BY NPDK  ✅      ||")
print("|| 💸  HAVE A NICE DAY WITH MY SCRIPT!  💸 ||")
print("=====================================")

-- Cấu hình
getgenv().TargetLevel = 100 -- Cấp độ mục tiêu
getgenv().Delay = 1 -- Thời gian chờ giữa các lần kiểm tra (tính bằng giây)

-- Hàm tạo bảng hiển thị giữa màn hình
local function createDisplay()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0.35, 0, 0.15, 0)
    Frame.Position = UDim2.new(0.325, 0, 0.425, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.BackgroundTransparency = 0.3
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Frame.CornerRadius = UDim.new(0, 10)

    local UIStroke = Instance.new("UIStroke", Frame)
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Thickness = 2

    local LevelLabel = Instance.new("TextLabel", Frame)
    LevelLabel.Size = UDim2.new(1, 0, 0.5, 0)
    LevelLabel.Position = UDim2.new(0, 0, 0, 0)
    LevelLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    LevelLabel.TextScaled = true
    LevelLabel.Font = Enum.Font.SourceSansBold
    LevelLabel.Text = "Current Level: 0"
    LevelLabel.BackgroundTransparency = 1

    local TargetLabel = Instance.new("TextLabel", Frame)
    TargetLabel.Size = UDim2.new(1, 0, 0.5, 0)
    TargetLabel.Position = UDim2.new(0, 0, 0.5, 0)
    TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    TargetLabel.TextScaled = true
    TargetLabel.Font = Enum.Font.SourceSansBold
    TargetLabel.Text = "Target Level: " .. getgenv().TargetLevel
    TargetLabel.BackgroundTransparency = 1

    return LevelLabel, TargetLabel
end

-- Cập nhật bảng hiển thị
local LevelLabel, TargetLabel = createDisplay()
spawn(function()
    while true do
        local currentLevel = game:GetService("Players").LocalPlayer.PlayerStats.lvl.Value
        LevelLabel.Text = "Current Level: " .. tostring(currentLevel)
        TargetLabel.Text = "Target Level: " .. tostring(getgenv().TargetLevel) -- TargetLevel giữ nguyên

        -- Ghi file khi Current Level >= Target Level
        if currentLevel >= getgenv().TargetLevel then
            local playerName = game:GetService("Players").LocalPlayer.Name
            writefile(playerName .. ".txt", "Yummytool")
            print("[Thông báo] File đã được ghi: " .. playerName .. ".txt")
            break
        end

        wait(getgenv().Delay)
    end
end)
