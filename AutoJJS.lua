-- ============================================
-- AUTO CHAT 1-550 - VERSÃO FUNCIONAL
-- Usa método correto do Roblox Chat
-- COM OPÇÃO DE NÚMEROS POR EXTENSO - CORRIGIDO
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- CONFIGURAÇÕES (AJUSTE AQUI)
-- ============================================
local Config = {
    DelayBetweenMessages = 5, -- Segundos entre mensagens (MÍNIMO 5)
    MaxMessages = 550,        -- Número máximo de mensagens
    UseSafeMode = true,       -- Modo seguro (recomendado)
    AutoStopAtLimit = true,   -- Para automaticamente no limite
    ModoExtenso = false       -- true para números por extenso (UM!, DOIS!, TRÊS!)
}

-- ============================================
-- TABELA DE NÚMEROS POR EXTENSO
-- ============================================
local numerosExtenso = {
    "UM", "DOIS", "TRÊS", "QUATRO", "CINCO", "SEIS", "SETE", "OITO", "NOVE", "DEZ",
    "ONZE", "DOZE", "TREZE", "CATORZE", "QUINZE", "DEZESSEIS", "DEZESSETE", "DEZOITO", "DEZENOVE", "VINTE",
    "VINTE E UM", "VINTE E DOIS", "VINTE E TRÊS", "VINTE E QUATRO", "VINTE E CINCO", 
    "VINTE E SEIS", "VINTE E SETE", "VINTE E OITO", "VINTE E NOVE", "TRINTA",
    "TRINTA E UM", "TRINTA E DOIS", "TRINTA E TRÊS", "TRINTA E QUATRO", "TRINTA E CINCO",
    "TRINTA E SEIS", "TRINTA E SETE", "TRINTA E OITO", "TRINTA E NOVE", "QUARENTA",
    "QUARENTA E UM", "QUARENTA E DOIS", "QUARENTA E TRÊS", "QUARENTA E QUATRO", "QUARENTA E CINCO",
    "QUARENTA E SEIS", "QUARENTA E SETE", "QUARENTA E OITO", "QUARENTA E NOVE", "CINQUENTA",
    "CINQUENTA E UM", "CINQUENTA E DOIS", "CINQUENTA E TRÊS", "CINQUENTA E QUATRO", "CINQUENTA E CINCO",
    "CINQUENTA E SEIS", "CINQUENTA E SETE", "CINQUENTA E OITO", "CINQUENTA E NOVE", "SESSENTA",
    "SESSENTA E UM", "SESSENTA E DOIS", "SESSENTA E TRÊS", "SESSENTA E QUATRO", "SESSENTA E CINCO",
    "SESSENTA E SEIS", "SESSENTA E SETE", "SESSENTA E OITO", "SESSENTA E NOVE", "SETENTA",
    "SETENTA E UM", "SETENTA E DOIS", "SETENTA E TRÊS", "SETENTA E QUATRO", "SETENTA E CINCO",
    "SETENTA E SEIS", "SETENTA E SETE", "SETENTA E OITO", "SETENTA E NOVE", "OITENTA",
    "OITENTA E UM", "OITENTA E DOIS", "OITENTA E TRÊS", "OITENTA E QUATRO", "OITENTA E CINCO",
    "OITENTA E SEIS", "OITENTA E SETE", "OITENTA E OITO", "OITENTA E NOVE", "NOVENTA",
    "NOVENTA E UM", "NOVENTA E DOIS", "NOVENTA E TRÊS", "NOVENTA E QUATRO", "NOVENTA E CINCO",
    "NOVENTA E SEIS", "NOVENTA E SETE", "NOVENTA E OITO", "NOVENTA E NOVE", "CEM"
}

-- Função para converter números para extenso
local function numeroParaExtenso(numero)
    if numero >= 1 and numero <= 100 then
        return numerosExtenso[numero]
    elseif numero > 100 and numero <= 550 then
        local centenas = math.floor(numero / 100)
        local resto = numero % 100
        
        if centenas == 1 then
            if resto == 0 then
                return "CEM"
            else
                return "CENTO E " .. (resto <= 100 and numeroParaExtenso(resto) or tostring(resto))
            end
        elseif centenas == 2 then
            return "DUZENTOS" .. (resto > 0 and " E " .. (resto <= 100 and numeroParaExtenso(resto) or tostring(resto)) or "")
        elseif centenas == 3 then
            return "TREZENTOS" .. (resto > 0 and " E " .. (resto <= 100 and numeroParaExtenso(resto) or tostring(resto)) or "")
        elseif centenas == 4 then
            return "QUATROCENTOS" .. (resto > 0 and " E " .. (resto <= 100 and numeroParaExtenso(resto) or tostring(resto)) or "")
        elseif centenas == 5 then
            return "QUINHENTOS" .. (resto > 0 and " E " .. (resto <= 100 and numeroParaExtenso(resto) or tostring(resto)) or "")
        else
            return tostring(numero)
        end
    else
        return tostring(numero)
    end
end

-- ============================================
-- VARIÁVEIS DO SISTEMA
-- ============================================
local Running = false
local MessageCount = 0
local ChatEvents
local StatusLabel
local ModoExtensoToggle

-- Encontrar os eventos de chat corretamente
local function GetChatEvents()
    if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
        return ReplicatedStorage.DefaultChatSystemChatEvents
    end
    
    -- Tentar método alternativo
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("Folder") and child.Name:find("Chat") then
            return child
        end
    end
    
    return nil
end

-- ============================================
-- FUNÇÃO PARA ENVIAR MENSAGEM (CORRIGIDA)
-- ============================================
local function SendChatMessage(text)
    if not ChatEvents then
        ChatEvents = GetChatEvents()
        if not ChatEvents then
            warn("❌ Não foi possível encontrar o sistema de chat!")
            return false
        end
    end
    
    local SayMessageRequest = ChatEvents:FindFirstChild("SayMessageRequest")
    if not SayMessageRequest then
        warn("❌ SayMessageRequest não encontrado!")
        return false
    end
    
    -- Limpar mensagens duplicadas - ENVIAR APENAS UMA VEZ
    local success, errorMsg = pcall(function()
        -- ENVIA APENAS UMA VEZ!
        SayMessageRequest:FireServer(text, "All")
    end)
    
    if success then
        MessageCount = MessageCount + 1
        print("✅ Enviado: " .. text)
        return true
    else
        warn("❌ Erro ao enviar mensagem: " .. tostring(errorMsg))
        return false
    end
end

-- ============================================
-- FUNÇÃO PRINCIPAL DE CONTAGEM (CORRIGIDA)
-- ============================================
local function StartCounting()
    if Running then 
        print("⚠️ Já está em execução!")
        return 
    end
    
    Running = true
    MessageCount = 0
    local lastMessage = "" -- Variável para controlar última mensagem
    
    print("🚀 Iniciando Auto Chat...")
    print("⏱️ Delay entre mensagens: " .. Config.DelayBetweenMessages .. "s")
    print("📝 Modo: " .. (Config.ModoExtenso and "EXTENSO (UM!, DOIS!)" or "NORMAL (1!, 2!)"))
    
    -- Loop principal
    for i = 1, Config.MaxMessages do
        if not Running then break end
        
        -- Formatar mensagem baseado no modo
        local message
        if Config.ModoExtenso then
            message = numeroParaExtenso(i) .. "!"
        else
            message = tostring(i) .. "!"
        end
        
        -- VERIFICA se é diferente da última mensagem
        if message ~= lastMessage then
            print("📤 Enviando: " .. message)
            
            -- Tentar enviar a mensagem APENAS UMA VEZ
            local sent = SendChatMessage(message)
            
            if not sent then
                print("⚠️ Falha ao enviar, tentando método alternativo...")
                -- Método de fallback (também apenas uma vez)
                pcall(function()
                    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(message)
                end)
            end
            
            -- Atualizar última mensagem
            lastMessage = message
            
            -- Atualizar status na GUI
            if StatusLabel then
                StatusLabel.Text = "Enviado: " .. tostring(i) .. "/550 | Modo: " .. (Config.ModoExtenso and "EXTENSO" or "NORMAL")
            end
        else
            print("⚠️ Mensagem duplicada detectada, pulando: " .. message)
        end
        
        -- Delay entre mensagens (CRÍTICO PARA EVITAR BAN)
        wait(Config.DelayBetweenMessages)
        
        -- Verificar se deve parar (modo seguro)
        if Config.UseSafeMode and i >= 20 then
            print("⚠️ Modo seguro: Parando após 20 mensagens")
            break
        end
    end
    
    Running = false
    print("✅ Contagem finalizada! Total: " .. tostring(MessageCount) .. " mensagens enviadas")
    print("📝 Modo utilizado: " .. (Config.ModoExtenso and "EXTENSO" or "NORMAL"))
    
    if StatusLabel then
        StatusLabel.Text = "Status: FINALIZADO"
        StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 120)
    end
end

-- ============================================
-- CRIAR INTERFACE (GUI)
-- ============================================
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoChat550"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Text = "🔥 AUTO CHAT 1-550 🔥"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 100, 100)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = MainFrame
    
    -- Status
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Text = "Status: PRONTO | Modo: " .. (Config.ModoExtenso and "EXTENSO" or "NORMAL")
    StatusLabel.Size = UDim2.new(1, -20, 0, 30)
    StatusLabel.Position = UDim2.new(0, 10, 0, 50)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
    StatusLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    StatusLabel.Font = Enum.Font.GothamSemibold
    StatusLabel.TextSize = 14
    StatusLabel.Parent = MainFrame
    
    -- Botão Iniciar
    local StartButton = Instance.new("TextButton")
    StartButton.Text = "▶️ INICIAR CONTAGEM"
    StartButton.Size = UDim2.new(0.9, 0, 0, 45)
    StartButton.Position = UDim2.new(0.05, 0, 0, 90)
    StartButton.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
    StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartButton.Font = Enum.Font.GothamBold
    StartButton.TextSize = 16
    StartButton.Parent = MainFrame
    
    -- Botão Parar
    local StopButton = Instance.new("TextButton")
    StopButton.Text = "⏹️ PARAR"
    StopButton.Size = UDim2.new(0.9, 0, 0, 45)
    StopButton.Position = UDim2.new(0.05, 0, 0, 145)
    StopButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
    StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopButton.Font = Enum.Font.GothamBold
    StopButton.TextSize = 16
    StopButton.Parent = MainFrame
    
    -- Botão Modo Extenso
    ModoExtensoToggle = Instance.new("TextButton")
    ModoExtensoToggle.Text = Config.ModoExtenso and "🔤 MODO: EXTENSO" or "🔢 MODO: NORMAL"
    ModoExtensoToggle.Size = UDim2.new(0.9, 0, 0, 40)
    ModoExtensoToggle.Position = UDim2.new(0.05, 0, 0, 200)
    ModoExtensoToggle.BackgroundColor3 = Config.ModoExtenso and Color3.fromRGB(40, 40, 120) or Color3.fromRGB(60, 60, 60)
    ModoExtensoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModoExtensoToggle.Font = Enum.Font.GothamBold
    ModoExtensoToggle.TextSize = 14
    ModoExtensoToggle.Parent = MainFrame
    
    -- Configuração
    local ConfigText = Instance.new("TextLabel")
    ConfigText.Text = "Delay: " .. Config.DelayBetweenMessages .. "s | Modo Seguro: " .. (Config.UseSafeMode and "ON" or "OFF")
    ConfigText.Size = UDim2.new(1, -20, 0, 20)
    ConfigText.Position = UDim2.new(0, 10, 1, -30)
    ConfigText.BackgroundTransparency = 1
    ConfigText.TextColor3 = Color3.fromRGB(150, 150, 150)
    ConfigText.Font = Enum.Font.Gotham
    ConfigText.TextSize = 12
    ConfigText.Parent = MainFrame
    
    -- Créditos
    local Credits = Instance.new("TextLabel")
    Credits.Text = "by vit_wc7"
    Credits.Size = UDim2.new(1, -20, 0, 20)
    Credits.Position = UDim2.new(0, 10, 1, -50)
    Credits.BackgroundTransparency = 1
    Credits.TextColor3 = Color3.fromRGB(100, 150, 255)
    Credits.Font = Enum.Font.GothamBold
    Credits.TextSize = 12
    Credits.Parent = MainFrame
    
    -- Ações dos botões
    StartButton.MouseButton1Click:Connect(function()
        if not Running then
            StatusLabel.Text = "Status: ENVIANDO... | Modo: " .. (Config.ModoExtenso and "EXTENSO" or "NORMAL")
            StatusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 30)
            coroutine.wrap(StartCounting)()
        end
    end)
    
    StopButton.MouseButton1Click:Connect(function()
        Running = false
        StatusLabel.Text = "Status: PARADO | Modo: " .. (Config.ModoExtenso and "EXTENSO" or "NORMAL")
        StatusLabel.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
        print("⏹️ Auto Chat parado manualmente")
    end)
    
    ModoExtensoToggle.MouseButton1Click:Connect(function()
        Config.ModoExtenso = not Config.ModoExtenso
        ModoExtensoToggle.Text = Config.ModoExtenso and "🔤 MODO: EXTENSO" or "🔢 MODO: NORMAL"
        ModoExtensoToggle.BackgroundColor3 = Config.ModoExtenso and Color3.fromRGB(40, 40, 120) or Color3.fromRGB(60, 60, 60)
        StatusLabel.Text = "Status: " .. (Running and "ENVIANDO" or "PRONTO") .. " | Modo: " .. (Config.ModoExtenso and "EXTENSO" or "NORMAL")
        print("🔄 Modo alterado para: " .. (Config.ModoExtenso and "EXTENSO" or "NORMAL"))
    end)
    
    return ScreenGui
end

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
print([[
============================================
🤖 AUTO CHAT 1-550 - VERSÃO FUNCIONAL
COM OPÇÃO DE NÚMEROS POR EXTENSO
============================================
CORREÇÃO: Não repete números!
============================================
ATENÇÃO:
- Use com moderação
- Delay mínimo recomendado: 5 segundos
- Spam pode resultar em mute/ban
============================================
]])

-- Criar a interface
local GUI = CreateGUI()

-- ============================================
-- FUNÇÕES PARA O CONSOLE
-- ============================================
_G.StartAutoChat = function()
    if not Running then
        coroutine.wrap(StartCounting)()
    end
end

_G.StopAutoChat = function()
    Running = false
end

_G.SetDelay = function(seconds)
    if seconds >= 3 then
        Config.DelayBetweenMessages = seconds
        print("✅ Delay ajustado para: " .. seconds .. " segundos")
    else
        print("❌ Delay mínimo: 3 segundos")
    end
end

_G.ToggleExtenso = function()
    Config.ModoExtenso = not Config.ModoExtenso
    print("🔄 Modo alterado para: " .. (Config.ModoExtenso and "EXTENSO" or "NORMAL"))
    if ModoExtensoToggle then
        ModoExtensoToggle.Text = Config.ModoExtenso and "🔤 MODO: EXTENSO" or "🔢 MODO: NORMAL"
        ModoExtensoToggle.BackgroundColor3 = Config.ModoExtenso and Color3.fromRGB(40, 40, 120) or Color3.fromRGB(60, 60, 60)
    end
end

print("✅ Script carregado! Comandos disponíveis:")
print("   StartAutoChat() - Iniciar contagem")
print("   StopAutoChat() - Parar contagem")
print("   SetDelay(5) - Ajustar delay")
print("   ToggleExtenso() - Alternar entre modo normal/extenso")
print("==============================================")
