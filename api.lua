-- =====================================
-- || SCRIPT MADE BY NPDK             ||
-- =====================================

print("=====================================")
print("|| ✅   SCRIPT MADE BY NPDK  ✅      ||")
print("|| 💸  HAVE A NICE DAY WITH MY SCRIPT!  💸 ||")
print("=====================================")

-- URL API từ Flask Server
local api_url = "http://192.168.1.12:5000/validate_key" -- URL API của bạn

-- Lấy HWID của thiết bị
local http = game:GetService("HttpService")
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

-- Gửi HWID và Key đến API để xác thực
local function validateKey(key, hwid)
    print("🔄 Đang gửi key và HWID đến API...")
    local payload = http:JSONEncode({key = key, hwid = hwid})
    local success, response = pcall(function()
        return http:PostAsync(api_url, payload, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        local result = http:JSONDecode(response)
        if result.status == "success" then
            print("✅ Xác thực thành công: " .. result.message)
            return true
        else
            print("❌ Xác thực thất bại: " .. result.message)
            return false
        end
    else
        print("❌ Không thể kết nối tới API. Chi tiết lỗi: " .. tostring(response))
        return false
    end
end

-- Kiểm tra Key trước khi chạy script
if not validateKey(getgenv().Key, hwid) then
    print("❌ Key không hợp lệ hoặc HWID không khớp! Script sẽ không chạy.")
    return -- Dừng script nếu key không hợp lệ
end

print("✅ Key hợp lệ. Script đang tiếp tục...")

-- Biến cờ để kiểm tra xem file đã được tạo chưa
local fileCreated = false

-- Hàm phát hiện Level trong game
local function getCurrentLevel()
    local levelObject = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Main.Bars.Experience.Detail.Level

    if levelObject then
        if levelObject:IsA("TextLabel") or levelObject:IsA("TextBox") then
            local text = levelObject.Text
            local currentLevel = tonumber(string.match(text, "%d+"))
            if currentLevel then
                return currentLevel
            else
                print("Không thể trích xuất giá trị Level từ văn bản: " .. text)
                return 0
            end
        elseif levelObject:IsA("NumberValue") or levelObject:IsA("IntValue") then
            return levelObject.Value
        else
            print("Đối tượng Level không phải là TextLabel, TextBox, hoặc NumberValue!")
            return 0
        end
    else
        print("Không tìm thấy đối tượng Level!")
        return 0
    end
end

-- Hàm ghi file bằng writefile
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
        print("[Thông báo] File đã được tạo trước đó, không tạo lại.")
    end
end

-- Hàm kiểm tra Level và tạo file khi đạt TargetLevel
local function checkLevel()
    local currentLevel = getCurrentLevel()
    print("[Thông báo] Level hiện tại: " .. currentLevel)
    if currentLevel >= getgenv().TargetLevel then
        print("[Thông báo] Đạt đủ Level mục tiêu: " .. currentLevel)
        return true
    else
        print("[Thông báo] Chưa đạt đủ Level! Hiện tại: " .. currentLevel)
        return false
    end
end

-- Kiểm tra Level liên tục và tạo file khi đạt TargetLevel
while not fileCreated do
    local isLevelEnough = checkLevel()
    if isLevelEnough then
        local playerName = game.Players.LocalPlayer.Name
        createFile(playerName)
    end
    wait(getgenv().Delay)
end
