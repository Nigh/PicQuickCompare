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
picture_array := [-1, -1]
hBitmap_cache := []
#include Gdip_All.ahk
pGDI := Gdip_Startup()

mygui := Gui("-AlwaysOnTop -Owner")
myGui.OnEvent("Close", myGui_Close)
myGui.OnEvent("DropFiles", mygui_DropFiles)
mygui.SetFont("s32 Q5", "Meiryo")
mygui.Add("Text", "x20 y10 Section", "PicQuickCompare")
mygui.SetFont("s10 Q5", "Meiryo")
mygui.Add("Text", "x+20 y+-52", "v" . version)
mygui.Add("Link", "xp y+0", 'bilibili: <a href="https://space.bilibili.com/895523">下限Nico</a>')
mygui.Add("Link", "xp y+0", 'GitHub: <a href="https://github.com/Nigh">xianii</a>')
pic := mygui.Add("Picture", "x20 w500 h400 0xE 0x200 0x800000 -0x40")
pic.OnEvent("Click", pic_on_click)
mygui.Show("AutoSize")

if (A_Args.Length > 0) {
	para_pic := Array()
	for n, GivenPath in A_Args {
		Loop Files, GivenPath, "F"  ; Include files and directories.
			para_pic.Push(A_LoopFileFullPath)
	}
	if (para_pic.Length > 0) {
		mygui_DropFiles(mygui, 0, para_pic, 0, 0)
	}
}
HotIfWinActive "ahk_id" mygui.Hwnd
Hotkey "Esc", myGui_Close
HotIf
Return

pic_on_click(thisGui, GuiCtrlObj) {
	global picture_array, pic
	if (picture_array[2] > 0) {
		mygui_ctrl_show_pic(pic, picture_array[2])
		KeyWait "LButton"
		mygui_ctrl_show_pic(pic, picture_array[1])
	}
}

create_pic_bitmap_cache() {
	global picture_array, pic, DPIScale
	pic.GetPos(, , , &ctrlH)
	loop 2 {
		if (picture_array[A_Index] < 0) {
			break
		}
		hBitmap_cache.Push({ pBitmap: 0, pBitmapShow: 0, G: 0, hBitmapShow: 0 })
		hBitmap_cache[hBitmap_cache.Length].pBitmap := picture_array[A_Index]
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
	global picture_array, pic, Screen_Width, Screen_Height, DPIScale
	h_max := 0
	w_max := 0
	ratio := 0
	W := 0
	H := 0
	loop 2 {
		if (picture_array[A_Index] > 0) {
			Gdip_GetImageDimensions(picture_array[A_Index], &W, &H)
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
	if (h_max > maxH * DPIScale) {
		percent := Min(percent, maxH / h_max)
	}
	if (w_max > maxW * DPIScale) {
		percent := Min(percent, maxW / w_max)
	}
	ctrlH := Round(h_max * percent) + 1
	ctrlW := Round(ctrlH * ratio) + 1
	MsgBox("hmax=" h_max "`nW=" W "`nctrlW=" ctrlW "`nH=" H "`nctrlH=" ctrlH "`nDPIScale=" DPIScale)
	pic.Move(20, , ctrlW, ctrlH)
	pic.gui.Show("AutoSize")
	pic.Redraw()
}

mygui_set_pic_size(picW, picH)
{
	global Screen_Width, Screen_Height, pic
	minW := 400
	minH := 400
	maxW := 0.5 * Screen_Width
	maxH := 0.7 * Screen_Height

	percentW := maxW / picW
	percentH := maxH / picH
	percentMin := Min(percentW, percentH)

	if (percentMin < 1) {
		ctrlW := picW * percentMin < minW ? minW : picW * percentMin
		ctrlH := picH * percentMin < minH ? minH : picH * percentMin
		percent := percentMin
	} else {
		ctrlW := picW < minW ? minW : picW
		ctrlH := picH < minH ? minH : picH
		percent := 1
	}
	pic.Move(20, , ctrlW, ctrlH)
	pic.gui.Show("AutoSize")
	pic.Redraw()
	Return percent
}

mygui_ctrl_show_pic(GuiCtrlObj, pBitmap)
{
	global hBitmap_cache
	loop 2 {
		if (hBitmap_cache[A_Index].pBitmap == pBitmap) {
			SetImage(GuiCtrlObj.hwnd, hBitmap_cache[A_Index].hBitmapShow)
			return
		}
	}
	GuiCtrlObj.GetPos(, , , &ctrlH)
	Gdip_GetImageDimensions(pBitmap, &W, &H)
	percent := ctrlH / H
	picW := W * percent
	picH := H * percent
	pBitmapShow := Gdip_CreateBitmap(picW, picH)
	G := Gdip_GraphicsFromImage(pBitmapShow)
	Gdip_SetSmoothingMode(G, 4)
	Gdip_SetInterpolationMode(G, 7)
	Gdip_DrawImage(G, pBitmap, 0, 0, picW, picH)
	hBitmapShow := Gdip_CreateHBITMAPFromBitmap(pBitmapShow)
	SetImage(GuiCtrlObj.hwnd, hBitmapShow)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapShow), DeleteObject(hBitmapShow)
}

mygui_DropFiles(GuiObj, GuiCtrlObj, FileArray, X, Y) {
	global picture_array, pic
	local valid := 0
	local picture
	GuiObj.Opt("+OwnDialogs")
	loop 2 {
		if (A_Index <= FileArray.Length) {
			picture := Gdip_CreateBitmapFromFile(FileArray[FileArray.Length + 1 - A_Index])
			if (picture > 0) {
				valid += 1
				picture_array[2] := picture_array[1]
				picture_array[1] := picture
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
