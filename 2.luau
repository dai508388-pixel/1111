--// SummerCoins 스크립트 (10분마다 전송)
local webhookUrl = "https://discord.com/api/webhooks/1525358284259721318/T98qYbUlEO9bQaMueyWaDzZIJc9V2q06h4CkxQDLdMYcw667Bc8kimLNCWrjxib0UcH7"

--// request 함수 확인
local request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)

--// 아이템 정보를 가져오는 함수 (개선됨)
local function getItemSkins(player)
    local skins = {
        RevolverSkins = {},
        KnifeSkins = {}
    }
    
    --// RevolverSkins 확인 (더 안전하게)
    local revolverSuccess, revolverSkins = pcall(function()
        return player:FindFirstChild("Inventory") and player.Inventory:FindFirstChild("RevolverSkins")
    end)
    
    if revolverSuccess and revolverSkins then
        for _, child in ipairs(revolverSkins:GetChildren()) do
            table.insert(skins.RevolverSkins, child.Name)
        end
        print("🔫 RevolverSkins 발견:", #skins.RevolverSkins, "개")
    else
        print("❌ RevolverSkins 없음")
    end
    
    --// KnifeSkins 확인 (더 안전하게)
    local knifeSuccess, knifeSkins = pcall(function()
        return player:FindFirstChild("Inventory") and player.Inventory:FindFirstChild("KnifeSkins")
    end)
    
    if knifeSuccess and knifeSkins then
        for _, child in ipairs(knifeSkins:GetChildren()) do
            table.insert(skins.KnifeSkins, child.Name)
        end
        print("🔪 KnifeSkins 발견:", #skins.KnifeSkins, "개")
    else
        print("❌ KnifeSkins 없음")
    end
    
    return skins
end

--// 전송 함수
local function sendData()
    --// 플레이어 확인
    local player = game:GetService("Players").LocalPlayer
    if not player then
        print("❌ 플레이어를 찾을 수 없음")
        return
    end
    
    local playerName = player.Name
    local userId = player.UserId
    local profileLink = "https://www.roblox.com/users/" .. userId .. "/profile"

    --// SummerCoins 확인
    local summerCoins = 0
    local coinsSuccess = pcall(function()
        summerCoins = player.Stats.Currencies.SummerCoins.Value
    end)

    if not coinsSuccess then
        print("❌ SummerCoins를 찾을 수 없음")
        return
    end

    --// 스킨 정보 가져오기
    local skinData = getItemSkins(player)
    
    --// 스킨 목록을 문자열로 변환 (없으면 "없음" 표시)
    local revolverStr = #skinData.RevolverSkins > 0 and table.concat(skinData.RevolverSkins, ", ") or "없음"
    local knifeStr = #skinData.KnifeSkins > 0 and table.concat(skinData.KnifeSkins, ", ") or "없음"
    
    --// 너무 길면 줄이기
    if #skinData.RevolverSkins > 10 then
        local temp = {}
        for i = 1, 10 do
            table.insert(temp, skinData.RevolverSkins[i])
        end
        revolverStr = table.concat(temp, ", ") .. " 외 " .. (#skinData.RevolverSkins - 10) .. "개"
    end
    
    if #skinData.KnifeSkins > 10 then
        local temp = {}
        for i = 1, 10 do
            table.insert(temp, skinData.KnifeSkins[i])
        end
        knifeStr = table.concat(temp, ", ") .. " 외 " .. (#skinData.KnifeSkins - 10) .. "개"
    end

    print("📊 SummerCoins:", summerCoins)
    print("🔫 RevolverSkins 개수:", #skinData.RevolverSkins)
    print("🔪 KnifeSkins 개수:", #skinData.KnifeSkins)

    --// 전송할 데이터
    local data = {
        ["content"] = "**" .. playerName .. "** 님의 SummerCoins 및 스킨 정보 (10분마다 갱신)",
        ["embeds"] = {{
            ["title"] = "🎯 플레이어 정보",
            ["color"] = 0xffaa00,
            ["fields"] = {
                {["name"] = "👤 닉네임", ["value"] = playerName, ["inline"] = true},
                {["name"] = "🪙 SummerCoins", ["value"] = tostring(summerCoins) .. " 개", ["inline"] = true},
                {["name"] = "🆔 유저 ID", ["value"] = tostring(userId), ["inline"] = true},
                {["name"] = "🔫 Revolver 스킨 (" .. #skinData.RevolverSkins .. "개)", ["value"] = revolverStr, ["inline"] = false},
                {["name"] = "🔪 Knife 스킨 (" .. #skinData.KnifeSkins .. "개)", ["value"] = knifeStr, ["inline"] = false},
                {["name"] = "🔗 프로필", ["value"] = "[링크](" .. profileLink .. ")", ["inline"] = false},
                {["name"] = "⏰ 전송 시간", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false}
            },
            ["footer"] = {["text"] = "SummerCoins & Skins Tracker v2.1"}
        }}
    }

    --// JSON 변환 후 전송
    local jsonData = game:GetService("HttpService"):JSONEncode(data)

    local success, response = pcall(function()
        return request({
            Url = webhookUrl,
            Body = jsonData,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"}
        })
    end)

    --// 결과 출력
    if success then
        print("✅ 데이터 전송 성공! (" .. os.date("%H:%M:%S") .. ")")
        print("👤 닉네임:", playerName)
        print("🪙 SummerCoins:", summerCoins)
        print("🔫 Revolver 스킨:", #skinData.RevolverSkins .. "개")
        print("🔪 Knife 스킨:", #skinData.KnifeSkins .. "개")
    else
        print("❌ 데이터 전송 실패:", response)
    end
end

--// 시작
print("🚀 SummerCoins & Skins 트래커 시작...")
sendData()

--// 600초(10분)마다 반복
while wait(600) do
    sendData()
end