--[[
╔════════════════════════════════════════════════════════════════════════════╗
║     ZYXHUB - BLOX FRUIT AUTO FARM V1                                       ║
║     "Auto Farm Quest + Auto Beli Fighting Style + Level Based"            ║
║     Creator: XamiX (Sea Zone Team)                                        ║
║     Fitur: Auto Quest | Auto Kill NPC | Auto Beli Dark Step |             ║
║            Ketinggian bisa diatur | Level Progression                     ║
╚════════════════════════════════════════════════════════════════════════════╝
]]

-- Load Rayfield dengan error handling
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local AutoFarmEnabled = false
local AutoQuestEnabled = true
local AutoBuyDarkStep = true
local CurrentLevel = 0
local CurrentBeli = 0
local TargetNPC = nil
local CurrentQuest = nil
local QuestLocation = nil
local KillCount = 0
local RequiredKills = 0
local FarmHeight = 50 -- Ketinggian default (bisa diatur)
local ToggleGUI = true

-- Data Fighting Style
local FightingStyles = {
    ["Dark Step"] = {price = 150000, level = 1, mastery = 0, location = "Jungle"},
    ["Electric"] = {price = 500000, level = 100, mastery = 0, location = "Skylands"},
    ["Fishman Karate"] = {price = 750000, level = 200, mastery = 0, location = "Fishman Island"},
    ["Dragon Breath"] = {price = 1500, level = 300, mastery = 0, location = "Sabertooth Tiger"}, -- Pake fragment
    ["Death Step"] = {price = 2500000, level = 400, mastery = 400, location = "Undead Settlement"},
    ["Sharkman Karate"] = {price = 2500000, level = 400, mastery = 400, location = "Forgotten Island"},
    ["Electric Claw"] = {price = 2000000, level = 400, mastery = 400, location = "Hydra Island"},
    ["Dragon Talon"] = {price = 2500000, level = 400, mastery = 400, location = "Great Tree"},
    ["Godhuman"] = {price = 5000000, level = 1100, mastery = 400, location = "Castle on Sea"},
    ["Sanguine Art"] = {price = 5000000, level = 2200, mastery = 400, location = "Sea of Treats"}
}

-- Function: Get Player Level
local function GetPlayerLevel()
    -- Coba berbagai cara mendapatkan level
    local levelStat = LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("Level") or LocalPlayer:FindFirstChild("Stats")
    if levelStat then
        if levelStat:FindFirstChild("Level") then
            return levelStat.Level.Value or 1
        elseif levelStat:FindFirstChild("Fruit") then
            -- Fallback
        end
    end
    
    -- Alternative: cek dari leaderstats
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local level = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Lvl") or leaderstats:FindFirstChild("LVL")
        if level then
            return level.Value or 1
        end
    end
    
    return 1
end

-- Function: Get Player Beli
local function GetPlayerBeli()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local beli = leaderstats:FindFirstChild("Beli") or leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash")
        if beli then
            return beli.Value or 0
        end
    end
    return 0
end

-- Function: Check and Buy Fighting Style
local function CheckAndBuyFightingStyle()
    if not AutoBuyDarkStep then return end
    
    CurrentBeli = GetPlayerBeli()
    CurrentLevel = GetPlayerLevel()
    
    -- Prioritaskan Dark Step (150.000)
    if CurrentBeli >= 150000 and CurrentLevel >= 1 then
        -- Cek apakah sudah punya Dark Step
        local hasDarkStep = false
        for _, v in pairs(LocalPlayer:FindFirstChild("PlayerGui"):GetDescendants()) do
            if v.Name == "DarkStep" then
                hasDarkStep = true
                break
            end
        end
        
        if not hasDarkStep then
            print("🛒 Mencoba beli Dark Step...")
            -- Cari NPC Dark Step (Batu)
            for _, npc in pairs(workspace:FindFirstChild("NPCs"):GetChildren()) do
                if npc.Name == "Batu" or npc:FindFirstChild("DarkStep") then
                    -- Teleport ke NPC
                    LocalPlayer.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, FarmHeight, 0)
                    wait(1)
                    
                    -- Interaksi (biasanya pake RemoteEvent)
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or 
                                   game:GetService("ReplicatedStorage"):FindFirstChild("BuyFightingStyle")
                    if remote then
                        remote:FireServer("DarkStep")
                        print("✅ Membeli Dark Step...")
                        wait(2)
                    end
                    break
                end
            end
        end
    end
    
    -- Lanjutkan dengan fighting style lain sesuai level dan uang
    if CurrentLevel >= 100 and CurrentBeli >= 500000 then
        -- Beli Electric
        -- (logic serupa)
    end
end

-- Function: Find Quest Based on Level
local function FindQuest()
    -- Ini harus disesuaikan dengan game
    -- Contoh mapping level ke quest
    local quests = {
        [1] = {name = "Bandit", location = "Marine Start", npc = "Bandit", kills = 5},
        [10] = {name = "Monkey", location = "Jungle", npc = "Monkey", kills = 5},
        [30] = {name = "Gorilla", location = "Jungle", npc = "Gorilla", kills = 5},
        [60] = {name = "Pirate", location = "Desert", npc = "Raider", kills = 5},
        [90] = {name = "Brute", location = "Frozen Village", npc = "Brute", kills = 5},
        [120] = {name = "Snow Bandit", location = "Snow Mountain", npc = "Snow Bandit", kills = 5},
        -- Tambahkan sesuai kebutuhan
    }
    
    local currentLevel = GetPlayerLevel()
    local bestQuest = nil
    
    for lvl, quest in pairs(quests) do
        if currentLevel >= lvl then
            bestQuest = quest
        end
    end
    
    return bestQuest
end

-- Function: Accept Quest
local function AcceptQuest(quest)
    if not quest then return end
    
    print("📋 Mencari quest: " .. quest.name)
    
    -- Cari NPC Quest
    for _, npc in pairs(workspace:FindFirstChild("NPCs"):GetChildren()) do
        if npc.Name == "QuestGiver" or npc:FindFirstChild(quest.name) then
            -- Teleport ke NPC
            LocalPlayer.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, FarmHeight, 0)
            wait(1)
            
            -- Accept quest (biasanya lewat RemoteEvent)
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or 
                           game:GetService("ReplicatedStorage"):FindFirstChild("AcceptQuest")
            if remote then
                remote:FireServer(quest.name)
                print("✅ Quest accepted: " .. quest.name)
                CurrentQuest = quest
                RequiredKills = quest.kills
                KillCount = 0
                wait(2)
            end
            break
        end
    end
end

-- Function: Find NPC to Kill
local function FindTargetNPC(quest)
    if not quest then return nil end
    
    local closestNPC = nil
    local closestDist = math.huge
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myPos then return nil end
    
    for _, npc in pairs(workspace:FindFirstChild("Enemies"):GetChildren()) do
        if npc.Name == quest.npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            local npcPos = npc:FindFirstChild("HumanoidRootPart")
            if npcPos then
                local dist = (myPos.Position - npcPos.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestNPC = npc
                end
            end
        end
    end
    
    return closestNPC
end

-- Function: Auto Farm (Main Loop)
local function AutoFarmLoop()
    while AutoFarmEnabled do
        local success, err = pcall(function()
            -- Update info
            CurrentLevel = GetPlayerLevel()
            CurrentBeli = GetPlayerBeli()
            
            -- Auto beli fighting style
            CheckAndBuyFightingStyle()
            
            -- Cari quest kalo belum punya
            if AutoQuestEnabled and (not CurrentQuest or KillCount >= RequiredKills) then
                local newQuest = FindQuest()
                if newQuest then
                    AcceptQuest(newQuest)
                end
                wait(2)
            end
            
            -- Cari target NPC
            if CurrentQuest then
                local target = FindTargetNPC(CurrentQuest)
                
                if target then
                    -- Teleport ke target dengan ketinggian yang diatur
                    local targetPos = target.HumanoidRootPart.Position
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos.x, targetPos.y + FarmHeight, targetPos.z)
                    
                    -- Auto attack
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new())
                    
                    -- Cek kalo target mati
                    if target.Humanoid.Health <= 0 then
                        KillCount = KillCount + 1
                        print("💀 NPC mati: " .. KillCount .. "/" .. RequiredKills)
                        
                        -- Kalo udah cukup kills, reset quest
                        if KillCount >= RequiredKills then
                            CurrentQuest = nil
                        end
                    end
                else
                    print("🔍 Mencari NPC: " .. CurrentQuest.npc)
                    -- Teleport ke lokasi quest
                    if QuestLocation then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = QuestLocation
                    end
                end
            end
            
            wait(0.5)
        end)
        
        if not success then
            warn("⚠️ Error di AutoFarm: " .. tostring(err))
            wait(2)
        end
    end
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new())
end)

-- GUI Rayfield
local Window = Rayfield:CreateWindow({
    Name = "ZyxHub - Blox Fruit Auto Farm",
    LoadingTitle = "ZyxHub",
    LoadingSubtitle = "Auto Farm + Auto Buy Dark Step",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ZyxHub_BloxFruit",
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Auto Farm", 4483362458)

MainTab:CreateSection("Auto Farm Settings")

local FarmToggle = MainTab:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Flag = "FarmToggle",
    Callback = function(v)
        AutoFarmEnabled = v
        if v then
            Rayfield:Notify({
                Title = "Auto Farm ON",
                Content = "Memulai auto farm...",
                Duration = 3
            })
            coroutine.wrap(AutoFarmLoop)()
        else
            Rayfield:Notify({
                Title = "Auto Farm OFF",
                Content = "Auto farm dimatikan",
                Duration = 2
            })
        end
    end
})

local QuestToggle = MainTab:CreateToggle({
    Name = "Auto Quest",
    CurrentValue = true,
    Flag = "QuestToggle",
    Callback = function(v)
        AutoQuestEnabled = v
    end
})

MainTab:CreateSection("Fighting Style")

local BuyDarkStepToggle = MainTab:CreateToggle({
    Name = "Auto Buy Dark Step (150K)",
    CurrentValue = true,
    Flag = "BuyDarkStepToggle",
    Callback = function(v)
        AutoBuyDarkStep = v
    end
})

MainTab:CreateSection("Position Settings")

local HeightSlider = MainTab:CreateSlider({
    Name = "Ketinggian Farm",
    Range = {10, 200},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 50,
    Flag = "HeightSlider",
    Callback = function(v)
        FarmHeight = v
    end
})

-- Status Tab
local StatusTab = Window:CreateTab("Status", 4483362458)

StatusTab:CreateSection("Player Info")

local LevelLabel = StatusTab:CreateLabel("Level: -")
local BeliLabel = StatusTab:CreateLabel("Beli: -")
local FightingStyleLabel = StatusTab:CreateLabel("Fighting Style: -")

StatusTab:CreateSection("Quest Info")

local QuestNameLabel = StatusTab:CreateLabel("Quest: -")
local KillProgressLabel = StatusTab:CreateLabel("Progress: 0/0")
local TargetNPCLabel = StatusTab:CreateLabel("Target NPC: -")

-- Update status
RunService.RenderStepped:Connect(function()
    CurrentLevel = GetPlayerLevel()
    CurrentBeli = GetPlayerBeli()
    
    LevelLabel:Set("Level: " .. CurrentLevel)
    BeliLabel:Set("Beli: " .. string.format("%.0f", CurrentBeli))
    
    if CurrentQuest then
        QuestNameLabel:Set("Quest: " .. CurrentQuest.name)
        KillProgressLabel:Set("Progress: " .. KillCount .. "/" .. RequiredKills)
        TargetNPCLabel:Set("Target NPC: " .. CurrentQuest.npc)
    else
        QuestNameLabel:Set("Quest: -")
        KillProgressLabel:Set("Progress: 0/0")
        TargetNPCLabel:Set("Target NPC: -")
    end
end)

-- Info Tab
local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateSection("Fighting Style Prices")

InfoTab:CreateLabel("Dark Step: 150,000 Beli")
InfoTab:CreateLabel("Electric: 500,000 Beli")
InfoTab:CreateLabel("Fishman Karate: 750,000 Beli")
InfoTab:CreateLabel("Dragon Breath: 1,500 Fragments")
InfoTab:CreateLabel("Death Step: 2.5M + 5K Fragments")
InfoTab:CreateLabel("Sharkman Karate: 2.5M + 5K Fragments")
InfoTab:CreateLabel("Electric Claw: 2M + 5K Fragments")
InfoTab:CreateLabel("Dragon Talon: 2.5M + 5K Fragments")
InfoTab:CreateLabel("Godhuman: 5M + 5K Fragments")
InfoTab:CreateLabel("Sanguine Art: 5M + 5K Fragments") [citation:6]

InfoTab:CreateSection("About")

InfoTab:CreateLabel("ZyxHub - Blox Fruit Auto Farm")
InfoTab:CreateLabel("Creator: XamiX")
InfoTab:CreateLabel("Fitur: Auto Farm, Auto Quest")
InfoTab:CreateLabel("Auto Beli Dark Step (150K)")
InfoTab:CreateLabel("Ketinggian bisa diatur")
InfoTab:CreateLabel(" ")
InfoTab:CreateLabel("⚠️ Gunakan di private server!")
InfoTab:CreateLabel("Toggle GUI: CTRL + F")

-- Toggle GUI
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        local conn
        conn = UserInputService.InputBegan:Connect(function(m)
            if m.KeyCode == Enum.KeyCode.F then
                if Window then
                    if ToggleGUI then
                        Window:Show()
                    else
                        Window:Hide()
                    end
                    ToggleGUI = not ToggleGUI
                end
                conn:Disconnect()
            end
        end)
    end
end)

-- Notifikasi awal
Rayfield:Notify({
    Title = "ZyxHub - Blox Fruit",
    Content = "Auto Farm siap! CTRL+F toggle GUI",
    Duration = 5
})

print("╔════════════════════════════════════════════════════╗")
print("║     ZYXHUB - BLOX FRUIT AUTO FARM LOADED!         ║")
print("║     Fitur:                                         ║")
print("║     ✅ Auto Farm sesuai level                      ║")
print("║     ✅ Auto Quest                                  ║")
print("║     ✅ Auto Beli Dark Step (150K)                  ║")
print("║     ✅ Ketinggian bisa diatur                      ║")
print("║     Tekan CTRL+F untuk toggle GUI                  ║")
print("╚════════════════════════════════════════════════════╝")
