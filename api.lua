-- =====================================
-- || SCRIPT MADE BY NPDK             ||
-- =====================================

print("=====================================")
print("|| ✅   SCRIPT MADE BY NPDK  ✅      ||")
print("|| 💸  HAVE A NICE DAY WITH MY SCRIPT!  💸 ||")
print("=====================================")


-- URL của script (đảm bảo URL tồn tại)
local script_url = "https://raw.githubusercontent.com/npdk1/My-Product/main/Grand%20Piece%20Online%20Roblox/api.lua"

-- Lấy HWID của thiết bị
local http = game:GetService("HttpService")
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

-- API URL từ Flask Server (cập nhật với địa chỉ IP server của bạn)
local api_url = "http://127.0.0.1:5000/update_hwid"

-- Gửi HWID và key đến API để xác thực
local function validateKey(key, hwid)
    local payload = http:JSONEncode({key = key, hwid = hwid})
    local success, response = pcall(function()
        return http:PostAsync(api_url, payload, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        local result = http:JSONDecode(response)
        if result.status == "success" then
            print("✅ Key hợp lệ và HWID đã được xác thực!")
            return true
        else
            print("❌ Lỗi: " .. result.message)
            return false
        end
    else
        print("❌ Không thể kết nối đến API. Chi tiết lỗi: " .. tostring(response))
        return false
    end
end

-- Kiểm tra key trước khi chạy script
if not validateKey(getgenv().Key, hwid) then
    print("❌ Key không hợp lệ hoặc HWID không khớp. Vui lòng kiểm tra lại!")
    return -- Dừng script nếu key không hợp lệ
end

-- Hàm tải script từ URL và thực thi
local function loadScriptFromURL(url)
    print("🔄 Đang tải script từ URL: " .. url)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)

    if success then
        print("✅ Tải script thành công từ URL!")
        local loadSuccess, loadError = pcall(function()
            loadstring(result)()
        end)

        if not loadSuccess then
            print("❌ Lỗi khi thực thi script: " .. tostring(loadError))
        end
    else
        print("❌ Không thể tải script từ URL. Đảm bảo rằng URL tồn tại và có thể truy cập được.")
        print("Chi tiết lỗi: " .. tostring(result))
    end
end

-- Gọi hàm để tải và thực thi script
loadScriptFromURL(script_url)

-- Biến cờ để kiểm tra xem file đã được tạo chưa
local fileCreated = false

-- Hàm phát hiện Level trong game GPO
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
