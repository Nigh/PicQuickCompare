#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)
#SingleInstance force
#include meta.ahk
;@Ahk2Exe-SetName %appName%
;@Ahk2Exe-SetVersion %version%
;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-ExeName %appName%

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
picture_array := [{ name: '', pBitmap: -1 }, { name: '', pBitmap: -1 }]
hBitmap_cache := []
#include Gdip_All.ahk
pGDI := Gdip_Startup()

mygui := Gui("-AlwaysOnTop -Owner")
myGui.OnEvent("Close", myGui_Close)
myGui.OnEvent("DropFiles", mygui_DropFiles)
mygui.SetFont("s32 Q5", "Meiryo")
mygui.Add("Text", "x20 y10 Section", "PicQuickCompare")
mygui.SetFont("s10 Q5", "Meiryo")
info := Array()
info.Push(mygui.Add("Text", "x420 y12", "v" . version))
info.Push(mygui.Add("Link", "xp y+0", 'bilibili: <a href="https://space.bilibili.com/895523">下限Nico</a>'))
info.Push(mygui.Add("Link", "xp y+0", 'GitHub: <a href="https://github.com/Nigh">xianii</a>'))
swapbtn := mygui.Add("Button", "xs y+0 h25", 'SWAP(s)')
swapbtn.OnEvent("Click", swap)
mygui.Add("Text", "x+10 yp+3 hp", 'Current:')
txt_indicator := mygui.Add("Text", "x+10 yp hp w300", 'NULL')
txt_indicator.SetFont("cTeal bold")
pic := mygui.Add("Picture", "x20 y+0 w500 h400 0xE 0x200 0x800000 -0x40")
pic.OnEvent("Click", pic_on_click)
pic.OnEvent("DoubleClick", pic_on_click)
mygui.Show("AutoSize")

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
Hotkey "^w", myGui_Close
Hotkey "Esc", myGui_Close
Hotkey "Space", pic_on_click
Hotkey "s", swap
HotIf
Return

swap(GuiCtrlObj, Info*) {
	global picture_array
	if (picture_array[2].pBitmap > 0) {
		tmp := picture_array[2]
		picture_array[2] := picture_array[1]
		picture_array[1] := tmp
		mygui_ctrl_show_pic(pic, picture_array[1])
	}
}

on_space(a) {
	global picture_array, pic
	if (picture_array[2].pBitmap > 0) {
		mygui_ctrl_show_pic(pic, picture_array[2])
		KeyWait "Space"
		mygui_ctrl_show_pic(pic, picture_array[1])
	}
}
pic_on_click(thisGui, GuiCtrlObj*) {
	global picture_array, pic
	if (picture_array[2].pBitmap > 0) {
		mygui_ctrl_show_pic(pic, picture_array[2])
		if (thisGui == "Space") {
			KeyWait "Space"
		} else {
			KeyWait "LButton"
		}
		mygui_ctrl_show_pic(pic, picture_array[1])
	}
}

create_pic_bitmap_cache() {
	global picture_array, pic, DPIScale
	pic.GetPos(, , , &ctrlH)
	loop 2 {
		if (picture_array[A_Index].pBitmap < 0) {
			break
		}
		hBitmap_cache.Push({ pBitmap: 0, pBitmapShow: 0, G: 0, hBitmapShow: 0 })
		hBitmap_cache[hBitmap_cache.Length].pBitmap := picture_array[A_Index].pBitmap
		Gdip_GetImageDimensions(hBitmap_cache[hBitmap_cache.Length].pBitmap, &W, &H)
		percent := ctrlH / H * DPIScale
		picW := W * percent
		picH := H * percent
		hBitmap_cache[hBitmap_cache.Length].pBitmapShow := Gdip_CreateBitmap(picW, picH)
		hBitmap_cache[hBitmap_cache.Length].G := Gdip_GraphicsFromImage(hBitmap_cache[hBitmap_cache.Length].pBitmapShow)
		Gdip_SetSmoothingMode(hBitmap_cache[hBitmap_cache.Length].G, 4)
		Gdip_SetInterpolationMode(hBitmap_cache[hBitmap_cache.Length].G, 7)
		Gdip_DrawImage(hBitmap_cache[hBitmap_cache.Length].G, hBitmap_cache[hBitmap_cache.Length].pBitmap, 0, 0, picW, picH)
		hBitmap_cache[hBitmap_cache.Length].hBitmapShow := Gdip_CreateHBITMAPFromBitmap(hBitmap_cache[hBitmap_cache.Length].pBitmapShow)
	}

	while (hBitmap_cache.Length > 2) {
		Gdip_DeleteGraphics(hBitmap_cache[1].G), Gdip_DisposeImage(hBitmap_cache[1].pBitmapShow), DeleteObject(hBitmap_cache[1].hBitmapShow)
		hBitmap_cache.RemoveAt(1)
	}
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
	pic.Move(20, , ctrlW, ctrlH)
	for _, inf in info {
		inf.Move(Max(ctrlW - 80, 420))
	}
	pic.gui.Show("AutoSize")
	pic.Redraw()
}

mygui_ctrl_show_pic(GuiCtrlObj, image)
{
	global hBitmap_cache, txt_indicator
	loop 2 {
		if (hBitmap_cache[A_Index].pBitmap == image.pBitmap) {
			SetImage(GuiCtrlObj.hwnd, hBitmap_cache[A_Index].hBitmapShow)
			txt_indicator.Text := image.name
			return
		}
	}
	GuiCtrlObj.GetPos(, , , &ctrlH)
	Gdip_GetImageDimensions(image.pBitmap, &W, &H)
	percent := ctrlH / H
	picW := W * percent
	picH := H * percent
	pBitmapShow := Gdip_CreateBitmap(picW, picH)
	G := Gdip_GraphicsFromImage(pBitmapShow)
	Gdip_SetSmoothingMode(G, 4)
	Gdip_SetInterpolationMode(G, 7)
	Gdip_DrawImage(G, image.pBitmap, 0, 0, picW, picH)
	hBitmapShow := Gdip_CreateHBITMAPFromBitmap(pBitmapShow)
	SetImage(GuiCtrlObj.hwnd, hBitmapShow)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapShow), DeleteObject(hBitmapShow)
}

mygui_DropFiles(GuiObj, GuiCtrlObj, FileArray, X, Y) {
	global picture_array, pic
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
					picture_array[2] := picture_array[1]
					picture_array[1] := { name: A_LoopFileName, pBitmap: bitmap }
				}
			}
		}
	}
	if (valid) {
		pic_ctrl_set_size()
		create_pic_bitmap_cache()
		mygui_ctrl_show_pic(pic, picture_array[1])
	}
	if (!valid) {
		MsgBox "Invalid Files"
	}
}
mygui_Close(thisGui) {
	trueExit(0, 0)
}
trueExit(ExitReason, ExitCode) {
	ExitApp
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
