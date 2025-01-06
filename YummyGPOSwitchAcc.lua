-- ================================
-- || Hàm gửi yêu cầu HTTP       ||
-- ================================
local function sendRequest(url, method, body)
    local http = game:GetService("HttpService")
    local response = nil

    if method == "POST" then
        local success, result = pcall(function()
            return http:RequestAsync({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body and http:JSONEncode(body) or ""
            })
        end)

        if success then
            response = result
        else
            print("[Lỗi] Không thể gửi POST request: " .. tostring(result))
        end

    elseif method == "GET" then
        local success, result = pcall(function()
            return http:RequestAsync({
                Url = url,
                Method = "GET"
            })
        end)

        if success then
            response = result
        else
            print("[Lỗi] Không thể gửi GET request: " .. tostring(result))
        end
    else
        print("[Lỗi] Phương thức không hợp lệ. Chỉ hỗ trợ GET hoặc POST.")
    end

    return response
end

-- ================================
-- || Kết nối với Flask API      ||
-- ================================
local function sendToFlask(currentLevel)
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    local playerName = game.Players.LocalPlayer.Name

    -- Payload để gửi
    local payload = {
        key = HiddenConfig.Key, -- Key cố định
        hwid = hwid,
        level = currentLevel,
        player_name = playerName
    }

    -- Gửi POST request đến Flask API
    local response = sendRequest(HiddenConfig.FlaskURL, "POST", payload)

    if response then
        local decoded = game:GetService("HttpService"):JSONDecode(response.Body)
        if decoded.status == "success" then
            print("[Thông báo] Kết nối Flask thành công! Thông điệp: " .. decoded.message)
        else
            print("[Cảnh báo] Kết nối Flask thất bại. Thông điệp: " .. decoded.message)
        end
    else
        print("[Lỗi] Không nhận được phản hồi từ Flask.")
    end
end

-- ================================
-- || Kiểm tra Level và gửi data ||
-- ================================
local function checkLevel()
    local currentLevel = getCurrentLevel()
    print("[Thông báo] Level hiện tại: " .. currentLevel)

    if currentLevel >= getgenv().TargetLevel then
        print("[Thông báo] Đạt đủ Level mục tiêu: " .. currentLevel)
        sendToFlask(currentLevel)
        return true
    else
        print("[Thông báo] Chưa đạt đủ Level! Hiện tại: " .. currentLevel)
        return false
    end
end
