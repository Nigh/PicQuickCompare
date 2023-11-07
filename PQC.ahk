if (A_IsCompiled) {
	debugBorder := ""
} else {
	debugBorder := "Border "
}
MonitorGet(0, &Left, &Top, &Right, &Bottom)
DPIScale := A_ScreenDPI / 96
DPIScaled(n) {
	return Round(n * DPIScale)
}
DPIScaledFont(n) {
	return Round(n * (DPIScale ** 0.5))
}
Screen_Height := Bottom - Top
Screen_Width := Right - Left
gui_margin := DPIScaled(10)
picture_array := []
loop 2
	picture_array.Push({
		name: '',
		pBitmap: -1,
		exif: Object(),
		exifstr: '',
		fileSize: '',
		picSize: '',
		pBitmapShow: 0,
		GShow: 0,
		hBitmapShow: 0,
		pBitmapInfo: 0,
		GInfo: 0,
		hBitmapInfo: 0
	})

settings := Object()

settings.postion := Abs(Round(IniRead("setting.ini", "setup", "position", "1") + 0))
settings.postion := Min(Max(1, settings.postion), 4)

settings.max_width := IniRead("setting.ini", "setup", "width", Screen_Width - 4 * gui_margin)

settings.runbackgroud := IniRead("setting.ini", "setup", "runbackgroud", "0") + 0

settings.hotkey_swap := IniRead("setting.ini", "hotkey", "swap", "s")
settings.hotkey_close := IniRead("setting.ini", "hotkey", "close", "^w")
settings.hotkey_compare := IniRead("setting.ini", "hotkey", "compare", "^q")

settings.init_hotkeys := settings.hotkey_swap "|" settings.hotkey_close "|" settings.hotkey_compare
settings.init_mode := settings.runbackgroud

#include Gdip_All.ahk
pGDI := Gdip_Startup()

mygui := Gui("-AlwaysOnTop -ToolWindow -SysMenu -Owner -DpiScale")
mygui.MarginX := gui_margin
mygui.MarginY := gui_margin
mygui.Title := appName
myGui.OnEvent("Close", myGui_Close)
myGui.OnEvent("DropFiles", mygui_DropFiles)

info_width := DPIScaled(334)
info_height := DPIScaled(66)
logo := mygui.add("Picture", "x" gui_margin " y+0 w" info_height " h" info_height " 0xE 0x200 " debugBorder,)
txt_info := mygui.add("Picture", "x+0 yp w" info_width " h" info_height " 0xE 0x200 " debugBorder,)

pBitmapLogo := Gdip_CreateBitmap(info_height, info_height)
G_Logo := Gdip_GraphicsFromImage(pBitmapLogo)
Gdip_SetSmoothingMode(G_Logo, 4)
Gdip_SetInterpolationMode(G_Logo, 7)

pBrush := Gdip_BrushCreateSolid(0xff81dad4)
points := "0," 0.2 * info_height
points .= "|" 0.7 * info_height "," 0.2 * info_height
points .= "|" 0.4 * info_height "," 0.9 * info_height
points .= "|0," 0.9 * info_height
Gdip_FillPolygon(G_Logo, pBrush, points)
Gdip_DeleteBrush(pBrush)

pBrush := Gdip_BrushCreateSolid(0xffe9b9a7)
points := 0.6 * info_height "," 0.1 * info_height
points .= "|" info_height "," 0.1 * info_height
points .= "|" info_height "," 0.8 * info_height
points .= "|" 0.3 * info_height "," 0.8 * info_height
Gdip_FillPolygon(G_Logo, pBrush, points)
Gdip_DeleteBrush(pBrush)

hBitmapLogo := Gdip_CreateHBITMAPFromBitmap(pBitmapLogo)
SetImage(logo.hwnd, hBitmapLogo)
Gdip_DeleteGraphics(G_Logo), Gdip_DisposeImage(pBitmapLogo), DeleteObject(hBitmapLogo)

pBitmapInfo := Gdip_CreateBitmap(info_width, info_height)
G_Info := Gdip_GraphicsFromImage(pBitmapInfo)
Gdip_SetSmoothingMode(G_Info, 4)
Gdip_SetInterpolationMode(G_Info, 7)
logoSize := info_height
Gdip_TextToGraphics(G_Info, "PicQuickCompare", "x0 y0 w" info_width " h" info_height " vCenter cff000000 s" DPIScaledFont(38) " R4 Bold", "MV Boli")
hBitmapInfo := Gdip_CreateHBITMAPFromBitmap(pBitmapInfo)
SetImage(txt_info.hwnd, hBitmapInfo)

picCurrentShow := 1
pic := mygui.Add("Picture", "x" gui_margin " y+0 w" DPIScaled(500) " h" DPIScaled(400) " 0xE 0x200 0x800000 -0x40")
pic.OnEvent("Click", pic_on_click)
pic.OnEvent("DoubleClick", pic_on_click)

mygui.SetFont("s" DPIScaledFont(8) " Q5 Norm", "Comic Sans MS")
info := Array()
info.Push(mygui.Add("Text", debugBorder "x" DPIScaled(420) " ys h0", "v" . version))
info.Push(mygui.Add("Link", debugBorder "xp y+0 hp", 'bilibili: <a href="https://space.bilibili.com/895523">TecNico</a>'))
info.Push(mygui.Add("Link", debugBorder "xp y+0 hp", 'GitHub: <a href="https://github.com/Nigh">xianii</a>'))

if (settings.runbackgroud) {
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
if (settings.runbackgroud) {
	if (settings.hotkey_close != "") {
		Try {
			Hotkey settings.hotkey_close, myGui_Hide
		}
	}
	Hotkey "Esc", myGui_Hide
} else {
	if (settings.hotkey_close != "") {
		Try {
			Hotkey settings.hotkey_close, myGui_Close
		}
	}
	Hotkey "Esc", myGui_Close
}
Hotkey "Space", pic_on_click

if (settings.hotkey_swap != "") {
	Try {
		Hotkey settings.hotkey_swap, swap
	}
}
HotIf
if (settings.runbackgroud) {
	if (settings.hotkey_compare != "") {
		Try {
			Hotkey settings.hotkey_compare, copyCompare
		}
	}
	TrayTip("Runs in Background.`nSelect pictures and press " hotkey_to_string(settings.hotkey_compare) " to compare.", "PicQuickCompare", 1)
}

#include setup_gui.ahk

customTrayMenu := { valid: true }
customTrayMenu.menu := []
customTrayMenu.menu.push({ name: "Setup 设置", func: setup_show })

setup_show(*) {
	pqc_setup_show()
}

shortFilename(name) {
	if (StrLen(name) > 20) {
		return SubStr(name, 1, 6) "..." SubStr(name, -9)
	}
	return name
}

sizeToStr(byte) {
	if (byte < 1024) {
		return byte "Bytes"
	}
	byte := Round(byte / 1024, 2)
	if (byte < 1024) {
		return byte "KB"
	}
	byte := Round(byte / 1024, 2)
	if (byte < 1024) {
		return byte "MB"
	}
	return "Inf"
}

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

transparentBrush := Gdip_BrushCreateSolid(0x0000FF00)
text_measure(G, txt, width, height, fontsize, font) {
	rc := Gdip_TextToGraphics(G, txt, "R4 Bold NoWrap Center y0 x0 w" width "h" height "c" transparentBrush " s" fontsize, font, 1)
	RegExMatch(rc, "^(\d+)\.?\d*\|(\d+)\.?\d*\|(\d+)\.?\d*\|(\d+)\.?\d*\|(\d+)", &rect)
	return rect
}
textdraw_measure(G, txt, option, color, font) {
	pBrush := Gdip_BrushCreateSolid(color)
	rc := Gdip_TextToGraphics(G, txt, option " c" pBrush, font, 1)
	Gdip_DeleteBrush(pBrush)
	RegExMatch(rc, "^(\d+)\.?\d*\|(\d+)\.?\d*\|(\d+)\.?\d*\|(\d+)\.?\d*\|(\d+)", &rect)
	return rect
}
create_pic_bitmap_cache(index) {
	global picture_array, pic, info_width, info_height

	if (picture_array[index].pBitmap < 0) {
		return
	}
	pic.GetPos(, , , &ctrlH)
	if (picture_array[index].GShow) {
		Gdip_DeleteGraphics(picture_array[index].GShow), Gdip_DisposeImage(picture_array[index].pBitmapShow), DeleteObject(picture_array[index].hBitmapShow)
		Gdip_DeleteGraphics(picture_array[index].GInfo), Gdip_DisposeImage(picture_array[index].pBitmapInfo), DeleteObject(picture_array[index].hBitmapInfo)
	}

	Gdip_GetImageDimensions(picture_array[index].pBitmap, &W, &H)
	percent := ctrlH / H
	picW := W * percent
	picH := H * percent
	picture_array[index].pBitmapShow := Gdip_CreateBitmap(picW, picH)
	picture_array[index].GShow := Gdip_GraphicsFromImage(picture_array[index].pBitmapShow)
	Gdip_SetSmoothingMode(picture_array[index].GShow, 4)
	Gdip_SetInterpolationMode(picture_array[index].GShow, 7)
	Gdip_DrawImage(picture_array[index].GShow, picture_array[index].pBitmap, 0, 0, picW, picH)
	picture_array[index].hBitmapShow := Gdip_CreateHBITMAPFromBitmap(picture_array[index].pBitmapShow)

	; create txt info bitmap
	picture_array[index].pBitmapInfo := Gdip_CreateBitmap(info_width, info_height)
	picture_array[index].GInfo := Gdip_GraphicsFromImage(picture_array[index].pBitmapInfo)
	Gdip_SetSmoothingMode(picture_array[index].GInfo, 4)
	Gdip_SetInterpolationMode(picture_array[index].GInfo, 7)
	Gdip_SetTextRenderingHint(picture_array[index].GInfo, 4)

	ydraw := info_height // 10
	if (picture_array[index].exifstr != "") {
		ydraw := 0
	}

	RegExMatch(picture_array[index].name, "^(?<filename>.+)\.(?<ext>.*)$", &match)
	fontsize := 18
	rect := text_measure(picture_array[index].GInfo, match.filename, info_width * 2.2, info_height // 3, DPIScaledFont(fontsize), "Microsoft JhengHei")
	if (rect[3] > info_width * 2) {
		fontsize := 8
	}
	while (rect[3] >= info_width) {
		fontsize := Floor(fontsize / 1.1)
		if (fontsize <= 12) {
			break
		}
		rect := text_measure(picture_array[index].GInfo, match.filename, info_width * 2.2, info_height // 3, DPIScaledFont(fontsize), "Microsoft JhengHei")
	}

	rect := textdraw_measure(picture_array[index].GInfo, match.filename, "R4 Bold NoWrap Center y" ydraw " x0 w" info_width "h" info_height // 3 " s" DPIScaledFont(fontsize), 0xFF000000, "Microsoft JhengHei")

	penWidth := Ceil(info_height / 60)
	pPen := Gdip_CreatePen(0xff323331, penWidth)
	ydraw := rect[2] + rect[4] + penWidth
	Gdip_DrawLine(picture_array[index].GInfo, pPen, 10, ydraw, info_width - 10, ydraw)
	Gdip_DeletePen(pPen)
	ydraw += penWidth + 6

	rect := text_measure(picture_array[index].GInfo, StrUpper(match.ext), info_width // 3, info_height // 4, DPIScaledFont(16), "Arial")
	pBrush := Gdip_BrushCreateSolid(0xff800024)
	Gdip_FillRoundedRectangle(picture_array[index].GInfo, pBrush, rect[1] - 2, ydraw - 4, rect[3] + 4, rect[4] + 4, rect[4] // 4)
	Gdip_DeleteBrush(pBrush)
	pBrush := Gdip_BrushCreateSolid(0xFFFFFFFF)
	Gdip_TextToGraphics(picture_array[index].GInfo, StrUpper(match.ext), "R4 NoWrap Center x0 y" ydraw " w" info_width // 3 "h" info_height // 4 "c" pBrush " s" DPIScaledFont(16), "Arial")
	Gdip_DeleteBrush(pBrush)

	Gdip_TextToGraphics(picture_array[index].GInfo, picture_array[index].picSize, "R4 NoWrap Center x" info_width * 1 // 3 " y" ydraw " w" info_width // 3 "h" info_height // 4 "cff00806d s" DPIScaledFont(16), "Arial")
	Gdip_TextToGraphics(picture_array[index].GInfo, picture_array[index].fileSize, "R4 NoWrap Center x" info_width * 2 // 3 " y" ydraw " w" info_width // 3 "h" info_height // 4 "cff3e0080 s" DPIScaledFont(16), "Arial")
	ydraw += info_height // 4
	if (picture_array[index].exifstr != "") {
		Gdip_TextToGraphics(picture_array[index].GInfo, picture_array[index].exifstr, "R4 NoWrap Center x0 y" ydraw " w" info_width "h" info_height // 4 "cff525252 s" DPIScaledFont(16), "Arial")
	}

	picture_array[index].hBitmapInfo := Gdip_CreateHBITMAPFromBitmap(picture_array[index].pBitmapInfo)
}

pic_ctrl_set_size() {
	global picture_array, pic, Screen_Width, Screen_Height, info
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

	minW := DPIScaled(400)
	minH := DPIScaled(400)
	maxW := settings.max_width
	maxH := 0.85 * Screen_Height

	percent := 1
	percent := Min(percent, maxH / h_max)
	percent := Min(percent, maxW / w_max)
	percent *= Min(maxW / (h_max * percent * ratio), 1)
	ctrlH := Round(h_max * percent) + 1
	ctrlW := Round(ctrlH * ratio) + 1
	; MsgBox("h_max=" h_max "`nw_max=" w_max "`nmaxH=" maxH "`nmaxW=" maxW)
	; MsgBox("W=" W "`nH=" H "`nctrlW=" ctrlW "`nctrlH=" ctrlH "`nDPIScale=" DPIScale "`npercent=" percent)
	pic.Move(10, , ctrlW, ctrlH)
	for _, inf in info {
		inf.Move(Max(ctrlW - DPIScaled(90), DPIScaled(410)))
	}
	switch settings.postion {
		Default:
		case 1:
			pic.gui.Show("AutoSize")
		case 2:
			pic.gui.Show("AutoSize x0")
		case 3:
			pic.gui.Show("AutoSize xCenter")
		case 4:
			pic.gui.Show("AutoSize")
	}
	pic.gui.GetPos(&X, &Y, &Width, &Height)
	if (Y + Height >= 0.95 * Screen_Height) {
		pic.gui.Show("yCenter")
	}
	if (settings.postion == 4) {
		pic.gui.Show("x" Screen_Width - Width)
	}
	pic.Redraw()
}

mygui_ctrl_show_pic(picture)
{
	global pic, txt_info
	SetImage(txt_info.hwnd, picture.hBitmapInfo)
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
					exinfo := Filexpro(A_LoopFileFullPath, "", "System.Photo.Orientation", "System.Photo.FNumber", "System.Photo.ISOSpeed", "System.Photo.FocalLength", "System.Photo.ExposureTime", "System.Photo.ExposureTimeNumerator", "System.Photo.ExposureTimeDenominator", "System.Image.HorizontalSize", "System.Image.VerticalSize", "System.Size", "xInfo")
					if (StrLen(exinfo["System.Photo.FocalLength"]) > 0) {
						picture_array[picCurrentShow].exif.focal := Round(exinfo["System.Photo.FocalLength"])
						picture_array[picCurrentShow].exif.apture := Round(exinfo["System.Photo.FNumber"], 1)
						picture_array[picCurrentShow].exif.ISO := exinfo["System.Photo.ISOSpeed"]
						ex_exposure := Round(("0" exinfo["System.Photo.ExposureTime"]) + 0, 5)
						ex_exposure := RegExReplace(ex_exposure, "(?<!\.)0*$", "")
						if (ex_exposure < 1) {
							ex_exposure := exinfo["System.Photo.ExposureTimeNumerator"] "/" exinfo["System.Photo.ExposureTimeDenominator"]
						}
						picture_array[picCurrentShow].exif.exposure := ex_exposure
						ex_exposure .= "s"
						ex_focal := picture_array[picCurrentShow].exif.focal "mm"
						ex_apture := "F" picture_array[picCurrentShow].exif.apture
						ex_ISO := "ISO" picture_array[picCurrentShow].exif.ISO

						exif_string := ex_focal "  " ex_apture "  " ex_exposure "  " ex_ISO
					} else {
						exif_string := ""
						picture_array[picCurrentShow].exif := Object()
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
					picture_array[picCurrentShow].exifstr := exif_string
					picture_array[picCurrentShow].fileSize := sizeToStr(exinfo["System.Size"])
					picture_array[picCurrentShow].picSize := exinfo["System.Image.HorizontalSize"] "x" exinfo["System.Image.VerticalSize"]
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
