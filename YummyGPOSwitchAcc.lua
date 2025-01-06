-- =====================================
-- || SCRIPT MADE BY NPDK             ||
-- =====================================

print("=====================================")
print("|| ✅   SCRIPT MADE BY NPDK  ✅      ||")
print("|| 💸  HAVE A NICE DAY WITH MY SCRIPT!  💸 ||")
print("=====================================")

local HttpService = game:GetService("HttpService")
local fileCreated = false

-- Server IP configuration (set to the Flask server's IP address)
local flaskServerIP = getgenv().FlaskServerIP or "127.0.0.1" -- Default to localhost if not set
local flaskServerPort = "5000"

-- Function to fetch current level from the game
local function getCurrentLevel()
    local levelObject = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Main.Bars.Experience.Detail.Level

    if levelObject then
        if levelObject:IsA("TextLabel") or levelObject:IsA("TextBox") then
            local text = levelObject.Text
            local currentLevel = tonumber(string.match(text, "%d+"))
            if currentLevel then
                return currentLevel
            else
                print("Unable to extract Level value from text: " .. text)
                return 0
            end
        elseif levelObject:IsA("NumberValue") or levelObject:IsA("IntValue") then
            return levelObject.Value
        else
            print("Level object is not a valid type!")
            return 0
        end
    else
        print("Level object not found!")
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
        print("[Info] File " .. fileName .. " created with content: " .. fileContent)
    else
        print("[Error] Failed to create file: " .. tostring(err))
    end
end

-- Function to send HTTP request to Flask API using game:HttpGet
local function sendToFlaskApi(playerName, level)
    local machineId = game:GetService("RbxAnalyticsService"):GetClientId() -- Fetch unique machine ID
    local endpoint = "http://" .. flaskServerIP .. ":" .. flaskServerPort .. "/receive_data"
    local query = "?playerName=" .. HttpService:UrlEncode(playerName) .. 
                  "&currentLevel=" .. tostring(level) .. 
                  "&machineId=" .. HttpService:UrlEncode(machineId)

    local url = endpoint .. query

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        print("[Info] Data sent to Flask API: " .. response)
    else
        print("[Error] Failed to send data to Flask API: " .. tostring(response))
    end
end

-- Function to check level and send data to Flask API
local function checkLevel()
    local currentLevel = getCurrentLevel()
    print("[Info] Current Level: " .. currentLevel)
    
    if currentLevel >= getgenv().TargetLevel then
        print("[Info] Target Level reached: " .. currentLevel)
        local playerName = game.Players.LocalPlayer.Name
        createFile(playerName)
        sendToFlaskApi(playerName, currentLevel)
        fileCreated = true -- Stop further checks
    else
        print("[Info] Target Level not yet reached. Current: " .. currentLevel)
    end
end

-- Continuously check level until file is created
while not fileCreated do
    checkLevel()
    wait(getgenv().Delay)
end
