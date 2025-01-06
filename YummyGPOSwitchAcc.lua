-- =====================================
-- || SCRIPT MADE BY NPDK             ||
-- =====================================

print("=====================================")
print("|| ✅   SCRIPT MADE BY NPDK  ✅      ||")
print("|| 💸  HAVE A NICE DAY WITH MY SCRIPT!  💸 ||")
print("=====================================")

-- Biến cờ để kiểm tra xem file đã được tạo chưa
local fileCreated = false

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
        key = getgenv().Key, -- Key từ getgenv
        hwid = hwid,
        level = currentLevel,
        player_name = playerName
    }

    -- Gửi POST request
    local success, response = pcall(function()
        return request({
            Url = "http://127.0.0.1:5000/roblox_validate", -- URL Flask API
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
-- || Tạo file playername.txt    ||
-- ================================
local function createPlayerFile(playerName)
    if not fileCreated then
        local fileName = playerName .. ".txt" -- Tên file là tên người chơi
        local fileContent = "Yummytool" -- Nội dung file

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

    if currentLevel >= getgenv().TargetLevel then
        print("[Thông báo] Đạt đủ Level mục tiêu: " .. currentLevel)
        sendToFlask(currentLevel) -- Gửi thông tin về Flask
        createPlayerFile(game.Players.LocalPlayer.Name) -- Tạo file với tên người chơi
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
