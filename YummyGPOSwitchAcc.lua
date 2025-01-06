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

-- Server IP configuration (set to the Flask server's public IP address)
local flaskServerIP = getgenv().FlaskServerIP or "171.226.231.220" -- Đặt thành địa chỉ IP công cộng của bạn
local flaskServerPort = "5000"
local apiKey = getgenv().ApiKey or "your_secure_api_key" -- Đặt API key an toàn

-- Target level và Delay có thể được thiết lập từ getgenv()
local targetLevel = getgenv().TargetLevel or 10 -- Giá trị mặc định là 10 nếu không đặt
local delayTime = getgenv().Delay or 5 -- Giá trị mặc định là 5 giây nếu không đặt

-- Function to fetch current level from the game
local function getCurrentLevel()
    local player = Players.LocalPlayer
    if not player then
        print("[Error] Không tìm thấy LocalPlayer!")
        return 0
    end

    local levelObject = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("HUD") and 
                        player.PlayerGui.HUD:FindFirstChild("Main") and 
                        player.PlayerGui.HUD.Main:FindFirstChild("Bars") and 
                        player.PlayerGui.HUD.Main.Bars:FindFirstChild("Experience") and 
                        player.PlayerGui.HUD.Main.Bars.Experience:FindFirstChild("Detail") and 
                        player.PlayerGui.HUD.Main.Bars.Experience.Detail:FindFirstChild("Level")

    if levelObject then
        if levelObject:IsA("TextLabel") or levelObject:IsA("TextBox") then
            local text = levelObject.Text
            local currentLevel = tonumber(string.match(text, "%d+"))
            if currentLevel then
                return currentLevel
            else
                print("[Error] Không thể trích xuất giá trị Level từ text: " .. text)
                return 0
            end
        elseif levelObject:IsA("NumberValue") or levelObject:IsA("IntValue") then
            return levelObject.Value
        else
            print("[Error] Level object không phải là kiểu hợp lệ!")
            return 0
        end
    else
        print("[Error] Không tìm thấy Level object!")
        return 0
    end
end

-- Function to create a file
local function createFile(playerName)
    local fileName = playerName .. ".txt"
    local fileContent = "Yummytool"

    local success, err = pcall(function()
        writefile(fileName, fileContent)
    end)

    if success then
        print("[Info] File " .. fileName .. " đã được tạo với nội dung: " .. fileContent)
    else
        print("[Error] Tạo file thất bại: " .. tostring(err))
    end
end

-- Function to send HTTP request to Flask API using HttpService:GetAsync
local function sendToFlaskApi(playerName, level)
    local machineId = RbxAnalyticsService:GetClientId() -- Lấy ID máy duy nhất
    local endpoint = "http://" .. flaskServerIP .. ":" .. flaskServerPort .. "/receive_data"
    local query = "?playerName=" .. HttpService:UrlEncode(playerName) .. 
                  "&currentLevel=" .. tostring(level) .. 
                  "&machineId=" .. HttpService:UrlEncode(machineId) ..
                  "&apiKey=" .. HttpService:UrlEncode(apiKey) -- Thêm API key vào query

    local url = endpoint .. query

    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        print("[Info] Dữ liệu đã được gửi tới Flask API: " .. response)
    else
        print("[Error] Gửi dữ liệu tới Flask API thất bại: " .. tostring(response))
    end
end

-- Function to check level and send data to Flask API
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

-- Continuously check level until file is created
while not fileCreated do
    checkLevel()
    wait(delayTime)
end
