-- =====================================
-- || SCRIPT MADE BY NPDK             ||
-- =====================================

print("=====================================")
print("|| ✅   SCRIPT MADE BY NPDK  ✅      ||")
print("|| 💸  HAVE A NICE DAY WITH MY SCRIPT!  💸 ||")
print("=====================================")

-- Cấu hình ẩn (cố định, không thể thay đổi)
local HiddenConfig = {
    FlaskURL = "http://127.0.0.1:5000/roblox_validate", -- URL Flask API
    Key = "SECRET_KEY_HERE" -- Key cố định
}

-- Cấu hình công khai (có thể chỉnh qua getgenv)
getgenv().TargetLevel = getgenv().TargetLevel or 10 -- Mức Level mục tiêu
getgenv().Delay = getgenv().Delay or 5 -- Thời gian delay mỗi lần kiểm tra (giây)

-- ================================
-- || Mở HTTP Request            ||
-- ================================
if not request then
    error("Executor của bạn không hỗ trợ HTTP requests (yêu cầu hàm request).")
end

print("[Thông báo] HTTP Request đã được kích hoạt!")

-- ================================
-- || Hàm lấy HWID               ||
-- ================================
local function getHWID()
    return game:GetService("RbxAnalyticsService"):GetClientId()
end

-- ================================
-- || Kết nối với Flask API      ||
-- ================================
local function sendToFlask(currentLevel)
    local httpService = game:GetService("HttpService")
    local hwid = getHWID()
    local playerName = game.Players.LocalPlayer.Name

    -- Tạo payload để gửi
    local payload = {
        key = HiddenConfig.Key, -- Sử dụng key ẩn
        hwid = hwid,
        level = currentLevel,
        player_name = playerName
    }

    -- Gửi POST request
    local success, response = pcall(function()
        return request({
            Url = HiddenConfig.FlaskURL, -- Endpoint Flask API
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json" -- Định dạng JSON
            },
            Body = httpService:JSONEncode(payload) -- Chuyển đổi payload sang JSON
        })
    end)

    if success then
        local decoded = httpService:JSONDecode(response.Body)
        if decoded.status == "success" then
            print("[Thông báo] Kết nối Flask thành công! Thông điệp: " .. decoded.message)
        else
            print("[Cảnh báo] Flask trả về thất bại: " .. decoded.message)
        end
    else
        print("[Lỗi] Không thể kết nối Flask: " .. tostring(response))
    end
end

-- ================================
-- || Hàm lấy Level hiện tại     ||
-- ================================
local function getCurrentLevel()
    local levelObject = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Main.Bars.Experience.Detail.Level

    if levelObject then
        if levelObject:IsA("TextLabel") or levelObject:IsA("TextBox") then
            local text = levelObject.Text
            local currentLevel = tonumber(string.match(text, "%d+"))
            return currentLevel or 0
        elseif levelObject:IsA("NumberValue") or levelObject:IsA("IntValue") then
            return levelObject.Value
        end
    end

    return 0
end

-- ================================
-- || Kiểm tra Level             ||
-- ================================
local function checkLevel()
    local currentLevel = getCurrentLevel()
    print("[Thông báo] Level hiện tại: " .. currentLevel)

    if currentLevel >= getgenv().TargetLevel then
        print("[Thông báo] Đạt đủ Level mục tiêu: " .. currentLevel)
        sendToFlask(currentLevel) -- Gửi thông tin về Flask
        return true
    else
        print("[Thông báo] Chưa đạt đủ Level! Hiện tại: " .. currentLevel)
        return false
    end
end

-- ================================
-- || Vòng lặp chính             ||
-- ================================
while true do
    local isLevelEnough = checkLevel()
    if isLevelEnough then
        break
    end
    wait(getgenv().Delay)
end
