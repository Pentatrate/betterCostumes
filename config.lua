if not utilitools then imgui.Text("Utilitools is disabled") return end
local configHelpers = utilitools.configHelpers
configHelpers.setMod(mod)

if imgui.BeginTabBar("beattoolsConfig") then
	if imgui.BeginTabItem("General##beattoolsConfig") then
		configHelpers.input("tooltips")
		configHelpers.presets.menuButtons()
		configHelpers.presets.updateOptions()
		imgui.Separator()
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
		imgui.EndTabItem("General##beattoolsConfig")
	end
	if imgui.BeginTabItem("Search##beattoolsConfig") then
		configHelpers.presets.search()
		imgui.EndTabItem("Search##beattoolsConfig")
	end
	imgui.EndTabBar()
end
