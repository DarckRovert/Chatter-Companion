-- Shared native 3.3.5 editor; both hosts use the same responsive layout.
local Chatter = ChatterEventFrame

local function button(parent, text, width, callback)
    local control = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    control:SetWidth(width)
    control:SetHeight(24)
    control:SetText(text)
    control:SetScript("OnClick", callback)
    return control
end

local function slider(parent)
    local control = CreateFrame("Slider", nil, parent)
    control:SetWidth(12)
    control:SetOrientation("VERTICAL")
    control:SetMinMaxValues(0, 0)
    control:SetValueStep(1)
    control:SetValue(0)
    control:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    control:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
    control:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
    return control
end

local function createLabel(parent, text, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    label:SetJustifyH("LEFT")
    label:SetText(text)
    return label
end

local function createEditBox(parent, x, y, width, height)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    holder:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, y)
    holder:SetHeight(height)
    holder:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3
        }
    })
    holder:SetBackdropColor(0, 0, 0, 0.85)
    holder:SetBackdropBorderColor(0.55, 0.55, 0.55, 1)

    local box = CreateFrame("EditBox", nil, holder)
    box:SetAutoFocus(false)
    box:SetMultiLine(false)
    box:SetFontObject(GameFontHighlight)
    box:SetPoint("TOPLEFT", holder, "TOPLEFT", 8, -6)
    box:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -8, 6)
    box:SetTextInsets(0, 0, 0, 0)
    box:SetJustifyH("LEFT")

    holder.editBox = box
    return box
end

local function createMultiLineEditBox(
    parent, x, y, width, height
)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    holder:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, y)
    holder:SetHeight(height)
    holder:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3
        }
    })
    holder:SetBackdropColor(0, 0, 0, 0.85)
    holder:SetBackdropBorderColor(0.55, 0.55, 0.55, 1)

    -- Scrollbar (thin slider on the right)
    local scrollbar = CreateFrame(
        "Slider", nil, holder
    )
    scrollbar:SetWidth(12)
    scrollbar:SetPoint(
        "TOPRIGHT", holder, "TOPRIGHT", -4, -6
    )
    scrollbar:SetPoint(
        "BOTTOMRIGHT", holder, "BOTTOMRIGHT", -4, 6
    )
    scrollbar:SetOrientation("VERTICAL")
    scrollbar:SetMinMaxValues(0, 1)
    scrollbar:SetValue(0)
    scrollbar:SetValueStep(1)
    scrollbar:SetThumbTexture(
        "Interface\\Buttons\\UI-ScrollBar-Knob"
    )
    scrollbar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
    })
    scrollbar:SetBackdropColor(0.1, 0.1, 0.1, 0.5)

    local scroll = CreateFrame(
        "ScrollFrame", nil, holder
    )
    scroll:SetPoint("TOPLEFT", holder, "TOPLEFT", 6, -6)
    scroll:SetPoint(
        "BOTTOMRIGHT", scrollbar, "BOTTOMLEFT", -2, 0
    )

    local box = CreateFrame("EditBox", nil, scroll)
    box:SetAutoFocus(false)
    box:SetMultiLine(true)
    box:SetFontObject(GameFontHighlight)
    -- Full width minus scrollbar and padding
    box:SetWidth(math.max(1, width - 28))
    box:SetHeight(20)
    box:SetTextInsets(2, 2, 2, 2)
    box:SetJustifyH("LEFT")
    scroll:SetScrollChild(box)

    -- Update width dynamically when shown
    scroll:SetScript("OnSizeChanged", function(self)
        box:SetWidth(math.max(1, self:GetWidth()))
    end)

    -- Sync helper: update scrollbar range and
    -- position from current scroll state
    local function updateScrollbar()
        local maxScroll = math.max(
            0,
            box:GetHeight() - scroll:GetHeight()
        )
        scrollbar:SetMinMaxValues(0, maxScroll)
        scrollbar:SetValue(math.min(scrollbar:GetValue(), maxScroll))
        if maxScroll > 0 then
            scrollbar:Show()
        else
            scrollbar:Hide()
        end
    end

    -- Mouse-wheel scrolling on the holder frame
    holder:EnableMouseWheel(true)
    holder:SetScript("OnMouseWheel", function(_, delta)
        local cur = scroll:GetVerticalScroll()
        local maxScroll = math.max(
            0,
            box:GetHeight() - scroll:GetHeight()
        )
        local step = 20
        local newVal = cur - (delta * step)
        newVal = math.max(0, math.min(newVal, maxScroll))
        scroll:SetVerticalScroll(newVal)
        scrollbar:SetValue(newVal)
    end)

    -- Scrollbar drag updates scroll position
    scrollbar:SetScript("OnValueChanged", function(
        self, value
    )
        scroll:SetVerticalScroll(value)
    end)

    -- Update scrollbar when text changes
    box:SetScript("OnTextChanged", function()
        scrollbar:SetValue(0)
        updateScrollbar()
    end)
    box:SetScript("OnSizeChanged", updateScrollbar)
    scroll:HookScript("OnSizeChanged", updateScrollbar)

    -- Initial scrollbar state (hidden until needed)
    scrollbar:Hide()

    holder.editBox = box
    holder.scroll = scroll
    holder.scrollbar = scrollbar
    holder.updateScrollbar = updateScrollbar
    return box
end

function Chatter:BuildEditor(panel, section)
    local storyOnly = section == "stories"
    local title = createLabel(panel,
        storyOnly and "|cFFD4AF37Project Jaina|r - Historias de Trasfondo (IA)" or "|cFFD4AF37Project Jaina|r - Rasgos de Bots Autónomos (IA)", 16, -16)
    title:SetFontObject(GameFontNormalLarge)
    local hint = createLabel(panel,
        storyOnly and "Selecciona un bot para leer o regenerar su biografía narrativa."
        or "Selecciona un bot para editar sus rasgos. Marca bots para borrar su memoria.", 16, -40)
    hint:SetFontObject(GameFontHighlightSmall)
    hint:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -40)
    hint:SetHeight(28)

    local left = CreateFrame("Frame", nil, panel)
    left:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -76)
    left:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 72)
    left:SetWidth(144)
    createLabel(left, "Buscar bot conocido", 0, 0)
    local search = createEditBox(left, 0, -18, 144, 24)
    search:SetMaxLetters(64)
    search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local list = CreateFrame("Frame", nil, left)
    list:SetPoint("TOPLEFT", left, "TOPLEFT", 0, -48)
    list:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", 0, 58)
    list:EnableMouseWheel(true)
    local bar = slider(list)
    bar:SetPoint("TOPRIGHT", list, "TOPRIGHT", 0, 0)
    bar:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", 0, 0)
    local rows = {}
    local empty = createLabel(list, "Sin bots registrados", 2, -6)
    empty:SetFontObject(GameFontHighlightSmall)
    empty:SetWidth(124)
    local count = createLabel(left, "", 0, 0)
    count:ClearAllPoints()
    count:SetPoint("BOTTOMLEFT", left, "BOTTOMLEFT", 0, 36)
    count:SetWidth(144)
    count:SetFontObject(GameFontHighlightSmall)
    local all = button(left, "Marcar todos", 82, function()
        if Chatter.forgetQueue then return end
        for _, bot in ipairs(Chatter:GetFilteredRoster(search:GetText())) do
            Chatter.checkedBots[bot.guid] = true
        end
        Chatter:UpdateRosterViews()
    end)
    all:SetPoint("BOTTOMLEFT", left, "BOTTOMLEFT", 0, 6)
    local clear = button(left, "Limpiar", 58, function()
        if Chatter.forgetQueue then return end
        Chatter.checkedBots = {}
        Chatter:UpdateRosterViews()
    end)
    clear:SetPoint("LEFT", all, "RIGHT", 4, 0)
    if storyOnly then
        all:Hide()
        clear:Hide()
        list:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", 0, 24)
        count:SetPoint("BOTTOMLEFT", left, "BOTTOMLEFT", 0, 6)
    end

    local refresh = button(panel, "Actualizar", 80, function()
        Chatter:RequestRoster()
    end)
    refresh:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -72)
    local selected = createLabel(panel, "Selecciona un bot", 172, -76)
    selected:SetPoint("TOPRIGHT", refresh, "TOPLEFT", -8, -4)
    selected:SetHeight(16)

    local scroll = CreateFrame("ScrollFrame", nil, panel)
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 172, -104)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -34, 76)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(200)
    content:SetHeight(section == "traits" and 224 or 454)
    scroll:SetScrollChild(content)
    local editorBar = slider(panel)
    editorBar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 4, 0)
    editorBar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 4, 0)
    editorBar:SetScript("OnValueChanged", function(_, value)
        scroll:SetVerticalScroll(value)
    end)
    local function resizeEditor()
        content:SetWidth(math.max(1, scroll:GetWidth()))
        if storyOnly then
            content:SetHeight(math.max(1, scroll:GetHeight()))
        end
        local maximum = math.max(0, content:GetHeight() - scroll:GetHeight())
        editorBar:SetMinMaxValues(0, maximum)
        editorBar:SetValue(math.min(editorBar:GetValue(), maximum))
        if maximum > 0 then editorBar:Show() else editorBar:Hide() end
    end
    scroll:SetScript("OnSizeChanged", resizeEditor)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(_, delta)
        local _, maximum = editorBar:GetMinMaxValues()
        editorBar:SetValue(math.max(0,
            math.min(maximum, editorBar:GetValue() - delta * 28)))
    end)

    for i = 1, storyOnly and 0 or 3 do
        local key = "trait" .. i
        local y = -(i - 1) * 48
        createLabel(content, "Rasgo de Personalidad " .. i, 0, y)
        local box = createEditBox(content, 0, y - 18, 200, 24)
        panel[key] = box
        box:SetMaxLetters(64)
        box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        box:SetScript("OnTextChanged", function(self, userInput)
            if userInput then
                for _, other in ipairs({Chatter.frame, Chatter.traitsPanel}) do
                    if other ~= panel and other[key] then
                        other[key]:SetText(self:GetText())
                    end
                end
            end
            Chatter:UpdateSaveButton()
        end)
        box:SetScript("OnEditFocusGained", function()
            local _, maximum = editorBar:GetMinMaxValues()
            editorBar:SetValue(math.min(maximum, -y))
        end)
        box:SetScript("OnTabPressed", function(self)
            self:ClearFocus()
            panel["trait" .. (i % 3 + 1)]:SetFocus()
        end)
    end
    if not storyOnly then
        createLabel(content, "Tono Conversacional (Generado por IA)", 0, -148)
        panel.tone = createMultiLineEditBox(content, 0, -166, 200, 58)
        panel.tone:EnableMouse(false)
    end
    if section ~= "traits" then
        if not storyOnly then
            createLabel(content, "Historia de Trasfondo (Narrativa IA)", 0, -236)
        end
        panel.backstory = createMultiLineEditBox(content, 0, -254, 200, 158)
        panel.backstory:EnableMouse(false)
        panel.regenStoryBtn = button(content, "Regenerar Historia", 150, function()
            Chatter:RegenBackstory()
        end)
        panel.regenStoryBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -424)
        panel.regenStoryBtn:Disable()
        if storyOnly then
            -- The story fills the viewport; its own scrollbar handles long text.
            local holder = panel.backstory:GetParent()
            holder:ClearAllPoints()
            holder:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            holder:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -4, 0)
            panel.regenStoryBtn:ClearAllPoints()
            panel.regenStoryBtn:SetParent(panel)
            panel.regenStoryBtn:SetPoint("BOTTOMRIGHT", panel,
                "BOTTOMRIGHT", -16, 44)
        end
    end

    panel.forgetBtn = button(panel, "Olvidar Marcados", 144, function()
        Chatter:ConfirmForget()
    end)
    panel.forgetBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 44)
    panel.saveBtn = button(panel, "Guardar Rasgos", 130, function()
        Chatter:SaveProfile()
    end)
    panel.saveBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 44)
    panel.saveBtn:Disable()
    if storyOnly then
        panel.forgetBtn:Hide()
        panel.saveBtn:Hide()
    end
    panel.status = createLabel(panel, "", 16, 0)
    panel.status:ClearAllPoints()
    panel.status:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 10)
    panel.status:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 10)
    panel.status:SetFontObject(GameFontNormalSmall)
    panel.status:SetHeight(28)

    local updating = false
    panel.refreshList = function()
        if updating then return end
        updating = true
        local filtered = Chatter:GetFilteredRoster(search:GetText())
        local visible = math.max(1, math.floor(list:GetHeight() / 24))
        local maximum = math.max(0, #filtered - visible)
        bar:SetMinMaxValues(0, maximum)
        local offset = math.min(maximum, math.floor(bar:GetValue()))
        bar:SetValue(offset)
        if maximum > 0 then bar:Show() else bar:Hide() end
        for i = 1, visible do
            if not rows[i] then
                local row = CreateFrame("Button", nil, list)
                row:SetPoint("TOPLEFT", list, "TOPLEFT", 0, -(i - 1) * 24)
                row:SetPoint("TOPRIGHT", list, "TOPRIGHT", -16, -(i - 1) * 24)
                row:SetHeight(24)
                row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
                row.check = CreateFrame("CheckButton", nil, row,
                    "UICheckButtonTemplate")
                row.check:SetWidth(24)
                row.check:SetHeight(24)
                row.check:SetPoint("LEFT", row, "LEFT", 0, 0)
                if storyOnly then row.check:Hide() end
                row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                row.text:SetPoint("LEFT", row, "LEFT", storyOnly and 4 or 26, 0)
                row.text:SetPoint("RIGHT", row, "RIGHT", -2, 0)
                row.text:SetJustifyH("LEFT")
                row:SetScript("OnClick", function(self)
                    if not Chatter.forgetQueue then Chatter:SelectBot(self.guid) end
                end)
                row.check:SetScript("OnClick", function(self)
                    if Chatter.forgetQueue then return end
                    Chatter.checkedBots[row.guid] = self:GetChecked() and true or nil
                    Chatter:UpdateRosterViews()
                end)
                row:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(self.botName)
                    GameTooltip:Show()
                end)
                row:SetScript("OnLeave", function() GameTooltip:Hide() end)
                rows[i] = row
            end
            local row, bot = rows[i], filtered[offset + i]
            if bot then
                row.guid, row.botName = bot.guid, bot.name
                row.text:SetText(bot.name)
                row.check:SetChecked(Chatter.checkedBots[bot.guid] or false)
                if Chatter.forgetQueue then row.check:Disable() else row.check:Enable() end
                if bot.guid == Chatter.selectedGuid then
                    row:LockHighlight()
                    row.text:SetTextColor(1, 0.82, 0)
                else
                    row:UnlockHighlight()
                    row.text:SetTextColor(1, 1, 1)
                end
                row:Show()
            else
                row:Hide()
            end
        end
        for i = visible + 1, #rows do rows[i]:Hide() end
        local checked = 0
        for _ in pairs(Chatter.checkedBots) do checked = checked + 1 end
        count:SetText(#filtered .. "/" .. #Chatter.roster .. " bots | "
            .. checked .. " marcados")
        if storyOnly then
            count:SetText(#filtered .. "/" .. #Chatter.roster .. " bots")
        end
        selected:SetText(Chatter:GetSelectedName() or "Selecciona un bot")
        if #filtered == 0 then
            empty:SetText(#Chatter.roster == 0 and "Sin bots conocidos" or "Sin coincidencias")
            empty:Show()
        else
            empty:Hide()
        end
        if checked > 0 and not Chatter.forgetQueue and not Chatter.pendingRoster then
            panel.forgetBtn:Enable()
        else
            panel.forgetBtn:Disable()
        end
        if Chatter.forgetQueue then
            all:Disable()
            clear:Disable()
            refresh:Disable()
        else
            all:Enable()
            clear:Enable()
            refresh:Enable()
        end
        updating = false
    end
    bar:SetScript("OnValueChanged", panel.refreshList)
    list:SetScript("OnSizeChanged", panel.refreshList)
    list:SetScript("OnMouseWheel", function(_, delta)
        local _, maximum = bar:GetMinMaxValues()
        bar:SetValue(math.max(0, math.min(maximum, bar:GetValue() - delta * 3)))
    end)
    search:SetScript("OnTextChanged", function()
        bar:SetValue(0)
        panel.refreshList()
    end)
    panel:HookScript("OnShow", function()
        resizeEditor()
        panel.refreshList()
    end)
    panel.refreshList()
end

function Chatter:BuildFrame()
    if self.frame then return end
    local frame = CreateFrame("Frame", "ChatterMainFrame", UIParent)
    frame:SetWidth(680)
    frame:SetHeight(640)
    frame:SetScale(math.min(1, (UIParent:GetWidth() - 32) / 680,
        (UIParent:GetHeight() - 32) / 640))
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Chatter:SaveWindowPosition()
    end)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    frame:Hide()
    self.frame = frame
    self:BuildEditor(frame)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() frame:Hide() end)
    table.insert(UISpecialFrames, "ChatterMainFrame")
    self:RestoreWindowPosition()
end

local function addCategory(panel)
    if type(InterfaceOptions_AddCategory) == "function" then
        InterfaceOptions_AddCategory(panel)
    elseif type(InterfaceOptionsFrame_AddCategory) == "function" then
        InterfaceOptionsFrame_AddCategory(panel)
    elseif type(INTERFACEOPTIONS_ADDONCATEGORIES) == "table" then
        table.insert(INTERFACEOPTIONS_ADDONCATEGORIES, panel)
    end
end

function Chatter:BuildOptionsPanel()
    if self.optionsPanel then return end
    local parent = CreateFrame("Frame", "ChatterOptionsPanel", UIParent)
    parent.name = "Project Jaina Chatter"
    parent:Hide()
    createLabel(parent, "|cFFD4AF37Project Jaina|r - |cFF00FFCCChatter Companion (Bots LLM)|r", 16, -16):SetFontObject(GameFontNormalLarge)
    local text = createLabel(parent,
        "Gestiona rasgos, personalidades, tono y trasfondos narrativos de los bots autónomos con IA (mod-llm-chatter).\n\n"
        .. "|cFFD4AF37Rasgos de Bot:|r Configura personalidad, tono conversacional y lista de bots.\n\n"
        .. "|cFFD4AF37Historias de Trasfondo:|r Lee y regenera la historia de vida del bot.\n\n"
        .. "Haz clic en el botón inferior para abrir el gestor visual completo.", 16, -48)
    text:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, -48)
    text:SetFontObject(GameFontHighlight)
    parent.openEditorBtn = button(parent, "Abrir Gestor de Bots", 180, function()
        Chatter:OpenFullEditor()
    end)
    parent.openEditorBtn:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -20)
    addCategory(parent)
    self.optionsPanel = parent
    local child = CreateFrame("Frame", "ChatterTraitsPanel", UIParent)
    child.name = "Rasgos de Bot"
    child.parent = "Project Jaina Chatter"
    child:Hide()
    self.traitsPanel = child
    self:BuildEditor(child, "traits")
    child:HookScript("OnShow", function()
        if Chatter.frame then Chatter.frame:Hide() end
        Chatter:ShowOptionsEditor()
    end)
    addCategory(child)
    local stories = CreateFrame("Frame", "ChatterStoriesPanel", UIParent)
    stories.name = "Historias de Fondo"
    stories.parent = "Project Jaina Chatter"
    stories:Hide()
    self.storiesPanel = stories
    self:BuildEditor(stories, "stories")
    stories:HookScript("OnShow", function()
        if Chatter.frame then Chatter.frame:Hide() end
        Chatter:ShowOptionsEditor()
    end)
    addCategory(stories)
end

function Chatter:ShowOptionsEditor()
    -- Navigation must not reload the profile over unsaved trait edits.
    self:UpdateRosterViews()
    if not self.loadedTraits and not self.pendingProfileGuid then
        self:RequestRoster()
    end
end

function Chatter:OpenFullEditor()
    self:BuildFrame()
    if InterfaceOptionsFrame then InterfaceOptionsFrame:Hide() end
    if GameMenuFrame then GameMenuFrame:Hide() end
    self.frame:Show()
    self.frame:Raise()
    self:UpdateSaveButton()
    self:ShowOptionsEditor()
end
