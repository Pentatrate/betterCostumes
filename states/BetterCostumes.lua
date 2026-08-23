local st = Gamestate:new("BetterCostumes")

function st:playSound(sound) te.playOne(sound, "static", "sfx", 0.5, math.random(90, 110) / 100) end

function st:getName(id, onlyReal)
	local costume = Costumes[id]
	if loc.json["costume_" .. id] then
		return loc.get("costume_" .. id)
	elseif costume and costume.metadata and costume.metadata.name then
		return costume.metadata.name
	elseif not onlyReal then
		return "id: " .. tostring(id)
	end
end
function st:getDesc(id)
	local costume = Costumes[id]
	if self:isUnlocked(id) then -- check if unlocked
		if loc.json["costume_" .. id .. "_description"] then
			return loc.try("costume_" .. id .. "_description",nil,true)
		else
			return costume.metadata.desc
		end
	else --otherwise, show the requirements
		local desc = loc.get("costume_" .. id .. "_unlock")
		if string.sub(desc, 1, 2) == "a!" then
			desc = loc.get("costume_unlock_arank", { string.sub(desc, 3, -1) })
		end
		return desc
	end
end

function st:isUnlocked(id)
	if mod.config.unlockAllCostumes then return true end
	local costume = Costumes[id]
	return costume.isCustom or self.CostumeUnlocks[id]
end
function st:isVisible(id)
	if mod.config.showHiddenCostumes then return true end
	local costume = Costumes[id]
	local requirements = costume.metadata.DisplayRequirements
	if not costume.isCustom and requirements then
		for _, requirement in ipairs(requirements) do
			if requirement.type == "LevelUnlock" then
				local state = UnlockManager.getUnlockState(requirement.level)
				if state == UnlockManager.static.LevelUnlockState.Locked or state == UnlockManager.static.LevelUnlockState.LockedWithHint then
					return false
				end
			end
		end
	end
	return true
end
function st:isEditable(id)
	local costume = Costumes[id]
	return costume and costume.isCustom and not costume.isWorkshop and not costume.errorPreventLoad
end

function st:isActive(id) return id == savedata.costumes.currentCostume or self:isRandomCostume(id) end
function st:isFavorite(id) return mod.config.favorites[id] end

function st:randomEnabled() return savedata.costumes.currentCostume == "random" and mod.config.selectiveRandomness end
function st:isRandomCostume(id) return savedata.costumes.currentCostume == "random" and self.p and id == self.p.randomCostume end
function st:isPotential(id) return self:randomEnabled() and mod.config.selectedRandomness[id] end

function st:setCostume(id)
	local costume = Costumes[id]
	if self:isUnlocked(id) then
		savedata.costumes.currentCostume = id
		self:playSound(sounds.optionsMenu.confirm)
		self.p.emoTimer = 60
		self.p.cEmotion = "happy"
	else
		self:playSound(sounds.mine)
	end
end

function st:createCostume()
	utilitools.config.save(mod)
	self.p.delete = true
	self.p = nil
	self.menuMusicManager:stop()
	returnData = { state = 'BetterCostumes', vars = { tab = self.tab } }

	cs = bs.load("CostumeEditor")
	cs.newCostume = true
	cs.bg = self.bg
	cs:init()
end
function st:editCostume(id)
	local costume = Costumes[id]
	if costume and self:isEditable(id) then
		utilitools.config.save(mod)
		self.p.delete = true
		self.p = nil
		self.menuMusicManager:stop()
		returnData = { state = 'BetterCostumes', vars = { tab = self.tab } }

		cs = bs.load("CostumeEditor")
		cs.path = costume.path
		cs.bg = self.bg
		cs:init()
	end
end
function st:quitToMenu()
	utilitools.config.save(mod)
	sdfunc.save()

	self.p.delete = true
	self.p = nil
	self.menuMusicManager:clearOnBeatHooks()
	self.menuMusicManager:forceUnmute()
	self.bg.skipRender = false

	cs = bs.load("Menu")
	cs.menuMusicManager = self.menuMusicManager
	cs.bg = self.bg
	cs:init()
end

function st:sortCostumes()
	self.costumesSorted = {}
	if self.tab ~= "None" and self.tab ~= "Settings" then
		for id, costume in pairs(Costumes) do
			if not self.fakeCostumes[id] then
				local inTab
				if self.tab == "All" then inTab = true end
				if self.tab == "Vanilla" and not costume.isCustom then inTab = true end
				if self.tab == "Workshop" and costume.isWorkshop then inTab = true end
				if self.tab == "Local" and costume.isCustom and not costume.isWorkshop then inTab = true end
				if id == "none" or id == "random" then inTab = true end
				if inTab and self:isVisible(id) then table.insert(self.costumesSorted, id) end
			end
		end
	end
	table.sort(self.costumesSorted, function(a, b)
		local A, B = Costumes[a], Costumes[b]
		if (a == "none") ~= (b == "none") then return a == "none" end
		if (a == "random") ~= (b == "random") then return a == "random" end
		if not A ~= not B then return not A end
		if A then
			if not self:isUnlocked(a) ~= not self:isUnlocked(b) then return not self:isUnlocked(b) end
			if self:isFavorite(a) ~= self:isFavorite(b) then return self:isFavorite(a) end
			if A.isWorkshop ~= B.isWorkshop then return B.isWorkshop end
			if A.isCustom ~= B.isCustom then return B.isCustom end

			local aName = self:getName(a, true)
			local bName = self:getName(b, true)
			if not aName ~= not bName then return not aName end
			if aName then
				return aName < bName
			end
		end
		return a < b
	end)
end

st:setInit(function(self)
	---@diagnostic disable-next-line: missing-parameter
	Player.reloadCustomCostumes()
	self.CostumeUnlocks = UnlockManager.checkCostumeUnlocks(Costumes)
	self.fakeCostumes = {
		_customCostumes = true,
		_defaultCostumes = true,
		_createCostume = true,
		customCostumeList = true
	}
	self.previewSize = 100
	self.lockSize = 32
	self.checkSize = 64
	self.starSizeX = 19
	self.starSizeY = 18
	self.style = imgui.GetStyle()

	self.tab = self.tab or "All"
	self.costumesSorted = {}

	self.initing = true

	self.p = em.init("Player", { x = project.res.cx, y = project.res.cy })
	self.p.drawScale = 2
	self.p.lineWidth = 3

	if not self.menuMusicManager then
		self.menuMusicManager = em.init("MenuMusicManager")
		self.menuMusicManager:play()
	end

	if not self.bg then
		self.bg = em.init('MenuBackground')
	end
	self.bg.skipRender = true

	shuv.pal[2] = { r = 255, g = 0, 	b = 0 }
	shuv.pal[3] = { r = 0,   g = 0, 	b = 255 }
	shuv.pal[4] = { r = 0,   g = 255, 	b = 0 }
	shuv.pal[5] = { r = 255, g = 255, 	b = 0 }
	shuv.pal[6] = { r = 255, g = 0, 	b = 255 }
	shuv.pal[7] = { r = 0,   g = 255, 	b = 255 }

	self.canvs = {}
	self.canvs2 = {}
	local oldCanv = love.graphics.getCanvas()
	for id, costume in pairs(Costumes) do
		if not self.fakeCostumes[id] and id ~= "random" then
			self.canvs[id] = love.graphics.newCanvas(self.previewSize, self.previewSize)
			self.canvs2[id] = love.graphics.newCanvas(self.previewSize, self.previewSize)
			love.graphics.setCanvas(self.canvs2[id])
			love.graphics.clear()
			self.p.x = self.previewSize / 2
			self.p.y = self.previewSize / 2
			self.p.drawScale = 1
			self.p.lineWidth = 2
			self.p.angle = 45

			self.p.forceCostume = id
			self.p:draw()
		end
	end
	love.graphics.setCanvas(oldCanv)

	self:sortCostumes()
end)

st:setUpdate(function(self, dt)
	if self.bg then self.bg:update(dt) end
	if self.p then
		if self.p.dizzy >= 800 then
			self.p.dizzy = 0
			self.p.emoTimer = 100
			self.p.cEmotion = "spiral"
		end
		self.p.skipRender = ({ never = true, behind = false, ["1/3"] = false, ["1/2"] = false, ["2/3"] = false })[mod.config.showCrankyLeft] or false
	end
	if maininput:pressed("back") then
		self:quitToMenu()
	end
end)

st:setBgDraw(function(self)
	color()
	love.graphics.rectangle("fill", 0, 0, project.res.x, project.res.y)
end)
st:setFgDraw(function(self)
	-- Penta: conveniently copied from BBP
	local appliedBBPTheme = false -- The following config may change mid draw call
	if mod.config.lightModeBetterCostumes then
		bbp.gui.pushStyle()
		appliedBBPTheme = true
	end
	local oldCanv = love.graphics.getCanvas()
	local hoveredCostume

	helpers.SetNextWindowPos(0, 0)
	do
		local mult = ({ never = 1, behind = 1, ["1/3"] = 2 / 3, ["1/2"] = 1 / 2, ["2/3"] = 1 / 3 })[mod.config.showCrankyLeft] or 1
		if mods["imgui-scale-fix"] and mods["imgui-scale-fix"].enabled then
			helpers.SetNextWindowSize(love.graphics.getWidth() * mult, love.graphics.getHeight())
		else
			helpers.SetNextWindowSize(project.res.x * imgui.canvasScale * mult, project.res.y * imgui.canvasScale)
		end
	end
	imgui.Begin("Better Costumes", nil, imgui.ImGuiWindowFlags_NoTitleBar + imgui.ImGuiWindowFlags_NoResize + imgui.ImGuiWindowFlags_NoMove + imgui.ImGuiWindowFlags_NoCollapse)

	do
		imgui.AlignTextToFramePadding()
		local avail = imgui.GetContentRegionAvail().x
		imgui.Text(tostring(loc.get('costumes')))

		if self:randomEnabled() then
			if self.tab ~= "None" and self.tab ~= "Settings" then
				imgui.SameLine()
				if imgui.Button("Select all##randomCostume") then
					for id, costume in pairs(Costumes) do
						if not self.fakeCostumes[id] then
							local inTab
							if self.tab == "All" then inTab = true end
							if self.tab == "Vanilla" and not costume.isCustom then inTab = true end
							if self.tab == "Workshop" and costume.isWorkshop then inTab = true end
							if self.tab == "Local" and costume.isCustom and not costume.isWorkshop then inTab = true end
							if id == "none" then inTab = true end
							if id == "random" then inTab = false end
							if inTab and self:isVisible(id) and self:isUnlocked(id) then mod.config.selectedRandomness[id] = true end
						end
					end
				end
			end
			imgui.SameLine()
			if imgui.Button("Deselect all##randomCostume") then
				mod.config.selectedRandomness = { none = true }
				if self.p then self.p.randomCostume = "none" end
			end
		end
		imgui.SameLine()
		local avail2 = imgui.GetContentRegionAvail().x

		local exitString = "Exit"
		local exitWidth = imgui.CalcTextSize(exitString, nil, false, nil).x
		imgui.SameLine(avail - exitWidth)
		if imgui.Button(exitString) then self:quitToMenu() end

		local midString = "LMB to select, RMB to edit, " .. utilitools.keybinds.text.generate(mod, "favoriteKey", true, false, true) .. " to favorite" .. (self:randomEnabled() and ", MMB to toggle random pool" or "")
		local midWidth = imgui.CalcTextSize(midString, nil, false, nil).x
		local avail3 = avail2 - exitWidth - self.style.ItemSpacing.x
		if avail3 - midWidth < 0 then
			if avail - midWidth >= 0 then
				imgui.NewLine()
				imgui.SameLine((avail - midWidth) / 2)
				imgui.Text(midString)
			else
				imgui.TextWrapped(midString)
			end
		else
			imgui.SameLine(avail - avail2 + (avail3 - midWidth) / 2)
			imgui.Text(midString)
		end
	end

	local tab = self.tab
	if imgui.BeginTabBar("BetterCostumes") then
		local function tab(name)
			if imgui.BeginTabItem(name .. "##BetterCostumes", nil, self.initing and self.tab == name and imgui.ImGuiTabItemFlags_SetSelected or nil) then
				self.tab = name
				imgui.EndTabItem(name .. "##BetterCostumes")
			end
		end
		tab("All")
		tab("Vanilla")
		tab("Workshop")
		tab("Local")
		tab("Settings")
		tab("None")
		imgui.EndTabBar()
	end
	self.initing = false
	if tab ~= self.tab then self:sortCostumes() end

	if self.tab == "Settings" then
		local configHelpers = utilitools.configHelpers
		configHelpers.setMod(mod)

		configHelpers.input("betterCostumes")
		imgui.Separator()
		configHelpers.input("showHiddenCostumes")
		configHelpers.input("unlockAllCostumes")
		imgui.Separator()
		configHelpers.input("realCostumes")
		configHelpers.input("liveRealCostumes")
		configHelpers.input("showCrankyLeft")
		configHelpers.input("lightModeBetterCostumes")
		imgui.Separator()
		configHelpers.input("favoriteKey")
		configHelpers.input("selectiveRandomness")
	end

	local width = self.previewSize + self.style.WindowPadding.x * 2
	local height = self.previewSize + self.style.WindowPadding.y * 2 + self.style.ItemSpacing.y + imgui.GetFontSize()
	local childSize = imgui.ImVec2_Float(width, height)

	local first = true
	for _, id in ipairs(self.costumesSorted) do
		local costume = Costumes[id]
		local costumeName = self:getName(id)
		local tooltip = self:getDesc(id)

		if not first then
			imgui.SameLine()
			if imgui.GetContentRegionAvail().x < width then imgui.NewLine() end
		end
		local pos = imgui.GetCursorPos()
		imgui.SetNextItemAllowOverlap()
		imgui.InvisibleButton("##invisibleButton" .. id, childSize)
		if imgui.IsItemVisible() then
			local hovered = imgui.IsItemHovered()
			if hovered and self:isUnlocked(id) and id ~= "random" then
				hoveredCostume = id
				if id ~= "none" and utilitools.keybinds.mod.pressed(mod, "favoriteKey") then
					self:playSound(sounds.optionsMenu.moveSounds)
					mod.config.favorites[id] = not self:isFavorite(id) or nil
				end
			end
			if imgui.IsItemClicked(0) then self:setCostume(id) end
			if imgui.IsItemClicked(1) then self:editCostume(id) end
			if imgui.IsItemClicked(2) and self:isUnlocked(id) and self:randomEnabled() then
				self:playSound(sounds.optionsMenu.clickSounds)
				mod.config.selectedRandomness[id] = not self:isPotential(id) or nil
				if not self:isPotential(id) then
					if utilitools.table.emptyTable(mod.config.selectedRandomness) then
						mod.config.selectedRandomness.none = true
					end
					if self.p and id == self.p.randomCostume then
						local array = utilitools.table.keysToValues(mod.config.selectedRandomness)
						self.p.randomCostume = array[math.random(#array)] or "none"
					end
				end
			end
			if tooltip then utilitools.imguiHelpers.tooltip(tooltip) end

			imgui.SetCursorPos(pos)
			if self:isActive(id) then
				imgui.PushStyleColor_U32(imgui.ImGuiCol_ChildBg, imgui.GetColorU32_Col(imgui.ImGuiCol_HeaderActive))
			elseif hovered and self:isUnlocked(id) then
				imgui.PushStyleColor_U32(imgui.ImGuiCol_ChildBg, imgui.GetColorU32_Col(imgui.ImGuiCol_HeaderHovered))
			elseif self:isPotential(id) then
				imgui.PushStyleColor_U32(imgui.ImGuiCol_ChildBg, imgui.GetColorU32_Col(imgui.ImGuiCol_Header))
			end

			imgui.BeginChild_Str(costumeName .. "##" .. id, childSize, imgui.ImGuiChildFlags_Border + imgui.ImGuiChildFlags_AutoResizeY + imgui.ImGuiChildFlags_AlwaysAutoResize, imgui.ImGuiWindowFlags_NoInputs)

			local pos1 = imgui.GetCursorPos()
			imgui.NewLine()

			if costume.preview then
				local pos2 = imgui.GetCursorPos()
				local canv
				if self.p and (mod.config.realCostumes == "always" or (mod.config.realCostumes == "hover" and hovered) or (mod.config.realCostumes == "antihover" and not hovered)) then
					if mod.config.liveRealCostumes then
						canv = self.canvs[id]
						love.graphics.setCanvas(canv)
						love.graphics.clear()
						self.p.x = self.previewSize / 2
						self.p.y = self.previewSize / 2
						self.p.drawScale = 1
						self.p.lineWidth = 2

						self.p.forceCostume = id
						self.p:draw()
					else canv = self.canvs2[id] end
				end
				imgui.Image(canv or costume.preview, imgui.ImVec2_Float(costume.preview:getWidth(), costume.preview:getHeight()), nil, nil, not self:isUnlocked(id) and imgui.ImVec4_Float(0.5, 0.5, 0.5, 1) or nil)
				if not self:isUnlocked(id) then
					imgui.SetCursorPosX(pos2.x + (self.previewSize - self.lockSize) / 2)
					imgui.SetCursorPosY(pos2.y + (self.previewSize - self.lockSize) / 2)
					imgui.Image(sprites.lock, imgui.ImVec2_Float(self.lockSize, self.lockSize))
				end
				if self:isActive(id) then
					imgui.SetCursorPosX(pos2.x + (self.previewSize - self.checkSize) / 2)
					imgui.SetCursorPosY(pos2.y + (self.previewSize - self.checkSize) / 2)
					imgui.Image(sprites.checkmark, imgui.ImVec2_Float(self.checkSize, self.checkSize))
				end
				if self:isFavorite(id) then
					imgui.SetCursorPos(pos2)
					imgui.Image(sprites.menu.atomMapSRank, imgui.ImVec2_Float(self.starSizeX, self.starSizeY))
				end
			end

			imgui.SetCursorPos(pos1)
			imgui.TextWrapped(costumeName)

			imgui.EndChild()

			if self:isActive(id) or self:isPotential(id) or (hovered and self:isUnlocked(id)) then imgui.PopStyleColor() end
		end

		first = false
	end

	if not hoveredCostume and self.p then self.p.forceCostume = nil end

	imgui.End()

	if appliedBBPTheme then bbp.gui.popStyle() end

	if self.p then
		self.p.x = ({ never = 300, behind = 300, ["1/3"] = 300 + 300 * 2 / 3, ["1/2"] = 300 + 300 * 1 / 2, ["2/3"] = 300 + 300 * 1 / 3 })[mod.config.showCrankyLeft] or 300
		self.p.y = 180
		self.p.drawScale = 2
		self.p.lineWidth = 3
		self.p.forceCostume = hoveredCostume
	end
	love.graphics.setCanvas(oldCanv)
end)

return st
