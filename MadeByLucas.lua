local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=title or "MusicHub", Text=text or "", Duration=dur or 4})
    end)
end

local function hasFS()
    return writefile and readfile and makefolder and listfiles and delfile
end

local FSROOT = "MusicHub"
local FSTRACKS = FSROOT.."/tracks"

local function fsinit()
    if not hasFS() then return end
    if not isfolder or not isfolder(FSROOT) then pcall(makefolder, FSROOT) end
    if not isfolder or not isfolder(FSTRACKS) then pcall(makefolder, FSTRACKS) end
end
local function fswritejson(path, tbl)
    if not hasFS() then return end
    local s = HttpService:JSONEncode(tbl)
    writefile(path, s)
end
local function fsreadjson(path)
    if not hasFS() then return nil end
    if not isfile or not isfile(path) then return nil end
    local s = readfile(path)
    return HttpService:JSONDecode(s)
end
local function fslist(dir)
    if not hasFS() then return {} end
    local ok, files = pcall(listfiles, dir)
    return ok and files or {}
end
local function fsdel(path)
    if hasFS() then pcall(delfile, path) end
end
local function fsdelfolder(path)
    if hasFS() then pcall(delfolder, path) end
end
fsinit()

local Tracks = {}
local function now() return os.time() end
local function loadTracks()
    Tracks = {}
    if hasFS() then
        for _, f in ipairs(fslist(FSTRACKS)) do
            if f:find("%.json$") then
                local t = fsreadjson(f)
                if t and t.name and t.id then
                    Tracks[tostring(t.id)] = t
                end
            end
        end
    end
end
loadTracks()
local function saveTrack(name, id)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$","")
    id = tostring(id or ""):gsub("^%s+", ""):gsub("%s+$","")
    if name == "" then name = "Música "..now() end
    if id == "" then return false, "SoundId inválido" end
    local data = {name=name, id=id, createdAt=now()}
    Tracks[id] = data
    if hasFS() then
        fswritejson(FSTRACKS.."/"..id..".json", data)
    end
    return true
end
local function deleteTrack(id)
    Tracks[id] = nil
    if hasFS() then
        fsdel(FSTRACKS.."/"..id..".json")
    end
end
local function deleteAll()
    Tracks = {}
    if hasFS() then
        fsdelfolder(FSTRACKS)
        fsinit()
    end
end

local Player = {
    sound = nil,
    key = nil,
    loop = false,
    playing = false,
    volume = 0.7
}
local function stopMusic()
    if Player.sound then
        pcall(function() Player.sound:Destroy() end)
        Player.sound = nil
        Player.key = nil
        Player.playing = false
    end
end
local function playMusic(id)
    stopMusic()
    local info = Tracks[id]
    if not info then return end
    local s = Instance.new("Sound", SoundService)
    s.SoundId = "rbxassetid://"..info.id
    s.Volume = Player.volume
    s.Looped = Player.loop
    s.Name = "MusicHub_Current"
    s:Play()
    Player.sound = s
    Player.key = id
    Player.playing = true
    s.Ended:Connect(function()
        if Player.loop then
            s.TimePosition = 0
            s:Play()
            Player.playing = true
        else
            Player.playing = false
        end
    end)
end
local function pauseMusic()
    if Player.sound then Player.sound:Pause() Player.playing = false end
end
local function resumeMusic()
    if Player.sound then Player.sound:Play() Player.playing = true end
end
local function setVolume(v)
    v = math.clamp(tonumber(v) or 0.7, 0, 1)
    Player.volume = v
    if Player.sound then Player.sound.Volume = Player.volume end
end

local function makeCorner(parent, rad)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, rad or 10)
end

local function makeButton(parent, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 148, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(72, 120, 220)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    makeCorner(b, 10)
    b.Parent = parent
    return b
end

local function makeInput(parent, ph)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0.5, -10, 0, 38)
    tb.BackgroundColor3 = Color3.fromRGB(36, 48, 78)
    tb.PlaceholderText = ph
    tb.Text = ""
    tb.ClearTextOnFocus = false
    tb.TextColor3 = Color3.fromRGB(230, 240, 255)
    tb.PlaceholderColor3 = Color3.fromRGB(170, 180, 210)
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 15
    makeCorner(tb, 10)
    tb.Parent = parent
    return tb
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "MusicHubUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleOrb = Instance.new("Frame", Gui)
ToggleOrb.Name = "ToggleOrb"
ToggleOrb.Size = UDim2.new(0, 70, 0, 70)
ToggleOrb.Position = UDim2.new(0.065, 0, 0.59, 0)
ToggleOrb.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleOrb.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
ToggleOrb.BorderSizePixel = 0
makeCorner(ToggleOrb, 35)

ToggleOrb.Active = true
ToggleOrb.Draggable = true

local OrbBtn = Instance.new("TextButton", ToggleOrb)
OrbBtn.Size = UDim2.new(1,0,1,0)
OrbBtn.BackgroundTransparency = 1
OrbBtn.Text = "🎵"
OrbBtn.TextScaled = false
OrbBtn.TextSize = 30
OrbBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
OrbBtn.Font = Enum.Font.GothamBold
OrbBtn.Position = UDim2.new(0,0,0,0)
OrbBtn.AnchorPoint = Vector2.new(0,0)

local Main = Instance.new("Frame", Gui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 880, 0, 440)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
makeCorner(Main, 16)
Main.ClipsDescendants = true

local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1, 0, 0, 56)
Top.Position = UDim2.new(0, 0, 0, 0)
Top.BackgroundColor3 = Color3.fromRGB(22, 28, 48)
Top.BorderSizePixel = 0
makeCorner(Top, 16)

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 32, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎵 MusicHub - By Lucas"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 32
Title.TextColor3 = Color3.fromRGB(180, 220, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

local BtnClose = Instance.new("TextButton", Top)
BtnClose.Size = UDim2.new(0, 44, 0, 44)
BtnClose.Position = UDim2.new(1, -54, 0, 6)
BtnClose.BackgroundTransparency = 1
BtnClose.Text = ""
BtnClose.TextScaled = true

local IconClose = Instance.new("TextLabel", BtnClose)
IconClose.Size = UDim2.new(1, 0, 1, 0)
IconClose.Position = UDim2.new(0, 0, 0, 0)
IconClose.BackgroundTransparency = 1
IconClose.Text = "✕"
IconClose.Font = Enum.Font.GothamBold
IconClose.TextSize = 36
IconClose.TextColor3 = Color3.fromRGB(255, 110, 110)
IconClose.TextScaled = true

local InputsFrame = Instance.new("Frame", Main)
InputsFrame.Size = UDim2.new(1, -64, 0, 38)
InputsFrame.Position = UDim2.new(0, 32, 0, 70)
InputsFrame.BackgroundTransparency = 1

local InputName = makeInput(InputsFrame, "Nome do arquivo (música)")
InputName.Position = UDim2.new(0, 0, 0, 0)
local InputSoundId = makeInput(InputsFrame, "SoundId (ex: 1847352423)")
InputSoundId.Position = UDim2.new(0.5, 10, 0, 0)

local BtnFrame = Instance.new("Frame", Main)
BtnFrame.Size = UDim2.new(1, -64, 0, 40)
BtnFrame.Position = UDim2.new(0, 32, 0, 120)
BtnFrame.BackgroundTransparency = 1

local BtnSave = makeButton(BtnFrame, "Salvar Música")
BtnSave.Position = UDim2.new(0, 0, 0, 0)
local BtnPreview = makeButton(BtnFrame, "▶ Pré-visualizar")
BtnPreview.Position = UDim2.new(0, 160, 0, 0)
local BtnLoop = makeButton(BtnFrame, "Loop: OFF")
BtnLoop.Size = UDim2.new(0, 120, 0, 38)
BtnLoop.Position = UDim2.new(0, 320, 0, 0)
local BtnPlayPause = makeButton(BtnFrame, "⏯️ / ⏸️")
BtnPlayPause.Size = UDim2.new(0, 120, 0, 38)
BtnPlayPause.Position = UDim2.new(0, 460, 0, 0)
local VolBox = Instance.new("TextBox", BtnFrame)
VolBox.Size = UDim2.new(0, 120, 0, 38)
VolBox.Position = UDim2.new(0, 600, 0, 0)
VolBox.BackgroundColor3 = Color3.fromRGB(36, 48, 78)
VolBox.Text = tostring(Player.volume)
VolBox.ClearTextOnFocus = false
VolBox.TextColor3 = Color3.fromRGB(230,240,255)
VolBox.Font = Enum.Font.GothamBold
VolBox.TextSize = 15
makeCorner(VolBox, 10)

local BtnComoUsar = makeButton(Main, "Como usar")
BtnComoUsar.Size = UDim2.new(0, 190, 0, 36.5)
BtnComoUsar.Position = UDim2.new(1, -428, 1, -38)
BtnComoUsar.BackgroundColor3 = Color3.fromRGB(72, 120, 220)
BtnComoUsar.TextSize = 15

local BtnDeleteAll = makeButton(Main, "APAGAR TUDO")
BtnDeleteAll.Size = UDim2.new(0, 190, 0, 36.5)
BtnDeleteAll.Position = UDim2.new(1, -220, 1, -38)
BtnDeleteAll.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
BtnDeleteAll.TextSize = 15

local TrackList = Instance.new("ScrollingFrame", Main)
TrackList.Name = "TrackList"
TrackList.Size = UDim2.new(1, -64, 0, 168)
TrackList.Position = UDim2.new(0, 32, 0, 170)
TrackList.BackgroundColor3 = Color3.fromRGB(20, 26, 46)
TrackList.BorderSizePixel = 0
TrackList.ScrollBarThickness = 8
makeCorner(TrackList, 10)
local tlay = Instance.new("UIListLayout", TrackList); tlay.Padding = UDim.new(0, 8)

local StatusFrame = Instance.new("Frame", Main)
StatusFrame.Size = UDim2.new(1, -64, 0, 52)
StatusFrame.Position = UDim2.new(0, 32, 1, -100)
StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 26, 46)
StatusFrame.BorderSizePixel = 0
makeCorner(StatusFrame, 14)

local msIcon = Instance.new("TextLabel", StatusFrame)
msIcon.Size = UDim2.new(0, 44, 1, 0)
msIcon.Position = UDim2.new(0, 8, 0, 0)
msIcon.BackgroundTransparency = 1
msIcon.Text = "🎵"
msIcon.TextColor3 = Color3.fromRGB(160,200,255)
msIcon.Font = Enum.Font.GothamBold
msIcon.TextSize = 32

local msTitle = Instance.new("TextLabel", StatusFrame)
msTitle.Size = UDim2.new(1, -180, 0, 26)
msTitle.Position = UDim2.new(0, 56, 0, 4)
msTitle.BackgroundTransparency = 1
msTitle.TextColor3 = Color3.fromRGB(225, 235, 255)
msTitle.Font = Enum.Font.GothamBold
msTitle.TextSize = 17
msTitle.TextXAlignment = Enum.TextXAlignment.Left

local msSub = Instance.new("TextLabel", StatusFrame)
msSub.Size = UDim2.new(1, -180, 0, 18)
msSub.Position = UDim2.new(0, 56, 0, 28)
msSub.BackgroundTransparency = 1
msSub.TextColor3 = Color3.fromRGB(130, 180, 255)
msSub.Font = Enum.Font.Gotham
msSub.TextSize = 13
msSub.TextXAlignment = Enum.TextXAlignment.Left

local msTime = Instance.new("TextLabel", StatusFrame)
msTime.Size = UDim2.new(0, 124, 0, 18)
msTime.Position = UDim2.new(1, -128, 0, 16)
msTime.BackgroundTransparency = 1
msTime.TextColor3 = Color3.fromRGB(180,220,255)
msTime.Font = Enum.Font.GothamBold
msTime.TextSize = 13
msTime.TextXAlignment = Enum.TextXAlignment.Right

local function refreshTrackList()
    for _, ch in ipairs(TrackList:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    for id, info in pairs(Tracks) do
        local row = Instance.new("Frame", TrackList)
        row.Size = UDim2.new(1, -8, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(28, 36, 62)
        row.BorderSizePixel = 0
        makeCorner(row, 8)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -180, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(210, 220, 255)
        lbl.Text = string.format("%s  |  id: %s", info.name, info.id)

        local btnPlay = Instance.new("TextButton", row)
        btnPlay.Size = UDim2.new(0, 54, 1, -2)
        btnPlay.Position = UDim2.new(1, -116, 0, 1)
        btnPlay.BackgroundColor3 = Color3.fromRGB(72, 120, 220)
        btnPlay.Text = "Ouvir"
        btnPlay.TextColor3 = Color3.fromRGB(255,255,255)
        btnPlay.Font = Enum.Font.GothamBold
        btnPlay.TextSize = 12
        makeCorner(btnPlay, 8)
        btnPlay.MouseButton1Click:Connect(function()
            playMusic(id)
        end)

        local btnDel = Instance.new("TextButton", row)
        btnDel.Size = UDim2.new(0, 54, 1, -2)
        btnDel.Position = UDim2.new(1, -58, 0, 1)
        btnDel.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
        btnDel.Text = "Del"
        btnDel.TextColor3 = Color3.fromRGB(240, 245, 255)
        btnDel.Font = Enum.Font.GothamBold
        btnDel.TextSize = 12
        makeCorner(btnDel, 8)
        btnDel.MouseButton1Click:Connect(function()
            deleteTrack(id)
            refreshTrackList()
        end)
    end
end
refreshTrackList()

BtnSave.MouseButton1Click:Connect(function()
    local ok, err = saveTrack(InputName.Text, InputSoundId.Text)
    if ok then
        notify("Músicas", "Música salva!", 3)
        refreshTrackList()
    else
        notify("Erro", err or "Falha ao salvar", 3)
    end
end)

BtnPreview.MouseButton1Click:Connect(function()
    local id = InputSoundId.Text
    if not id or id == "" then 
        notify("Erro", "Informe um SoundId.", 3) 
        return 
    end
    stopMusic()
    local s = Instance.new("Sound", SoundService)
    s.SoundId = "rbxassetid://"..id
    s.Volume = Player.volume
    s.Looped = false
    s.Name = "MusicHub_Preview"
    s:Play()
    Player.sound = s
    Player.key = "preview_"..id
    Player.playing = true
    msTitle.Text = "Pré-visualizar"
    msSub.Text = "ID: "..id
end)

RunService.RenderStepped:Connect(function()
    local key = Player.key
    local info = key and Tracks[key]

    local function updateTime()
        if Player.sound and Player.playing then
            local ok, pos = pcall(function() return Player.sound.TimePosition end)
            local ok2, len = pcall(function() return Player.sound.TimeLength end)
            pos = ok and pos or 0
            len = ok2 and len or 0
            if len <= 0 then
                msTime.Text = formatTime(pos).." / --:--"..(Player.loop and "   🔁" or "")
            else
                msTime.Text = formatTime(pos).." / "..formatTime(len)..(Player.loop and "   🔁" or "")
            end
        else
            msTime.Text = "--:-- / --:--"
        end
    end

    if info then
        msTitle.Text = info.name or "(?)"
        msSub.Text = "ID: "..(info.id or "")
        updateTime()
    elseif key and key:match("^preview_") then
        local id = key:match("^preview_(%d+)")
        msTitle.Text = "Pré-visualizar"
        msSub.Text = "ID: "..(id or "")
        updateTime()
    else
        msTitle.Text = "Nenhuma música tocando"
        msSub.Text = ""
        msTime.Text = ""
    end
end)

RunService.RenderStepped:Connect(function()
    local key = Player.key
    local info = key and Tracks[key]
    if info then
        msTitle.Text = info.name or "(?)"
        msSub.Text = "ID: "..(info.id or "")
        if Player.sound and Player.playing then
            local pos = Player.sound.TimePosition or 0
            local len = Player.sound.TimeLength or 0
            if len <= 0 then len = Player.sound.TimeLength end
            msTime.Text = formatTime(pos).." / "..((len > 0) and formatTime(len) or "--:--").."   "..(Player.loop and "🔁" or "")
        else
            msTime.Text = "--:-- / --:--"
        end
    elseif key and key:match("^preview_") then
        local id = key:match("^preview_(%d+)")
        msTitle.Text = "Pré-visualizar"
        msSub.Text = "ID: "..(id or "")
        if Player.sound and Player.playing then
            local pos = Player.sound.TimePosition or 0
            local len = Player.sound.TimeLength or 0
            if len <= 0 then len = Player.sound.TimeLength end
            msTime.Text = formatTime(pos).." / "..((len > 0) and formatTime(len) or "--:--").."   "..(Player.loop and "🔁" or "")
        else
            msTime.Text = "--:-- / --:--"
        end
    else
        msTitle.Text = "Nenhuma música tocando"
        msSub.Text = ""
        msTime.Text = ""
    end
end)

RunService.RenderStepped:Connect(function()
    local key = Player.key
    local info = key and Tracks[key]
    if info then
        msTitle.Text = info.name or "(?)"
        msSub.Text = "ID: "..(info.id or "")
        if Player.sound and Player.playing then
            local pos = Player.sound.TimePosition or 0
            local len = Player.sound.TimeLength or 0
            msTime.Text = formatTime(pos).." / "..((len > 0) and formatTime(len) or "--:--").."   "..(Player.loop and "🔁" or "")
        else
            msTime.Text = "--:-- / --:--"
        end
    elseif key and key:match("^preview_") then
        local id = key:match("^preview_(%d+)")
        msTitle.Text = "Pré-visualizar"
        msSub.Text = "ID: "..(id or "")
        if Player.sound and Player.playing then
            local pos = Player.sound.TimePosition or 0
            local len = Player.sound.TimeLength or 0
            msTime.Text = formatTime(pos).." / "..((len > 0) and formatTime(len) or "--:--").."   "..(Player.loop and "🔁" or "")
        else
            msTime.Text = "--:-- / --:--"
        end
    else
        msTitle.Text = "Nenhuma música tocando"
        msSub.Text = ""
        msTime.Text = ""
    end
end)
BtnLoop.MouseButton1Click:Connect(function()
    Player.loop = not Player.loop
    BtnLoop.Text = Player.loop and "Loop: ON" or "Loop: OFF"
    if Player.sound then Player.sound.Looped = Player.loop end
end)
BtnPlayPause.MouseButton1Click:Connect(function()
    if Player.sound then
        if Player.playing then
            pauseMusic()
        else
            resumeMusic()
        end
    end
end)
VolBox.FocusLost:Connect(function()
    local v = tonumber(VolBox.Text)
    if not v or v < 0 or v > 1 then
        notify("Volume", "Use um valor entre 0 e 1.", 3)
        VolBox.Text = tostring(Player.volume)
        return
    end
    setVolume(v)
end)
BtnDeleteAll.MouseButton1Click:Connect(function()
    deleteAll()
    refreshTrackList()
    notify("Config", "Todas as músicas apagadas.", 4)
end)
BtnComoUsar.MouseButton1Click:Connect(function()
    setclipboard("https://youtu.be/GVtXlhltLJs?si=WtXD4M9j12ddvAhr")
    notify("Como usar", "Link copiado para a área de transferência!", 4)
end)

local function formatTime(sec)
    sec = math.floor(sec or 0)
    return string.format("%02d:%02d", math.floor(sec/60), sec%60)
end

RunService.RenderStepped:Connect(function()
    local key = Player.key
    local info = key and Tracks[key]
    if info then
        msTitle.Text = info.name or "(?)"
        msSub.Text = "ID: "..(info.id or "")
        if Player.sound and Player.playing then
            local pos = Player.sound.TimePosition or 0
            local len = Player.sound.TimeLength or 0
            msTime.Text = formatTime(pos).." / "..((len > 0) and formatTime(len) or "--:--").."   "..(Player.loop and "🔁" or "")
        else
            msTime.Text = "--:-- / --:--"
        end
    else
        msTitle.Text = "Nenhuma música tocando"
        msSub.Text = ""
        msTime.Text = ""
    end
end)

local minimized = false
local tweening = false
local function tweenVisible(show)
    if tweening then return end
    tweening = true
    if show then
        Main.Visible = true
        Main.Size = UDim2.new(0, 30, 0, 30)
        Main.Position = ToggleOrb.Position
        local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(Main, ti, {Size=UDim2.new(0,880,0,440), Position=UDim2.new(0.5,0,0.5,0)}):Play()
        task.wait(0.24)
    else
        local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(Main, ti, {Size=UDim2.new(0,30,0,30), Position=ToggleOrb.Position}):Play()
        task.wait(0.22)
        Main.Visible = false
    end
    tweening = false
end

BtnClose.MouseButton1Click:Connect(function()
    minimized = true
    tweenVisible(false)
end)
OrbBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tweenVisible(not minimized)
end)

tweenVisible(false)
notify("MusicHub", "Pronto! Salve músicas, toque, pause, loop, volume, minimize!", 5)
