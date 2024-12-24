-- ======================================
-- || SCRIPT LUA - KEY VALIDATION SYSTEM ||
-- ======================================

print("=====================================")
print("|| ✅ SCRIPT MADE BY NPDK ✅        ||")
print("|| 💸 HAVE A NICE DAY WITH MY SCRIPT! 💸 ||")
print("=====================================")

-- Bật HttpService
local HttpService = game:GetService("HttpService")

if not HttpService.HttpEnabled then
    HttpService.HttpEnabled = true -- Thử bật (chỉ admin game có thể bật qua Studio)
end

-- Kiểm tra trạng thái HttpService
if not HttpService.HttpEnabled then
    game.Players.LocalPlayer:Kick("❌ HttpService chưa được bật! Vui lòng bật trong Game Settings > Security.")
    return
end

print("✅ HttpService đã được bật!")

-- Function lấy HWID của người dùng
local function getHWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId() -- Lấy HWID từ Roblox
    return hwid
end

-- Function gửi dữ liệu tới Flask API
local function sendKeyAndHWID()
    local hwid = getHWID()
    local key = getgenv().Key
    local api_url = getgenv().API_URL

    print("🔄 Đang gửi key và HWID đến API...")

    -- Tạo payload để gửi
    local payload = {
        key = key,
        hwid = hwid
    }

    -- Encode payload thành JSON
    local json_payload = HttpService:JSONEncode(payload)

    -- Thực hiện POST request tới API
    local success, response = pcall(function()
        return HttpService:PostAsync(api_url, json_payload, Enum.HttpContentType.ApplicationJson)
    end)

    -- Xử lý phản hồi từ API
    if success then
        local result = HttpService:JSONDecode(response)
        if result.status == "success" then
            print("✅ Key hợp lệ và HWID đã được xác thực. Script tiếp tục chạy!")
        else
            print("❌ Lỗi từ API: " .. result.message)
            game.Players.LocalPlayer:Kick("❌ Key không hợp lệ hoặc HWID không khớp. Script sẽ không chạy.")
        end
    else
        print("❌ Không thể kết nối tới API. Chi tiết lỗi: " .. tostring(response))
        game.Players.LocalPlayer:Kick("❌ Lỗi kết nối API. Script không thể tiếp tục.")
    end
end

-- Kiểm tra và gửi HWID liên tục theo thời gian cấu hình
while true do
    sendKeyAndHWID()
    wait(getgenv().Delay) -- Chờ trước khi gửi lại
end
