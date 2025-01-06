-- =====================================
-- || SCRIPT MADE BY NPDK             ||
-- =====================================

print("=====================================")
print("|| ✅   SCRIPT MADE BY NPDK  ✅      ||")
print("|| 💸  HAVE A NICE DAY WITH MY SCRIPT!  💸 ||")
print("=====================================")

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local fileCreated = false

-- =======================
-- Cấu Hình (Sử dụng getgenv)
-- =======================
local config = {
    flaskServerURL = "http://YOUR_PUBLIC_IP:5000/receive_data",  -- Thay YOUR_PUBLIC_IP bằng địa chỉ IP công cộng của bạn hoặc hostname DDNS
    apiKey = getgenv().Key or "DEFAULT-KEY",  -- Sử dụng Key từ getgenv hoặc mặc định
    targetLevel = getgenv().TargetLevel or 10,  -- Level mục tiêu từ getgenv hoặc mặc định
    delayTime = getgenv().Delay or 5  -- Delay giữa các lần kiểm tra từ getgenv hoặc mặc định
}

-- =======================
-- Hàm Lấy HWID (Hardware ID)
-- =======================
local function getHWID()
    -- Trong Roblox thông thường, không thể lấy HWID vì lý do bảo mật.
    -- Nếu bạn đang sử dụng một exploit hoặc dịch vụ bên ngoài, hãy đảm bảo rằng bạn tuân thủ các chính sách của Roblox.
    -- Dưới đây là một ví dụ giả định:
    
    local hwid = "EXAMPLE-HWID-1234-5678"  -- Thay thế bằng cách lấy HWID thực tế
    return hwid
end

-- =======================
-- Hàm Lấy Level Hiện Tại Của Người Chơi
-- =======================
local function getCurrentLevel()
    local player = Players.LocalPlayer
    if not player then
        warn("[Error] Không tìm thấy LocalPlayer!")
        return 0
    end

    -- Điều chỉnh đường dẫn đến Level object tùy thuộc vào GUI của bạn
    local levelObject = player:FindFirstChild("PlayerGui", true):FindFirstChild("HUD/Main/Bars/Experience/Detail/Level")
    
    if levelObject then
        if levelObject:IsA("TextLabel") or levelObject:IsA("TextBox") then
            local text = levelObject.Text
            local currentLevel = tonumber(string.match(text, "%d+"))
            if currentLevel then
                return currentLevel
            else
                warn("[Error] Không thể trích xuất giá trị Level từ text: " .. text)
                return 0
            end
        elseif levelObject:IsA("NumberValue") or levelObject:IsA("IntValue") then
            return levelObject.Value
        else
            warn("[Error] Level object không phải là kiểu hợp lệ!")
            return 0
        end
    else
        warn("[Error] Không tìm thấy Level object!")
        return 0
    end
end

-- =======================
-- Hàm Tạo File (Chỉ hoạt động trong môi trường exploit hoặc sử dụng dịch vụ bên ngoài)
-- =======================
local function createFile(playerName)
    local fileName = playerName .. ".txt"
    local fileContent = "Yummytool"

    local success, err = pcall(function()
        writefile(fileName, fileContent)
    end)

    if success then
        print("[Info] File " .. fileName .. " đã được tạo với nội dung: " .. fileContent)
    else
        warn("[Error] Tạo file thất bại: " .. tostring(err))
    end
end

-- =======================
-- Hàm Gửi Dữ Liệu Tới Flask API Sử Dụng POST
-- =======================
local function sendToFlaskApi(playerName, level, hwid)
    local machineId = RbxAnalyticsService:GetClientId()
    local data = {
        key = config.apiKey,
        hwid = hwid,
        playerName = playerName,
        currentLevel = level,
        machineId = machineId
    }

    local jsonData = HttpService:JSONEncode(data)

    local success, response = pcall(function()
        return HttpService:PostAsync(config.flaskServerURL, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        print("[Info] Dữ liệu đã được gửi tới Flask API: " .. response)
    else
        warn("[Error] Gửi dữ liệu tới Flask API thất bại: " .. tostring(response))
    end
end

-- =======================
-- Hàm Kiểm Tra Key và Level
-- =======================
local function checkKeyAndLevel()
    local currentLevel = getCurrentLevel()
    print("[Info] Current Level: " .. currentLevel)
    
    if currentLevel >= config.targetLevel then
        print("[Info] Đã đạt Level mục tiêu: " .. currentLevel)
        local playerName = Players.LocalPlayer.Name
        local hwid = getHWID()
        createFile(playerName)
        sendToFlaskApi(playerName, currentLevel, hwid)
        fileCreated = true -- Dừng kiểm tra thêm
    else
        print("[Info] Chưa đạt Level mục tiêu. Current: " .. currentLevel)
    end
end

-- =======================
-- Vòng Lặp Kiểm Tra Key và Level Liên Tục
-- =======================
while not fileCreated do
    checkKeyAndLevel()
    wait(config.delayTime)
end
