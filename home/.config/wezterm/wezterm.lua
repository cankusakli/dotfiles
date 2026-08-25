local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Dim unfocused windows' text (not the background) so the focused one is
-- obvious at a glance, without making the window see-through.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
	if actual == nil or expected == nil then
		return actual == expected
	end
	return actual.hue == expected.hue
		and actual.saturation == expected.saturation
		and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	local text_hsb
	if not window:is_focused() then
		text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
	end

	-- Only write when the value we own actually changes; a redundant
	-- set_config_overrides() call would trigger another config reload.
	if same_text_hsb(overrides.foreground_text_hsb, text_hsb) then
		return
	end

	overrides.foreground_text_hsb = text_hsb
	window:set_config_overrides(overrides)
end)

return config
