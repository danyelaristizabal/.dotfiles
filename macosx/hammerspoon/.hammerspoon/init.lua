-- ~/.hammerspoon/init.lua  (stow package: .dotfiles/macosx/hammerspoon/.hammerspoon/init.lua)
--
-- Run-or-raise app hotkeys.
-- Requires: System Settings → Desktop & Dock → Mission Control →
--   "When switching to an application, switch to a Space with open windows" = ON
--   (macosx/install.sh enables this automatically via defaults write)

---------------------------------------------------------------------------
-- BINDINGS — edit this table, everything else is plumbing
---------------------------------------------------------------------------
local bindings = {
	{ mods = { "alt" }, key = "return", app = "Ghostty" },
	{ mods = { "alt" }, key = "c", app = "Google Chrome" },
	{ mods = { "alt" }, key = "v", app = "Vivaldi" },
	{ mods = { "alt" }, key = "s", app = "Slack" },
	{ mods = { "alt", "shift" }, key = "s", app = "Spotify" },
	{ mods = { "alt", "shift" }, key = "c", app = "Claude" },
	{ mods = { "alt" }, key = "b", app = "Bitwarden" },
	{ mods = { "alt" }, key = "t", app = "Sublime Text" },
}

-- Hotkey that shows all bindings on screen
local cheatsheetHotkey = { mods = { "alt" }, key = "/" }

---------------------------------------------------------------------------
-- Run or raise
---------------------------------------------------------------------------
hs.window.animationDuration = 0

local function runOrRaise(name)
	local app = hs.application.get(name)

	-- 1. Not running → launch
	if not app then
		hs.application.launchOrFocus(name)
		return
	end

	-- Hidden (Cmd+H) → unhide
	if app:isHidden() then
		app:unhide()
	end

	local wins = app:allWindows()

	-- 3. Has a normal window on this desktop → focus it
	for _, w in ipairs(wins) do
		if w:isStandard() and w:isVisible() and not w:isMinimized() then
			w:focus()
			return
		end
	end

	-- 2. Minimized to the Dock → restore and focus
	for _, w in ipairs(wins) do
		if w:isMinimized() then
			w:unminimize()
			w:focus()
			return
		end
	end

	-- 4. Windows only on another desktop (or no windows at all) →
	--    activating makes macOS switch to that Space; if the app has no
	--    windows anywhere, this also opens a new one (like clicking the Dock icon).
	hs.application.launchOrFocus(name)
end

---------------------------------------------------------------------------
-- Wire it up
---------------------------------------------------------------------------
local function prettyMods(mods)
	local symbols = { cmd = "⌘", alt = "⌥", ctrl = "⌃", shift = "⇧" }
	local out = ""
	for _, m in ipairs(mods) do
		out = out .. (symbols[m] or m)
	end
	return out
end

local lines = {}
for _, b in ipairs(bindings) do
	hs.hotkey.bind(b.mods, b.key, function()
		runOrRaise(b.app)
	end)
	table.insert(lines, string.format("%s%s  →  %s", prettyMods(b.mods), b.key:upper(), b.app))
end

---------------------------------------------------------------------------
-- Window management
---------------------------------------------------------------------------
local function moveWindow(action)
	local win = hs.window.focusedWindow()
	if not win then return end
	local screen = win:screen():frame()

	local frames = {
		maximize = { x = screen.x, y = screen.y, w = screen.w, h = screen.h },
		left     = { x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h },
		right    = { x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h },
	}

	win:setFrame(frames[action])
end

local windowBindings = {
	{ mods = { "alt" }, key = "m", action = "maximize", label = "Maximize" },
	{ mods = { "alt" }, key = "h", action = "left",     label = "Left half" },
	{ mods = { "alt" }, key = "l", action = "right",    label = "Right half" },
}

local windowLines = {}
for _, b in ipairs(windowBindings) do
	hs.hotkey.bind(b.mods, b.key, function()
		moveWindow(b.action)
	end)
	table.insert(windowLines, string.format("%s%s  →  %s", prettyMods(b.mods), b.key:upper(), b.label))
end

hs.hotkey.bind(cheatsheetHotkey.mods, cheatsheetHotkey.key, function()
	local all = {}
	for _, l in ipairs(lines) do table.insert(all, l) end
	table.insert(all, "")
	for _, l in ipairs(windowLines) do table.insert(all, l) end
	hs.alert.show(table.concat(all, "\n"), 3)
end)

---------------------------------------------------------------------------
-- Auto-reload when the config changes (follows the stow symlink)
---------------------------------------------------------------------------
configWatcher = hs.pathwatcher
	.new(hs.configdir, function(files)
		for _, f in ipairs(files) do
			if f:sub(-4) == ".lua" then
				hs.reload()
				return
			end
		end
	end)
	:start()

hs.alert.show("Hammerspoon config loaded")
