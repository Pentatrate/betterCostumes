return {
	tooltips = {
		type = "combo",
		name = "Tooltips",
		tooltips = { short = "Tooltip length when hovering" },
		values = { "long", "short", "none" },
		valueTooltips = {
			{ long = "When hovering over menu options, display a detailed tooltip", short = "Display detailed tooltip" },
			{ short = "Shorten tooltip" }
		},
		default = "long"
	},
	search = {
		type = "text",
		name = "Search",
		tooltips = { short = "Search for configs" },
		default = "",
		off = ""
	},

	selectiveRandomness = {
		type = "bool",
		name = "Select Random Pool",
		tooltips = { short = "Select the costume pool that gets randomized for the random costume" },
		default = false,
		off = false
	},
	favoriteKey = {
		type = "key",
		name = "Favorite Hotkey",
		tooltips = { short = "Favorite certain costumes" },
		default = { { {}, "key:f" } }
	},
	showHiddenCostumes = {
		type = "bool",
		name = "Show Hidden Costumes",
		tooltips = { short = "Shows hidden costumes" },
		default = false,
		off = false
	},
	unlockAllCostumes = {
		type = "bool",
		name = "Unlock All Costumes",
		tooltips = { short = "Forces all costumes to be unlocked" },
		default = false,
		off = false
	},
	showCrankyLeft = {
		type = "combo",
		name = "Show Cranky",
		tooltips = { short = "Shows cranky on the left" },
		values = { "never", "behind", "1/3", "1/2", "2/3" },
		valueTooltips = {
			{ short = "Hides cranky" },
			{ short = "Puts cranky behind the imgui window" },
			{ short = "Leaves 1/3 of the screen to show cranky" },
			{ short = "Leaves 1/2 of the screen to show cranky" },
			{ short = "Leaves 2/3 of the screen to show cranky" }
		},
		default = "behind"
	},
	lightModeBetterCostumes = {
		type = "bool",
		name = "Light Mode",
		tooltips = { short = "Turns on light mode for Better Costumes" },
		default = false
	},
	betterCostumes = {
		type = "bool",
		name = "Better Costumes",
		tooltips = { short = "Shows the Better Costumes menu option" },
		default = true,
		off = false
	},
	realCostumes = {
		type = "combo",
		name = "Real Costumes",
		tooltips = { short = "Show the real cosumtes instead of the preview" },
		values = { "never", "hover", "antihover", "always" },
		valueTooltips = {
			{ short = "Always shows the preview" },
			{ short = "Shows the real costume on hover" },
			{ short = "Shows the preview on hover" },
			{ short = "Always shows the real costume" }
		},
		default = "hover"
	},
	liveRealCostumes = {
		type = "combo",
		name = "Live Real Costumes",
		tooltips = { short = "Updates cranky in real time\nCauses more lag" },
		values = { "never", "parallel", "independent" },
		valueTooltips = {
			{ short = "Show a frozen cranky in different costumes" },
			{ short = "Show the same live cranky in different costumes\nCauses lag" },
			{ short = "Show different live crankies in different costumes\nCauses lots of lag" }
		},
		default = "never"
	},
	zoom = {
		type = "float",
		name = "Size",
		tooltips = { short = "Multiplies the Previews by a certain size" },
		default = 1
	},

	-- Internal Variables (as a replacement instead of using global variables)
	searches = {
		type = "hidden",
		name = "[internal] searches",
		default = {}
	},
	selectedRandomness = {
		type = "hidden",
		name = "[internal] selectedRandomness",
		default = { none = true }
	},
	favorites = {
		type = "hidden",
		name = "[internal] favorites",
		default = {}
	}
}
