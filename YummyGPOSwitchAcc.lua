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
    AntiHttpSpyEnabled = true -- Bật/Tắt Anti HTTP Spy
}

-- Lấy thông số từ getgenv
local Config = {
    TargetLevel = getgenv().TargetLevel or 10, -- Mức Level mục tiêu
    Delay = getgenv().Delay or 5, -- Thời gian delay mỗi lần kiểm tra (giây)
    Key = getgenv().Key or "DEFAULT_KEY" -- Key từ getgenv
}

-- ================================
-- || ANTI HTTP SPY              ||
-- ================================
if HiddenConfig.AntiHttpSpyEnabled then
    local hookfunction = hookfunction or nil

    -- Hook các hàm HTTP
    local oldHttpGet = game.HttpGet
    hookfunction(game.HttpGet, function(self, ...)
        return error("HTTP request bị chặn bởi Anti-HTTP Spy")
    end)

    local oldHttpPost = game.HttpPost
    hookfunction(game.HttpPost, function(self, ...)
        return error("HTTP request bị chặn bởi Anti-HTTP Spy")
    end)

    print("[Thông báo] Anti HTTP Spy đã được kích hoạt.")
end

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
    local http = game:GetService("HttpService")
    local hwid = getHWID()
    local playerName = game.Players.LocalPlayer.Name

    -- Tạo payload để gửi
    local payload = {
        key = Config.Key, -- Sử dụng Key từ Config
        hwid = hwid,
        level = currentLevel,
        player_name = playerName
    }

    local success, response = pcall(function()
        return http:PostAsync(
            HiddenConfig.FlaskURL,
            http:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if success then
        local decoded = http:JSONDecode(response)
        if decoded.status == "success" then
            print("[Thông báo] Kết nối Flask thành công! Thông điệp: " .. decoded.message)
        else
            print("[Cảnh báo] Kết nối Flask thất bại. Thông điệp: " .. decoded.message)
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
-- || Hàm tạo file               ||
-- ================================
local fileCreated = false
local function createFile(playerName)
    if not fileCreated then
        local fileName = playerName .. ".txt"
        local fileContent = "Yummytool"

        local success, err = pcall(function()
            writefile(fileName, fileContent)
        end)

        if success then
            print("[Thông báo] File " .. fileName .. " đã được tạo với nội dung: " .. fileContent)
            fileCreated = true
        else
            print("[Lỗi] Không thể tạo file: " .. tostring(err))
        end
    else
        print("[Thông báo] File đã được tạo trước đó.")
    end
end

-- ================================
-- || Kiểm tra Level             ||
-- ================================
local function checkLevel()
    local currentLevel = getCurrentLevel()
    print("[Thông báo] Level hiện tại: " .. currentLevel)

    if currentLevel >= Config.TargetLevel then
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
while not fileCreated do
    local isLevelEnough = checkLevel()
    if isLevelEnough then
        local playerName = game.Players.LocalPlayer.Name
        createFile(playerName)
    end
    wait(Config.Delay)
end
