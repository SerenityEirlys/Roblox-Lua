repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer
local Plr = game.Players.LocalPlayer
repeat wait() until Plr.Character
repeat wait() until Plr.Character:FindFirstChild("HumanoidRootPart")
repeat wait() until Plr.Character:FindFirstChild("Humanoid")
local TeleportService = game:GetService("TeleportService")

local Plrgui = game:GetService("Players").LocalPlayer.PlayerGui

local function ConvertGradientToRGB(v, num)
    local color = v.Color.Keypoints[num].Value
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return Color3.fromRGB(r, g, b)
end


local RarityColor = {}
for _, v in pairs(Plrgui.Lobby.MarketplaceFrame.MarketplaceMain.MainFrame.BuyMenu.FilterBar.Rarities:GetChildren()) do
    if v:IsA("Frame") then
        RarityColor[v.Name] = {
            ["1"] = ConvertGradientToRGB(v.FilterButton[v.Name], 1),
            ["2"] = ConvertGradientToRGB(v.FilterButton[v.Name], 2)
        }
    end
end


local function GetRarity(color1, color2)
    for rarity, colors in pairs(RarityColor) do
        if (color1 == colors["1"] and color2 == colors["2"]) then
            return rarity
        end
    end
end

local function GetRandomUnit()
    for _, v in pairs(Plrgui.Lobby.PostOffice.Menus.SendPackages.PlayerUnits.PlayerUnits:GetChildren()) do
        if v:IsA("Frame") then
            local UnitRarity = GetRarity(ConvertGradientToRGB(v.TroopPicture.RarityGradient, 1), ConvertGradientToRGB(v.TroopPicture.RarityGradient, 2))
            if not v.TroopPicture.CannotTrade.Visible and (UnitRarity == "Basic" or UnitRarity == "Uncommon" or UnitRarity == "Rare") then
                return v
            end
        end
    end
end


-- Function to click a GUI button
local function ClickButton(a)
    game:GetService("GuiService").SelectedObject = a
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Return", false, game)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Return", false, game) 
end


-- Function to detect invocation
local function DetectInvoke()
    local a = require(game:GetService("ReplicatedStorage").MultiboxFramework)
    for i, v in next, getupvalues(getupvalues(a.Network.Invoke)[1])[5] do
        if i == "PostOffice_SendGift" then
            return v.SendBridge._identifier
        end
    end
end

local function InputTextBox(textbox, text)
    textbox:CaptureFocus()
    wait(0.1)
    textbox.Text = text
    
end

-- Function to generate a random string
local function Random(Length)
    local alphabet = "0123456789"
    local n = string.len(alphabet)
    local pw = {}
    for i = 1, Length do
        pw[i] = string.byte(alphabet, math.random(n))
    end
    return string.char(table.unpack(pw))
end
local function SendWebHook(PlayerName,Gem)
    local msg = {
        ['content'] = 'Send Gem Success',
        ["embeds"] = {{
            ["title"] = "Toilet Tower Defense",
            ["description"] = getgenv().UnitName,
            ["type"] = "rich",
            ["color"] = tonumber(0xbdce44),
            ["fields"] = {
                {
                    ["name"] = "Player name",
                    ["value"] = PlayerName,                                            
                    ["inline"] = true
                },
                {
                    ["name"] = "Gem",
                    ["value"] =Gem,                                            
                    ["inline"] = true
                }
            }
        }}
    }
    request({
        Url = getgenv().Webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode(msg)
    }) 
end
getgenv().SendGemToggle = true 
-- Main loop
spawn(function()
    while  getgenv().SendGemToggle do
        wait()
        pcall(function()
            if DetectInvoke() ~= nil then
                wait(10)
                print("Step 8: DetectInvoke is not nil")
                for i, v in pairs(getgenv().PlayerList) do
                    local for_gem = string.char(math.random(97, 122))
                    local gem_only = {
                        [1] = {
                            [1] = {
                                [1] = Random(64),
                                [2] = v,
                                [3] = for_gem,
                                [4] = for_gem,
                                [5] = getgenv().Gem,
                                [6] = ""
                            },
                            [2] = DetectInvoke()
                        }
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("dataRemoteEvent"):FireServer(unpack(gem_only))
                    SendWebHook(game:GetService("Players"):GetNameFromUserIdAsync(v),getgenv().Gem)
                    wait(10)
                end
                getgenv().SendGemToggle = false 
            else
                print("Step 9: DetectInvoke is nil")
                if not Plrgui.LoadingGui.LoadingFrame.Visible then
                    if Plrgui.Lobby.PostOffice.Visible then
                        if Plrgui.Lobby.PostOffice.Menus.SendPackages.SendingFrame.Username.Text == "RAV_Albert" then
                            local Unit = GetRandomUnit()
                            if Unit then
                                if  Unit.TroopPicture.IsInTrade.Visible then
                                    if Plrgui.Lobby.PostOffice.Menus.Alerts.Visible then 
                                        ClickButton(Plrgui.Lobby.PostOffice.Menus.Alerts.ConfirmSend.Options.Confirm)
                                    else 
                                        ClickButton(Plrgui.Lobby.PostOffice.Menus.SendPackages.SendingFrame.Send.SendButton)
                                    end
                                else 
                                    ClickButton(Unit.TroopPicture.InteractiveButton)
                                end
                            else 
                                local msg = {
                                    ['content'] = 'Send Gem Lỗi',
                                    ["embeds"] = {{
                                        ["title"] = "Toilet Tower Defense",
                                        ["description"] = getgenv().UnitName,
                                        ["type"] = "rich",
                                        ["color"] = tonumber(0xbdce44),
                                        ["fields"] = {
                                            {
                                                ["name"] = "Reason",
                                                ["value"] = "Acc khong co unit rac",                                            
                                                ["inline"] = false
                                            },
                                            
                                        }
                                    }}
                                }
                                request({
                                    Url = getgenv().Webhook,
                                    Method = "POST",
                                    Headers = {["Content-Type"] = "application/json"},
                                    Body = game:GetService("HttpService"):JSONEncode(msg)
                                }) 
                                wait()
                                TeleportService:Teleport(13775256536)
                            end         
                        else
                            Plrgui.Lobby.PostOffice.Menus.SendPackages.SendingFrame.Username.Text = "RAV_Albert"
                        end
                    else
                        local PostOfficeHandler = getsenv(Plrgui.Lobby.PostOffice.PostOfficeHandler)
                        PostOfficeHandler:OpenFrame()
                    end
                end
            end
        end)
    end
end)
