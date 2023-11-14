h2FontStyle := "s" DPIScaled(18) " w600 c505050 q5"
textFontStyle := "s" DPIScaled(10) " w400 cblack q5"
clientWidth := DPIScaled(360)
header_gap := " y+" DPIScaled(10) " "
item_gap := " y+" DPIScaled(3) " "
buttonWidth := DPIScaled(150)
hotkeyWinWidth := DPIScaled(80)
padding := DPIScaled(20)

pqc_setup := Gui("+ToolWindow +AlwaysOnTop -SysMenu -DPIScale +OwnDialogs +Owner" mygui.Hwnd, "setup")

if A_IsCompiled {
	pqc_setup.Add("Picture", "x" gui_margin " y" gui_margin " h" DPIScaledFont(32) * 2 " w-1 Section", "HBITMAP:" HBitmapFromResource("app_title.png"))
} else {
	pqc_setup.Add("Picture", "x" gui_margin " y" gui_margin " h" DPIScaledFont(32) * 2 " w-1 Section", "app_title.png")
}

pqc_setup.SetFont(, "Consolas")
pqc_setup.SetFont(, "Comic Sans MS")
pqc_setup.SetFont(, "Segoe UI")

pqc_setup.SetFont("s" DPIScaledFont(32) " w700 cc07070")

pqc_setup.Add("Text", "x+0 y" DPIScaled(5), "Setup")

pqc_setup.SetFont(h2FontStyle)
pqc_setup.Add("Text", "x" padding " y+" DPIScaled(10) " section", "Position")
pqc_setup.SetFont(textFontStyle)
setup_position := Array()
setup_position.Push(pqc_setup.Add("Radio", item_gap "w" (clientWidth - 2 * padding) // 4, "free"))
setup_position.Push(pqc_setup.Add("Radio", "x+0 wp", "left"))
setup_position.Push(pqc_setup.Add("Radio", "x+0 wp", "center"))
setup_position.Push(pqc_setup.Add("Radio", "x+0 wp", "right"))

pqc_setup.SetFont(h2FontStyle)
pqc_setup.Add("Text", "xs " header_gap, "Max Width")
pqc_setup.SetFont(textFontStyle)
width_range := " Range" Screen_Width // 4 "-" Screen_Width - 4 * mygui.MarginX " TickInterval" Screen_Width // 12 " "
setup_maxwidth := pqc_setup.Add("Slider", "ToolTipBottom Thick" width_range item_gap "w" clientWidth - 2 * padding, Screen_Width - 4 * mygui.MarginX)

pqc_setup.SetFont(h2FontStyle)
pqc_setup.Add("Text", "xs " header_gap, "Max Height")
pqc_setup.SetFont(textFontStyle)
height_range := " Range" Screen_Height // 4 + info_height "-" Screen_Height - 4 * mygui.MarginY - info_height - DPIScaled(20) " TickInterval" Screen_Height // 12 " "
setup_maxheight := pqc_setup.Add("Slider", "ToolTipBottom Thick" height_range item_gap "w" clientWidth - 2 * padding, Screen_Width - 4 * mygui.MarginX)

pqc_setup.SetFont(h2FontStyle)
pqc_setup.Add("Text", "xs " header_gap, "Mode")
pqc_setup.SetFont(textFontStyle)
setup_mode := pqc_setup.Add("CheckBox", "Checked" settings.runbackgroud item_gap, "runs in background")
setup_mode.OnEvent("Click", compare_hotkey_state_update)

pqc_setup.SetFont(h2FontStyle)
pqc_setup.Add("Text", "xs " header_gap, "Hotkeys")

pqc_setup.SetFont(textFontStyle)
setup_hotkey_swap := pqc_setup.Add("Hotkey", item_gap "w" clientWidth - 2 * padding - hotkeyWinWidth)
setup_hotkeyWin1 := pqc_setup.Add("CheckBox", "x+10 hp w" hotkeyWinWidth, "win")
pqc_setup.SetFont("s10")
pqc_setup.Add("Text", "xs" item_gap, "Swap hotkey is ")
hotkey_swapText := pqc_setup.Add("Text", "x+0 hp cc07070 w260", "")
hotkey_swap_text_update := hotkey_text_update_func(setup_hotkey_swap, setup_hotkeyWin1, hotkey_swapText)
setup_hotkey_swap.OnEvent("Change", hotkey_swap_text_update)
setup_hotkeyWin1.OnEvent("Click", hotkey_swap_text_update)

pqc_setup.SetFont(textFontStyle)
setup_hotkey_close := pqc_setup.Add("Hotkey", "xs " item_gap "w" clientWidth - 2 * padding - hotkeyWinWidth)
setup_hotkeyWin2 := pqc_setup.Add("CheckBox", "x+10 hp w" hotkeyWinWidth, "win")
pqc_setup.SetFont("s10")
pqc_setup.Add("Text", "xs" item_gap, "Close hotkey is ")
hotkey_closeText := pqc_setup.Add("Text", "x+0 hp cc07070 w260", "")
hotkey_close_text_update := hotkey_text_update_func(setup_hotkey_close, setup_hotkeyWin2, hotkey_closeText)
setup_hotkey_close.OnEvent("Change", hotkey_close_text_update)
setup_hotkeyWin2.OnEvent("Click", hotkey_close_text_update)

pqc_setup.SetFont(textFontStyle)
setup_hotkey_compare := pqc_setup.Add("Hotkey", "xs " item_gap "w" clientWidth - 2 * padding - hotkeyWinWidth)
setup_hotkeyWin3 := pqc_setup.Add("CheckBox", "x+10 hp w" hotkeyWinWidth, "win")
pqc_setup.SetFont("s10")
pqc_setup.Add("Text", "xs" item_gap, "Compare hotkey is ")
hotkey_compareText := pqc_setup.Add("Text", "x+0 hp cc07070 w260", "")
hotkey_compare_text_update := hotkey_text_update_func(setup_hotkey_compare, setup_hotkeyWin3, hotkey_compareText)
setup_hotkey_compare.OnEvent("Change", hotkey_compare_text_update)
setup_hotkeyWin3.OnEvent("Click", hotkey_compare_text_update)

pqc_setup.SetFont(textFontStyle)
saveBtn := pqc_setup.Add("Button", "xs y+" DPIScaled(10) " h" DPIScaled(50) " w" buttonWidth, "Save")
cancelBtn := pqc_setup.Add("Button", "x+" DPIScaled(10) " hp w" buttonWidth, "Cancel")
saveBtn.OnEvent("Click", pqc_setup_save)
cancelBtn.OnEvent("Click", pqc_setup_cancel)

pqc_setup.SetFont("s" DPIScaled(6))
pqc_setup.Add("Link", "xs y+0 w" clientWidth - 3 * padding " right", 'Visit <a href="https://github.com/Nigh/PicQuickCompare">GitHub Page</a> for more info')
pqc_setup.OnEvent("Close", pqc_setup_cancel)

pqc_setup_cancel(*) {
	global
	pqc_setup.Hide()
	mygui.Opt("-Disabled")
	mygui.Show("NA")
}

compare_hotkey_state_update(*) {
	global
	if (setup_mode.Value > 0) {
		setup_hotkey_compare.Opt("-Disabled")
		setup_hotkeyWin3.Opt("-Disabled")
		hotkey_compare_text_update()
	} else {
		setup_hotkey_compare.Opt("+Disabled")
		setup_hotkeyWin3.Opt("+Disabled")
		hotkey_compareText.Value := "Disabled"
	}
}

pqc_setup_save(*) {
	global
	for k, v in setup_position {
		if (v.Value) {
			settings.postion := k
			break
		}
	}
	settings.max_width := setup_maxwidth.Value
	settings.max_height := setup_maxheight.Value
	settings.runbackgroud := setup_mode.Value

	settings.hotkey_swap := setup_hotkey_swap.Value
	settings.hotkey_close := setup_hotkey_close.Value
	settings.hotkey_compare := setup_hotkey_compare.Value

	if (setup_hotkeyWin1.Value) {
		settings.hotkey_swap := "#" settings.hotkey_swap
	}
	if (setup_hotkeyWin2.Value) {
		settings.hotkey_close := "#" settings.hotkey_close
	}
	if (setup_hotkeyWin3.Value) {
		settings.hotkey_compare := "#" settings.hotkey_compare
	}

	setupStr := "position=" settings.postion
	setupStr .= "`nwidth=" settings.max_width
	setupStr .= "`nheight=" settings.max_height
	setupStr .= "`nrunbackgroud=" settings.runbackgroud
	IniWrite(setupStr, "setting.ini", "setup")

	setupStr := "swap=" settings.hotkey_swap
	setupStr .= "`nclose=" settings.hotkey_close
	setupStr .= "`ncompare=" settings.hotkey_compare
	IniWrite(setupStr, "setting.ini", "hotkey")

	if (settings.runbackgroud != settings.init_mode) {
		MsgBox("Mode Changed`nIn order for the changes to take effect`nPQC is is about to be restarted", "OK", "Owner" pqc_setup.Hwnd)
		Reload
	}
	if (settings.init_hotkeys != settings.hotkey_swap "|" settings.hotkey_close "|" settings.hotkey_compare) {
		MsgBox("Hotkey Changed`nIn order for the changes to take effect`nPQC is is about to be restarted", "OK", "Owner" pqc_setup.Hwnd)
		Reload
	}
	pqc_setup_cancel()
}

hotkey_to_string(hotkey_str) {
	local output_str := ""
	if (InStr(hotkey_str, "#")) {
		output_str .= "Win + "
	}
	if (InStr(hotkey_str, "^")) {
		output_str .= "Ctrl + "
	}
	if (InStr(hotkey_str, "!")) {
		output_str .= "Alt + "
	}
	if (InStr(hotkey_str, "+")) {
		output_str .= "Shift + "
	}
	output_str .= RegExReplace(hotkey_str, "#|\^|\!|\+|\<|\>")
	Return output_str
}

hotkey_text_update_func(setup_hotkey, setup_win, hotkey_text) {
	fn(*) {
		local output_str := ""
		hotkey_str := setup_hotkey.Value
		if (setup_win.Value) {
			hotkey_str := "#" setup_hotkey.Value
		}
		hotkey_text.Value := hotkey_to_string(hotkey_str)
	}
	return fn
}

pqc_setup_show() {
	global
	setup_position[settings.postion].Value := 1
	setup_maxwidth.Value := settings.max_width
	setup_maxheight.Value := settings.max_height

	setup_hotkey_swap.Value := RegExReplace(settings.hotkey_swap, "#")
	setup_hotkeyWin1.Value := RegExMatch(settings.hotkey_swap, "#")
	hotkey_swap_text_update()
	setup_hotkey_close.Value := RegExReplace(settings.hotkey_close, "#")
	setup_hotkeyWin2.Value := RegExMatch(settings.hotkey_close, "#")
	hotkey_close_text_update()
	setup_hotkey_compare.Value := RegExReplace(settings.hotkey_compare, "#")
	setup_hotkeyWin3.Value := RegExMatch(settings.hotkey_compare, "#")
	hotkey_compare_text_update()
	compare_hotkey_state_update()
	setup_mode.Value := settings.runbackgroud

	pqc_setup.Show("yCenter w" clientWidth)
	mygui.Opt("+Disabled")
}
; enable for test
; pqc_setup_show()
