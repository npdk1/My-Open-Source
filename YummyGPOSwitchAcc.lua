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

-- Cấu hình máy chủ Flask (sử dụng IP công cộng)
local flaskServerURL = "http://171.226.231.220:5000/receive_data"  -- Địa chỉ IP công cộng và cổng Flask
local apiKey = "your_secure_api_key"  -- Thay đổi thành API key an toàn của bạn

-- Thiết lập Level mục tiêu và Delay
local targetLevel = 10  -- Level mục tiêu
local delayTime = 5  -- Thời gian delay giữa các lần kiểm tra (giây)

-- Hàm lấy Level hiện tại của người chơi
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

-- Hàm tạo file
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

-- Hàm gửi dữ liệu tới Flask API sử dụng POST
local function sendToFlaskApi(playerName, level)
    local machineId = RbxAnalyticsService:GetClientId()
    local data = {
        playerName = playerName,
        currentLevel = level,
        machineId = machineId,
        apiKey = apiKey
    }

    local jsonData = HttpService:JSONEncode(data)

    local success, response = pcall(function()
        return HttpService:PostAsync(flaskServerURL, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        print("[Info] Dữ liệu đã được gửi tới Flask API: " .. response)
    else
        warn("[Error] Gửi dữ liệu tới Flask API thất bại: " .. tostring(response))
    end
end

-- Hàm kiểm tra Level và gửi dữ liệu tới Flask API
local function checkLevel()
    local currentLevel = getCurrentLevel()
    print("[Info] Current Level: " .. currentLevel)
    
    if currentLevel >= targetLevel then
        print("[Info] Đã đạt Level mục tiêu: " .. currentLevel)
        local playerName = Players.LocalPlayer.Name
        createFile(playerName)
        sendToFlaskApi(playerName, currentLevel)
        fileCreated = true -- Dừng kiểm tra thêm
    else
        print("[Info] Chưa đạt Level mục tiêu. Current: " .. currentLevel)
    end
end

-- Vòng lặp kiểm tra Level liên tục
while not fileCreated do
    checkLevel()
    wait(delayTime)
end
