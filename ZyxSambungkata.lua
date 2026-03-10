-- SAFE LOAD RAYFIELD
local Rayfield
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if success and result then
    Rayfield = result
else
    warn("Rayfield gagal diload!")
    return
end


-- PLAYER
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


-- FUNCTION CARI TEXTBOX
local function FindTextBox()
    for _,v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v:IsA("TextBox") and v.Visible then
            return v
        end
    end
end


-- FUNCTION CARI LAST WORD
local function FindLastWord()
    for _,v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") then
            if v.Text and #v.Text > 1 and not v.Text:match("[%d%p]") then
                return v.Text
            end
        end
    end
end


-- WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Zyx-GPT Sambung Kata Ultimate",
    LoadingTitle = "Loading Script",
    LoadingSubtitle = "by XamiX",
    ConfigurationSaving = {
        Enabled = false
    }
})

local Tab = Window:CreateTab("Main")


-- STATUS
local isRunning = false


Tab:CreateButton({
    Name = "▶ Start Auto Sambung",
    Callback = function()

        if isRunning then return end
        isRunning = true

        task.spawn(function()

            local textBox = FindTextBox()

            if not textBox then
                warn("TextBox tidak ditemukan")
                isRunning = false
                return
            end

            while isRunning do
                pcall(function()

                    local lastWord = FindLastWord()

                    if lastWord then

                        local lastChar = string.sub(lastWord,-1):upper()

                        if WordDatabase[lastChar] then
                            local words = WordDatabase[lastChar]
                            local word = words[math.random(1,#words)]

                            -- typing simulation
                            for i=1,#word do
                                textBox.Text = word:sub(1,i)
                                task.wait(0.04)
                            end

                            task.wait(0.1)

                            game:GetService("VirtualInputManager"):SendKeyEvent(true,"Return",false,game)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false,"Return",false,game)

                        end

                    end

                end)

                task.wait(1.5)

            end

        end)

    end
})


Tab:CreateButton({
    Name = "⏹ Stop",
    Callback = function()
        isRunning = false
    end
})
