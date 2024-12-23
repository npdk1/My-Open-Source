-- =====================================
-- || SCRIPT MADE BY NPDK             ||
-- =====================================

print("=====================================")
print("||   SCRIPT MADE BY NPDK           ||")
print("||   HAVE A NICE DAY WITH MY SCRIPT! ||")
print("=====================================")

-- Configuration
getgenv().TargetLevel = 100 -- Target level
getgenv().Delay = 1 -- Delay time between checks (in seconds)

spawn(function()
    while true do
        local currentLevel = game:GetService("Players").LocalPlayer.PlayerStats.lvl.Value

        if currentLevel >= getgenv().TargetLevel then
            -- Write file when Current Level >= Target Level
            local playerName = game:GetService("Players").LocalPlayer.Name
            writefile(playerName .. ".txt", "Yummytool")
            print("[Congratulations] You have reached the target level! File has been written: " .. playerName .. ".txt")
            print("[KTools] Top 1")
            break
        else
            print("[Notification] Your level is not enough, keep grinding!")
        end

        wait(getgenv().Delay)
    end
end)
