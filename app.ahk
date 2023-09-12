#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)
#SingleInstance force
#include meta.ahk
;@Ahk2Exe-SetName %appName%
;@Ahk2Exe-SetVersion %version%
;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-ExeName %appName%
;@Ahk2Exe-AddResource *10 %A_ScriptDir%\app_title.png

#include prod.ahk

; if you need admin privilege, enable it.
if (0)
{
	UAC()
}
#include update.ahk
setTray()
OnExit(trueExit)

; ===============================================================
; ===============================================================
; your code below

MonitorGet(1, &Left, &Top, &Right, &Bottom)
DPIScale := A_ScreenDPI / 96
Screen_Height := Bottom - Top
Screen_Width := Right - Left
picture_array := []
loop 2
	picture_array.Push({
		name: '',
		pBitmap: -1,
		exif: '',
		pBitmapShow: 0,
		G: 0,
		hBitmapShow: 0
	})

if (IniRead("setting.ini", "setup", "autocenter", "1") == "1") {
	setting_autoCenter := "center"
	autoCenter_default_check := "Checked1"
} else {
	setting_autoCenter := ""
	autoCenter_default_check := "Checked0"
}

if (IniRead("setting.ini", "setup", "runbackgroud", "0") == "1") {
	setting_runbackgroud := 1
	runbackgroud_default_check := "Checked1"
} else {
	setting_runbackgroud := 0
	runbackgroud_default_check := "Checked0"
}

#include Gdip_All.ahk
pGDI := Gdip_Startup()

mygui := Gui("-AlwaysOnTop -ToolWindow -SysMenu -Owner")
mygui.MarginX := 10
mygui.MarginY := 10
mygui.Title := appName
myGui.OnEvent("Close", myGui_Close)
myGui.OnEvent("DropFiles", mygui_DropFiles)
if A_IsCompiled {
	mygui.Add("Picture", "x10 y10 Section", "HBITMAP:" HBitmapFromResource("app_title.png"))
} else {
	mygui.Add("Picture", "x10 y10 Section", "app_title.png")
}

mygui.SetFont("s8 Q5 bold", "Comic Sans MS")
swapbtn := mygui.Add("Button", "xs y+5 h22 w90", 'SWAP(s)')
swapbtn.OnEvent("Click", swap)

autoCenterSwitch := mygui.Add("Checkbox", "x+10 yp hp " autoCenter_default_check, 'Auto Center')
autoCenterSwitch.OnEvent("Click", autoPosSwitch_cb)
backgroundSwitch := mygui.Add("Checkbox", "x+10 yp hp " runbackgroud_default_check, 'Runs in background')
backgroundSwitch.OnEvent("Click", backgroundSwitch_cb)

mygui.SetFont("s10 Q5 norm", "Comic Sans MS")
mygui.Add("Text", "xs y+0 h12", 'Current:')
txt_indicator := mygui.Add("Text", "x+10 yp hp w360", 'NULL')
txt_indicator.SetFont("cTeal bold")

mygui.Add("Text", "xs y+0 h12", 'EXIF:')
txt_exif := mygui.Add("Text", "x+10 yp hp w360", 'NULL')
txt_exif.SetFont("cNavy bold")

picCurrentShow := 1
pic := mygui.Add("Picture", "x10 y+0 w500 h400 0xE 0x200 0x800000 -0x40")
pic.OnEvent("Click", pic_on_click)
pic.OnEvent("DoubleClick", pic_on_click)

mygui.SetFont("s8 Q5 Norm", "Comic Sans MS")
info := Array()
info.Push(mygui.Add("Text", "x420 y12 h0", "v" . version))
info.Push(mygui.Add("Link", "xp y+0 hp", 'bilibili: <a href="https://space.bilibili.com/895523">TecNico</a>'))
info.Push(mygui.Add("Link", "xp y+0 hp", 'GitHub: <a href="https://github.com/Nigh">xianii</a>'))

if (setting_runbackgroud) {
	mygui.Show("AutoSize Hide")
} else {
	mygui.Show("AutoSize")
}

if (A_Args.Length > 0) {
	para_pic := Array()
	for n, GivenPath in A_Args {
		Loop Files, GivenPath, "F"
			para_pic.Push(A_LoopFileFullPath)
	}
	if (para_pic.Length > 0) {
		mygui_DropFiles(mygui, 0, para_pic, 0, 0)
	}
}
HotIfWinActive "ahk_id" mygui.Hwnd
if (setting_runbackgroud) {
	Hotkey "^w", myGui_Hide
	Hotkey "Esc", myGui_Hide
} else {
	Hotkey "^w", myGui_Close
	Hotkey "Esc", myGui_Close
}
Hotkey "Space", pic_on_click
Hotkey "s", swap
HotIf
if (setting_runbackgroud) {
	Hotkey "^q", copyCompare
	TrayTip("Runs in Background.`nSelect pictures and press Ctrl+Q to compare.", "PicQuickCompare", 1)
}
Return

copyCompare(GuiCtrlObj, info*) {
	global mygui
	A_Clipboard := ""
	Send("^c")
	if (!ClipWait(1)) {
		return
	}
	FileArray := []
	loop parse A_Clipboard, "`n", "`r" {
		FileArray.Push(A_LoopField)
	}
	mygui_DropFiles(mygui, 0, FileArray, 0, 0)
}

#include Filexpro.ahk
autoPosSwitch_cb(GuiCtrlObj, Info*) {
	global setting_autoCenter
	if (GuiCtrlObj.Value > 0) {
		setting_autoCenter := "center"
		IniWrite("1", "setting.ini", "setup", "autocenter")
	} else {
		setting_autoCenter := ""
		IniWrite("0", "setting.ini", "setup", "autocenter")
	}
	GuiCtrlObj.Opt("+Disabled")
	SetTimer(() => GuiCtrlObj.Opt("-Disabled"), -600)
}
backgroundSwitch_cb(GuiCtrlObj, Info*) {
	global setting_autoCenter
	if (GuiCtrlObj.Value > 0) {
		IniWrite("1", "setting.ini", "setup", "runbackgroud")
	} else {
		IniWrite("0", "setting.ini", "setup", "runbackgroud")
	}
	Reload
	; GuiCtrlObj.Opt("+Disabled")
	; SetTimer(() => GuiCtrlObj.Opt("-Disabled"), -600)
}
isSwapable() {
	global
	return picture_array[picCurrentShow ^ 0x3].pBitmap > 0
}
swap(GuiCtrlObj, Info*) {
	global picture_array, picCurrentShow
	if (isSwapable()) {
		picCurrentShow := picCurrentShow ^ 0x3
		mygui_ctrl_show_pic(picture_array[picCurrentShow])
	}
}

on_space(a) {
	if (isSwapable()) {
		swap("")
		KeyWait "Space"
		swap("")
	}
}
pic_on_click(thisGui, GuiCtrlObj*) {
	if (isSwapable()) {
		swap("")
		if (thisGui == "Space") {
			KeyWait "Space"
		} else {
			KeyWait "LButton"
		}
		swap("")
	}
}

create_pic_bitmap_cache(index) {
	global picture_array, pic, DPIScale

	if (picture_array[index].pBitmap < 0) {
		return
	}
	pic.GetPos(, , , &ctrlH)
	if (picture_array[index].G) {
		Gdip_DeleteGraphics(picture_array[index].G), Gdip_DisposeImage(picture_array[index].pBitmapShow), DeleteObject(picture_array[index].hBitmapShow)
	}

	Gdip_GetImageDimensions(picture_array[index].pBitmap, &W, &H)
	percent := ctrlH / H * DPIScale
	picW := W * percent
	picH := H * percent
	picture_array[index].pBitmapShow := Gdip_CreateBitmap(picW, picH)
	picture_array[index].G := Gdip_GraphicsFromImage(picture_array[index].pBitmapShow)
	Gdip_SetSmoothingMode(picture_array[index].G, 4)
	Gdip_SetInterpolationMode(picture_array[index].G, 7)
	Gdip_DrawImage(picture_array[index].G, picture_array[index].pBitmap, 0, 0, picW, picH)
	picture_array[index].hBitmapShow := Gdip_CreateHBITMAPFromBitmap(picture_array[index].pBitmapShow)
}

pic_ctrl_set_size() {
	global picture_array, pic, Screen_Width, Screen_Height, DPIScale, info
	h_max := 0
	w_max := 0
	ratio := 0
	W := 0
	H := 0
	loop 2 {
		if (picture_array[A_Index].pBitmap > 0) {
			Gdip_GetImageDimensions(picture_array[A_Index].pBitmap, &W, &H)
			if (H > h_max) {
				h_max := H
			}
			if (W > w_max) {
				w_max := W
			}
			if (W / H > ratio) {
				ratio := W / H
			}
		}
	}

	minW := 400
	minH := 400
	maxW := 0.95 * Screen_Width / DPIScale
	maxH := 0.85 * Screen_Height / DPIScale

	percent := 1
	if (h_max > maxH / DPIScale) {
		percent := Min(percent, maxH / h_max)
	}
	if (w_max > maxW / DPIScale) {
		percent := Min(percent, maxW / w_max)
	}
	ctrlH := Round(h_max * percent) + 1
	ctrlW := Round(ctrlH * ratio) + 1
	; MsgBox("h_max=" h_max "`nw_max=" w_max "`nmaxH=" maxH "`nmaxW=" maxW)
	; MsgBox("W=" W "`nH=" H "`nctrlW=" ctrlW "`nctrlH=" ctrlH "`nDPIScale=" DPIScale "`npercent=" percent)
	pic.Move(10, , ctrlW, ctrlH)
	for _, inf in info {
		inf.Move(Max(ctrlW - 90, 410))
	}
	pic.gui.Show("AutoSize " setting_autoCenter)
	pic.gui.GetPos(&X, &Y, &Width, &Height)
	if (Y + Height >= 0.95 * Screen_Height / DPIScale) {
		pic.gui.Show("yCenter")
	}
	pic.Redraw()
}

mygui_ctrl_show_pic(picture)
{
	global txt_indicator, pic, mygui
	txt_indicator.Text := picture.name
	txt_exif.Text := picture.exif
	SetImage(pic.hwnd, picture.hBitmapShow)
}

mygui_DropFiles(GuiObj, GuiCtrlObj, FileArray, X, Y) {
	global picture_array, pic, picCurrentShow
	local valid := 0
	local bitmap
	GuiObj.Opt("+OwnDialogs")
	loop 2 {
		if (A_Index <= FileArray.Length) {
			fullpath := FileArray[FileArray.Length + 1 - A_Index]
			bitmap := Gdip_CreateBitmapFromFile(fullpath)
			if (bitmap > 0) {
				valid += 1
				Loop Files, fullpath, "F" {
					picCurrentShow := picCurrentShow ^ 0x3
					exinfo := Filexpro(A_LoopFileFullPath, "", "System.Photo.Orientation", "System.Photo.FNumber", "System.Photo.ISOSpeed", "System.Photo.FocalLength", "System.Photo.ExposureTime", "System.Photo.ExposureTimeNumerator", "System.Photo.ExposureTimeDenominator", "xInfo")
					if (StrLen(exinfo["System.Photo.FocalLength"]) > 0) {
						ex_focal := exinfo["System.Photo.FocalLength"] "mm"
						ex_apture := "F" exinfo["System.Photo.FNumber"]
						ex_ISO := "ISO" exinfo["System.Photo.ISOSpeed"]
						ex_exposure := ("0" exinfo["System.Photo.ExposureTime"]) + 0
						if (ex_exposure < 1) {
							ex_exposure := exinfo["System.Photo.ExposureTimeNumerator"] "/" exinfo["System.Photo.ExposureTimeDenominator"] "s"
						}
						exif := ex_focal "  " ex_apture "  " ex_exposure "  " ex_ISO
					} else {
						exif := "NULL"
					}
					if (exinfo["System.Photo.Orientation"] == "8") {
						Gdip_ImageRotateFlip(bitmap, 3)
					}
					if (exinfo["System.Photo.Orientation"] == "3") {
						Gdip_ImageRotateFlip(bitmap, 2)
					}
					if (exinfo["System.Photo.Orientation"] == "6") {
						Gdip_ImageRotateFlip(bitmap, 1)
					}
					picture_array[picCurrentShow].name := A_LoopFileName
					picture_array[picCurrentShow].pBitmap := bitmap
					picture_array[picCurrentShow].exif := exif
				}
			}
		}
	}
	if (valid) {
		pic_ctrl_set_size()
		loop 2
			create_pic_bitmap_cache(A_Index)
		mygui_ctrl_show_pic(picture_array[picCurrentShow])
	}
	if (!valid) {
		MsgBox "Invalid Files"
	}
}

myGui_Hide(thisGui) {
	global mygui
	mygui.Show("Hide")
}
mygui_Close(thisGui) {
	trueExit(0, 0)
}
trueExit(ExitReason, ExitCode) {
	ExitApp
}

HBitmapFromResource(resName) {
	hMod := DllCall("GetModuleHandle", "Ptr", 0, "Ptr")
	hRes := DllCall("FindResource", "Ptr", hMod, "Str", resName, "UInt", RT_RCDATA := 10, "Ptr")
	resSize := DllCall("SizeofResource", "Ptr", hMod, "Ptr", hRes)
	hResData := DllCall("LoadResource", "Ptr", hMod, "Ptr", hRes, "Ptr")
	pBuff := DllCall("LockResource", "Ptr", hResData, "Ptr")
	pStream := DllCall("Shlwapi\SHCreateMemStream", "Ptr", pBuff, "UInt", resSize, "Ptr")

	pBitmap := 0
	DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", pStream, "Ptr*", &pBitmap)
	; pBitmap := pGDI.CreateBitmapFromStream(pStream)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	Gdip_DisposeImage(pBitmap)
	ObjRelease(pStream)
	Return hBitmap
}

; ===============================================================
; ===============================================================

UAC()
{
	full_command_line := DllCall("GetCommandLine", "str")

	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
		try
		{
			if A_IsCompiled
				Run '*RunAs "' A_ScriptFullPath '" /restart'
			else
				Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
		}
		ExitApp
	}
}
#include tray.ahk
