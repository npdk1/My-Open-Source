-- Cấu hình Key và các thông số cần thiết
getgenv().Key = "KTOOLS-D15XJ-YGSRB-07EY8" -- Key của người dùng
getgenv().TargetLevel = 1 -- Mục tiêu cấp độ
getgenv().Delay = 5 -- Thời gian chờ giữa các lần kiểm tra (giây)

-- Lấy HWID
local http = game:GetService("HttpService")
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

-- In ra HWID để kiểm tra
print("🔑 HWID của bạn: " .. hwid)

-- Thông báo lỗi nếu HWID không được gửi đến API
print("⚠️ Vui lòng đảm bảo rằng bạn đã sử dụng đúng công cụ hỗ trợ API để gửi HWID.")

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
