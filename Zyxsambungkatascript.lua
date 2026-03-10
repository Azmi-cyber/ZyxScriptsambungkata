--[[
    Zyx-GPT Auto Sambung Kata
    Executor: Velocity (Level 8)
    UI: Rayfield
    Fitur:
    - UI dengan 3 Tab (Main, Settings, Info)
    - Auto detect huruf terakhir dari PlayerGui
    - Database kata dari KBBI (lokal + eksternal)
    - Prioritas khusus huruf X
    - Auto typing dengan VirtualInputManager
    - Typo simulation 20%
    - Auto Enter
    - Loop delay 1.2 - 1.8 detik
    - Error handling dengan pcall()
]]

-- ============== LOAD RAYFIELD UI LIBRARY ==============
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ============== VARIABEL GLOBAL ==============
local isRunning = false
local typingDelay = 0.05 -- Delay antar huruf (dalam detik)
local loopDelayMin = 1.2
local loopDelayMax = 1.8

-- ============== DATABASE KATA SUPER LENGKAP ==============
local WordDatabase = {
    -- Database inti (contoh untuk A-D, sisanya akan di-load dari eksternal)
    A = {"abjad", "absen", "acara", "acuh", "adalah", "adil", "aduh", "agama", "agar", "agen", "agresif", "air", "ajaib", "akar", "akhir", "akhlak", "aksi", "aku", "alam", "alat", "aliran", "allah", "alone", "aman", "amat", "anak", "andai", "anggur", "anjing", "antar", "apa", "api", "apik", "arah", "arang", "arca", "area", "aren", "argo", "arif", "arti", "arus", "asah", "asap", "asia", "asli", "asmara", "aspal", "asri", "astaga", "asuhan", "atau", "atap", "atas", "ateis", "atlet", "atmosfer", "atom", "atap", "aula", "awak", "awal", "awam", "awan", "awas", "awat", "awet", "axis", "ayam", "ayat", "ayo", "azab", "azam", "azas"},
    B = {"baba", "badai", "badan", "badut", "bagus", "bahagia", "bahaya", "bahan", "bahas", "bahkan", "baik", "baju", "bak", "bakar", "bakat", "baki", "bako", "bakso", "bakteri", "balas", "balik", "bambu", "ban", "banci", "bandar", "banget", "bangsa", "bangun", "banjir", "bank", "bantal", "banyak", "bapak", "bar", "bara", "barang", "barat", "barbar", "barel", "baru", "basah", "basmi", "basuh", "bata", "batas", "batu", "bau", "bawa", "bayam", "bayar", "bayi", "bazir", "bea", "bebas", "bebek", "beban", "bebas", "beber", "bebek", "bebel", "beda", "bedah", "bedak", "bedegong", "bego", "bekal", "bekas", "beku", "belah", "belai", "belajar", "belakang", "belanja", "belas", "belati", "beli", "belok", "bemban", "bencana", "benda", "bendera", "bengis", "benih", "benjol", "bensin", "bentuk", "benua", "berantas", "beras", "berat", "bercak", "beri", "berita", "berkas", "beruang", "besan", "besar", "besi", "besok", "betah", "betina", "beton", "biadab", "bias", "biasa", "bibir", "bibit", "bicara", "bidaah", "bidan", "bidang", "biji", "bikin", "bila", "bilang", "biliar", "bimasakti", "bimbing", "bin", "binasa", "binatang", "bincang", "biodata", "bipolar", "birahi", "biru", "bis", "bisa", "bisik", "bismillah", "bisul", "bodoh", "bohlam", "bohong", "boikot", "bokep", "boker", "bola", "boleh", "bolong", "bomb", "bon", "boncos", "boneka", "bongkar", "bonus", "bopeng", "bor", "borok", "boros", "bos", "bosan", "botak", "botol", "boyong", "buah", "buang", "buas", "buat", "budak", "budaya", "bugar", "buka", "bukan", "buku", "bulan", "bulat", "bulu", "bumbu", "bumi", "bunuh", "bunyi", "bupati", "buru", "bus", "busuk", "busur", "buta", "butik", "butuh", "buyar", "buzzer"},
    C = {"cabe", "cabul", "cacah", "cacat", "caci", "cacian", "cadu", "cagak", "cagar", "cakap", "cakar", "cakep", "cakram", "cakrawala", "cakupan", "caleg", "calon", "camar", "camat", "cambuk", "camilan", "campak", "campur", "camtik", "candi", "candu", "cangcut", "canggih", "cangkir", "cangkul", "cantik", "capaian", "capai", "capek", "capik", "cari", "casis", "cat", "cata", "catat", "catur", "cawat", "cawu", "ceban", "cebong", "cebur", "cecar", "cecer", "cedera", "cegah", "ceguk", "cekah", "cekak", "cekal", "cekatan", "cekcok", "cekidot", "cekik", "ceking", "ceklis", "cekot", "celah", "celaka", "celana", "celat", "cele", "celek", "celemek", "celetuk", "celinguk", "celomes", "celup", "celurit", "cemas", "cembung", "cemooh", "cempeng", "cemplung", "cempreng", "cendera", "cengeng", "cengil", "cengkih", "cengli", "centil", "cepat", "ceper", "ceplas", "ceples", "ceplok", "ceplos", "cepu", "cepuk", "cerah", "cerai", "ceramah", "cerdas", "cerdik", "cere", "cerewet", "cergas", "ceria", "cerita", "ceriwis", "cerna", "ceroboh", "cerobong", "cerpen", "cetak", "cetar", "cetek", "cethar", "cethil", "cewek", "ciak", "cialat", "ciamik", "cianjur", "ciap", "cicak", "cicil", "cicip", "ciduk", "cigak", "cikrak", "cikut", "cili", "cilik", "ciluk", "cimol", "cina", "cincang", "cincau", "cincin", "cindil", "cinta", "cipir", "cipo", "cipok", "ciprat", "ciri", "cis", "citra", "ciuman", "cobaan", "cobek", "coblos", "cocok", "codet", "cokelat", "coklat", "colak", "colek", "coleng", "colok", "comberan", "combi", "combong", "comeback", "comel", "comot", "compeng", "compes", "compoh", "compreng", "comro", "condong", "conek", "congek", "congo", "congok", "congor", "contek", "conteng", "contoh", "copas", "copet", "copot", "corak", "corek", "coreng", "coret", "coro", "corong", "coto", "cowok", "coy", "criwis", "cua", "cuaca", "cuak", "cuan", "cuanki", "cuap", "cuar", "cuat", "cubit", "cuca", "cucak", "cucu", "cucuh", "cucuk", "cucur", "cucut", "cuka", "cukai", "cukil", "cukimay", "cukin", "cukong", "cuku", "cukup", "cula", "culik", "culun", "cuma", "cumbu", "cumi", "cun", "cung", "cungap", "cungkil", "cungkring", "cunia", "cup", "cupai", "cupar", "cupet", "cuping", "cuplak", "cuplik", "cuprat", "cuput", "curah", "curai", "curam", "curang", "curhat", "curi", "curiga", "curing", "curna", "curnal", "cus", "cut", "cutbrai", "cute"},
    D = {"da", "dab", "dada", "dadah", "dadak", "dadan", "dadap", "dadar", "dadih", "dading", "dadu", "daduh", "daeng", "daerah", "daftar", "daging", "dagu", "dah", "dahaga", "dahak", "daham", "dahan", "dahana", "dahani", "dahap", "dahar", "dahi", "dahiat", "dahina", "dahlia", "dahriah", "dahsyat", "dahulu", "dai", "daidan", "daif", "daim", "daiman", "daing", "dait", "dajal", "daka", "dakapan", "dakda", "dakik", "dakocan", "dakon", "daksa", "daksina", "daktil", "daktilitis", "daku", "dakwa", "dakwah", "dal", "dalal", "dalalat", "dalam", "dalang", "daldaru", "dalem", "dalfin", "dalih", "dalil", "dalton", "dalu", "daluang", "dam", "damah", "damai", "damak", "damal", "damar", "damaru", "damas", "damat", "damba", "dambin", "dambir", "dame", "damen", "dami", "damik", "damotin", "dan", "dana", "danau", "danawa", "danda", "dandan", "dandang", "dandanan", "dandapati", "dandi", "dang", "dangai", "dangar", "dangau", "dangdut", "dange", "danghyang", "dangir", "dangka", "dangkal", "dangkap", "dangkar", "dangkung", "danguk", "dansa", "danta", "danuh", "danur", "danyang", "dap", "dapa", "dapar", "dapat", "dapra", "dapur", "dar", "dara", "darab", "darah", "daras", "darat", "darau", "dargah", "dari", "dariyah", "darjat", "darji", "darma", "darmabakti", "darmakelana", "darmasiswa", "darmatirta", "darmawisata", "darun", "darurat", "darus", "darwis", "das", "dasa", "dasalomba", "dasar", "dasarian", "dasasila", "dasatitah", "dasi", "dasin", "daster", "dasun", "data", "datang", "datar", "datas", "dateh", "datil", "dativ", "datuk", "datung", "dauk", "daulat", "daun", "daur", "dawai", "dawan", "dawat", "dawet", "daya", "dayah", "dayang", "dayu", "dayuh", "dayuk", "dayung", "dayus"},
    -- Database huruf E-Z dan tambahan akan di-load dari eksternal
}

-- Kata khusus untuk huruf X (prioritas)
local xWords = {"xenon", "xenofobia", "xerografi", "xilem", "xilofon", "xiloid", "xilol", "xilologi", "xim", "xincang", "xio", "xokai", "xosa", "xray", "xu", "xylena", "xylidin", "xylitol", "xylograf", "xyloid", "xylol", "xylologi", "xylometer", "xylosa", "xylotoksin"}

-- ============== LOAD DATABASE EKSTERNAL ==============
local function LoadExternalDatabase()
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/XamiX/SeaZone/main/kbbi_database.lua")
    end)
    if success and result then
        local extraDB = loadstring(result)()
        if type(extraDB) == "table" then
            for letter, words in pairs(extraDB) do
                if not WordDatabase[letter] then
                    WordDatabase[letter] = {}
                end
                for _, word in ipairs(words) do
                    table.insert(WordDatabase[letter], word)
                end
            end
        end
    end
end
LoadExternalDatabase()

-- ============== FUNGSI UTAMA ==============

-- Fungsi untuk mendapatkan kata berdasarkan huruf awal
local function GetWordByFirstLetter(firstLetter)
    firstLetter = firstLetter:upper()
    if firstLetter == "X" then
        return xWords[math.random(1, #xWords)]
    end
    if WordDatabase[firstLetter] and #WordDatabase[firstLetter] > 0 then
        return WordDatabase[firstLetter][math.random(1, #WordDatabase[firstLetter])]
    end
    return nil
end

-- Fungsi untuk mensimulasi typo
local function SimulateTypo(word)
    if #word < 3 then return word end
    local typoType = math.random(1, 3)
    local typoWord = word
    if typoType == 1 then
        local pos = math.random(1, #word - 1)
        typoWord = word:sub(1, pos-1) .. word:sub(pos+1, pos+1) .. word:sub(pos, pos) .. word:sub(pos+2)
    elseif typoType == 2 then
        local pos = math.random(1, #word)
        typoWord = word:sub(1, pos-1) .. word:sub(pos+1)
    else
        local pos = math.random(1, #word)
        typoWord = word:sub(1, pos) .. word:sub(pos, pos) .. word:sub(pos+1)
    end
    return typoWord
end

-- Fungsi untuk mengetik kata menggunakan VirtualInputManager
local function TypeWord(word)
    local VIM = game:GetService("VirtualInputManager")
    -- Typo simulation (20% chance)
    if math.random(1, 100) <= 20 then
        local typoWord = SimulateTypo(word)
        -- Ketik typo
        for i = 1, #typoWord do
            VIM:SendKeyEvent(true, string.byte(string.sub(typoWord, i, i)):byte(), false, nil)
            task.wait(typingDelay)
            VIM:SendKeyEvent(false, string.byte(string.sub(typoWord, i, i)):byte(), false, nil)
        end
        task.wait(0.3)
        -- Hapus typo
        for i = 1, #typoWord do
            VIM:SendKeyEvent(true, Enum.KeyCode.Backspace, false, nil)
            task.wait(0.03)
            VIM:SendKeyEvent(false, Enum.KeyCode.Backspace, false, nil)
        end
        task.wait(0.1)
    end
    -- Ketik kata yang benar
    for i = 1, #word do
        VIM:SendKeyEvent(true, string.byte(string.sub(word, i, i)):byte(), false, nil)
        task.wait(typingDelay)
        VIM:SendKeyEvent(false, string.byte(string.sub(word, i, i)):byte(), false, nil)
    end
    -- Tekan Enter
    task.wait(0.1)
    VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
    VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
end

-- Fungsi untuk mendapatkan huruf terakhir dari PlayerGui
local function GetLastLetterFromGame()
    local player = game:GetService("Players").LocalPlayer
    if not player then return nil end
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    local lastLetter = nil
    local success, result = pcall(function()
        for _, v in ipairs(playerGui:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text and #v.Text > 0 then
                local text = v.Text
                -- Ambil karakter terakhir, abaikan spasi atau karakter non-huruf
                local lastChar = string.sub(text, -1)
                if lastChar:match("%a") then -- Hanya huruf
                    lastLetter = lastChar
                    break
                end
            end
        end
    end)
    if success then
        return lastLetter
    else
        return nil
    end
end

-- ============== UI RAYFIELD ==============
local Window = Rayfield:CreateWindow({
    Name = "Zyx-GPT Sambung Kata",
    Icon = 0,
    LoadingTitle = "Zyx-GPT V1.0 - Sea Zone",
    LoadingSubtitle = "by XamiX",
    Theme = "Ocean",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = { Enabled = true, FolderName = "ZyxGPT_SambungKata", FileName = "Config" },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Tab Main
local MainTab = Window:CreateTab("Main", nil)
local MainSection = MainTab:CreateSection("Kontrol Utama")

-- Log aktivitas
local logLabel = MainTab:CreateLabel("Menunggu perintah...")

-- Tombol Start
local StartButton = MainTab:CreateButton({
    Name = "▶️ Start Auto Sambung Kata",
    Callback = function()
        if isRunning then
            Rayfield:Notify({ Title = "Zyx-GPT", Content = "Auto play sudah berjalan!", Duration = 2 })
            return
        end
        isRunning = true
        Rayfield:Notify({ Title = "Zyx-GPT", Content = "Auto play dimulai!", Duration = 2 })
        logLabel:Set("✅ Auto play aktif, mencari huruf...")

        -- Main loop
        spawn(function()
            while isRunning do
                local success, err = pcall(function()
                    local lastLetter = GetLastLetterFromGame()
                    if lastLetter then
                        local wordToType = GetWordByFirstLetter(lastLetter)
                        if wordToType then
                            logLabel:Set("✏️ Mengetik: " .. wordToType .. " (dari huruf: " .. lastLetter .. ")")
                            TypeWord(wordToType)
                        else
                            logLabel:Set("⚠️ Tidak ada kata untuk huruf: " .. lastLetter)
                        end
                    else
                        logLabel:Set("⏳ Tidak menemukan huruf, akan scan lagi...")
                    end
                end)
                if not success then
                    logLabel:Set("❌ Error dalam loop: " .. tostring(err))
                end
                -- Loop delay random antara 1.2 - 1.8 detik
                local loopDelay = math.random(loopDelayMin * 10, loopDelayMax * 10) / 10
                task.wait(loopDelay)
            end
        end)
    end
})

-- Tombol Stop
local StopButton = MainTab:CreateButton({
    Name = "⏹️ Stop Auto Sambung Kata",
    Callback = function()
        isRunning = false
        logLabel:Set("⏹️ Auto play dihentikan.")
        Rayfield:Notify({ Title = "Zyx-GPT", Content = "Auto play dihentikan.", Duration = 2 })
    end
})

-- Tab Settings
local SettingsTab = Window:CreateTab("Settings", nil)
local SettingsSection = SettingsTab:CreateSection("Pengaturan")

-- Slider untuk mengatur kecepatan mengetik
local SpeedSlider = SettingsTab:CreateSlider({
    Name = "Kecepatan Mengetik (detik/huruf)",
    Range = {0.02, 0.1},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = typingDelay,
    Flag = "TypingSpeed",
    Callback = function(value)
        typingDelay = value
    end
})

-- Tab Info
local InfoTab = Window:CreateTab("Info", nil)
local InfoSection = InfoTab:CreateSection("Tentang Script")

InfoTab:CreateParagraph({
    Title = "Zyx-GPT Sambung Kata",
    Content = "✓ Auto detect huruf terakhir dari PlayerGui\n✓ Database kata dari KBBI + eksternal\n✓ Khusus huruf X (prioritas)\n✓ Typo simulation 20%\n✓ Auto typing dengan VirtualInputManager\n✓ Auto Enter\n✓ Loop delay 1.2 - 1.8 detik"
})

InfoTab:CreateParagraph({
    Title = "Cara Pakai",
    Content = "1. Buka game Sambung Kata\n2. Inject script dengan Velocity\n3. Klik 'Start Auto Sambung Kata'\n4. Script akan otomatis membaca huruf dan mengetik"
})

-- Notifikasi awal
Rayfield:Notify({
    Title = "Zyx-GPT Sambung Kata",
    Content = "Script siap digunakan! Klik Start untuk memulai.",
    Duration = 5
})
