print("=====================================")
print("|| ✅   SCRIPT MADE BY NPDK  ✅      ||")
print("|| 💸  HAVE A NICE DAY WITH MY SCRIPT!  💸 ||")
print("=====================================")

----------------------------------------
-- THÊM ĐOẠN CHECK KEY TỪ SERVER
----------------------------------------
local http = syn and syn.request or http_request or http and http.request
if not http then
    warn("[Lỗi] Exploit của bạn không hỗ trợ http requests!")
    return
end

-- ĐỊA CHỈ API CHO KEY SYSTEM (ví dụ Flask)
local validateUrl = "http://127.0.0.1:5000/roblox_validate" 
-- Thay bằng IP/Domain server thực tế, ví dụ:
-- "http://xxx.xxx.xxx.xxx:5000/roblox_validate"
-- hoặc "https://example.com/roblox_validate"

-- JSON encode đơn giản (nếu exploit chưa có sẵn)
local HttpService = game:GetService("HttpService")

local function sendKeyRequest(key)
    local player = game.Players.LocalPlayer
    local hwid = tostring(player.UserId)  -- Hoặc hwid tuỳ ý

    local bodyTable = {
        key = key,
        hwid = hwid
    }

    local jsonData = HttpService:JSONEncode(bodyTable)
    local response = http({
        Url = validateUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = jsonData
    })

    return response
end

----------------------------------------
-- TIẾN HÀNH GỌI API CHECK KEY
----------------------------------------
local res = nil
local success, err = pcall(function()
    res = sendKeyRequest(getgenv().Key)
end)

if not success then
    warn("[Lỗi] Không thể kết nối tới server key:", err)
    return
end

-- Kiểm tra response
if res and res.StatusCode == 200 then
    -- Thử giải mã JSON
    local decoded = {}
    pcall(function()
        decoded = HttpService:JSONDecode(res.Body)
    end)

    if decoded.status == "success" then
        print("[Key System] ✅ Key hợp lệ! Tiếp tục script...")
        print("[Key System] Thông báo server:", decoded.message)
    else
        warn("[Key System] ❌ Key fail:", decoded.message or "Lý do không rõ")
        return
    end
else
    warn("[Key System] ❌ Kết nối bị lỗi hoặc StatusCode != 200!")
    if res then
        warn("Chi tiết:", res.StatusCode, res.Body)
    end
    return
end

----------------------------------------
-- CODE GỐC KIỂM TRA LEVEL + TẠO FILE
----------------------------------------

-- Biến cờ để kiểm tra xem file đã được tạo chưa
local fileCreated = false

-- Hàm phát hiện Level trong game GPO
local function getCurrentLevel()
    local levelObject = game:GetService("Players").LocalPlayer
                       .PlayerGui.HUD.Main.Bars.Experience.Detail.Level
    if levelObject then
        if levelObject:IsA("TextLabel") or levelObject:IsA("TextBox") then
            local text = levelObject.Text
            local currentLevel = tonumber(string.match(text, "%d+"))
            if currentLevel then
                return currentLevel
            else
                print("[Thông báo] Không thể trích xuất Level từ text:", text)
                return 0
            end
        elseif levelObject:IsA("NumberValue") or levelObject:IsA("IntValue") then
            return levelObject.Value
        else
            print("[Thông báo] Đối tượng Level không phải TextLabel/TextBox/NumberValue!")
            return 0
        end
    else
        print("[Thông báo] Không tìm thấy đối tượng Level!")
        return 0
    end
end

-- Hàm ghi file
local function createFile(playerName)
    if not fileCreated then
        local fileName = playerName .. ".txt"
        local fileContent = "Yummytool"
        local success, err = pcall(function()
            writefile(fileName, fileContent)
        end)
        if success then
            print("[Thông báo] Đã tạo file:", fileName, "Nội dung:", fileContent)
            fileCreated = true
        else
            print("[Lỗi] Không thể tạo file:", tostring(err))
        end
    else
        print("[Thông báo] File đã được tạo trước đó, không tạo lại.")
    end
end

-- Hàm check Level
local function checkLevel()
    local currentLevel = getCurrentLevel()
    print("[Thông báo] Level hiện tại:", currentLevel)
    if currentLevel >= getgenv().TargetLevel then
        print("[Thông báo] Đã đạt đủ Level mục tiêu:", currentLevel)
        return true
    else
        print("[Thông báo] Chưa đủ level! (Target:", getgenv().TargetLevel, ")")
        return false
    end
end

-- Vòng lặp kiểm tra Level liên tục
while not fileCreated do
    local isLevelEnough = checkLevel()
    if isLevelEnough then
        local playerName = game.Players.LocalPlayer.Name
        createFile(playerName)  -- Tạo file khi đạt đủ Level
    end
    wait(getgenv().Delay)
end
