local wezterm = require 'wezterm'

local wsl_domains = wezterm.default_wsl_domains()


wezterm.on("gui-startup", function(cmd)
  local _, first_pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window()
end)

for _, domain in ipairs(wsl_domains) do
  domain.default_cwd = "~"
end

local config =  {
  enable_wayland = false,
  adjust_window_size_when_changing_font_size = false,
  audible_bell = 'Disabled',
  color_scheme = 'Catppuccin Frappe',
  disable_default_key_bindings = true,
  exit_behavior = 'Close',
  font = wezterm.font('JetBrains Mono', { weight = 'Bold', italic = false }),
  font_size = 12,
  force_reverse_video_cursor = true,
  hide_mouse_cursor_when_typing = true,
  hide_tab_bar_if_only_one_tab = true,
  keys = {
    { action = wezterm.action.ActivateCommandPalette, mods = 'CTRL|SHIFT', key =     'P' },
    { action = wezterm.action.CopyTo    'Clipboard' , mods = 'CTRL|SHIFT', key =     'C' },
    { action = wezterm.action.DecreaseFontSize      , mods =       'CTRL', key =     '-' },
    { action = wezterm.action.IncreaseFontSize      , mods =       'CTRL', key =     '=' },
    { action = wezterm.action.Nop                   , mods =        'ALT', key = 'Enter' },
    { action = wezterm.action.PasteFrom 'Clipboard' , mods = 'CTRL|SHIFT', key =     'V' },
    { action = wezterm.action.ResetFontSize         , mods =       'CTRL', key =     '0' },
    { action = wezterm.action.SplitHorizontal, mods = 'CTRL|SHIFT', key = '|' },  -- split terminal horizontally
    { action = wezterm.action.SplitVertical, mods = 'CTRL|SHIFT', key = '_' },  -- split terminal vertically
    { action = wezterm.action.CloseCurrentPane { confirm = true }, mods = 'CTRL|SHIFT', key = 'W' },  -- close current pane
    { action = wezterm.action.PaneSelect, mods = 'CTRL|SHIFT', key = 'Tab' },
    { action = wezterm.action.PaneSelect {mode = 'MoveToNewTab' }, mods = 'CTRL|SHIFT', key = 'M' },  -- close current pane
    { action = wezterm.action.SpawnTab 'CurrentPaneDomain', mods = 'CTRL|SHIFT', key = 'T' },
  },
  scrollback_lines = 10000,
  show_update_window = true,
  use_dead_keys = false,
  unicode_version = 15,
  macos_window_background_blur = 100,
  window_close_confirmation = 'NeverPrompt',
  adjust_window_size_when_changing_font_size = false,
  window_background_opacity = 1,  -- transparency  
  audible_bell = 'Disabled',
  window_padding = {
    left = 0,
    right = 0,
    top =  '0.3cell',
    bottom = 0,
  },
  wsl_domains = wsl_domains
}
 -- Add tab commands
for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL|ALT',
    action = wezterm.action.ActivateTab(i - 1),
  })

end

return config

