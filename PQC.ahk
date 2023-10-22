
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
		exif: '',
		fileSize: '',
		picSize: '',
		pBitmapShow: 0,
		G: 0,
		hBitmapShow: 0
	})

settings := Object()

settings.postion := Abs(Round(IniRead("setting.ini", "setup", "position", "1") + 0))
settings.postion := Min(Max(1, settings.postion), 4)

settings.max_width := IniRead("setting.ini", "setup", "width", Screen_Width-2*gui_margin)

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

if A_IsCompiled {
	mygui.Add("Picture", "x" gui_margin " y" gui_margin " h" DPIScaledFont(10)*4 " w-1 Section", "HBITMAP:" HBitmapFromResource("app_title.png"))
} else {
	mygui.Add("Picture", "x" gui_margin " y" gui_margin " h" DPIScaledFont(10)*4 " w-1 Section", "app_title.png")
}

mygui.SetFont("s" DPIScaledFont(10) " Q5 norm", "Comic Sans MS")
mygui.Add("Text", "x+" DPIScaled(10) " yp Section h" DPIScaled(12), 'Current:')
mygui.Add("Text", "xs y+0 hp wp", 'EXIF:')

txt_indicator := mygui.Add("Text", debugBorder "Section x+10 ys hp w" DPIScaled(270), 'NULL')
txt_indicator.SetFont("cTeal bold")

txt_exif := mygui.Add("Text", debugBorder "xs y+0 hp w" DPIScaled(270), 'NULL')
txt_exif.SetFont("cNavy bold")

picSize := mygui.Add("Text", debugBorder "Center xp y+0 hp", '0000000000')
picSize.SetFont("cOlive bold")
fileSize := mygui.Add("Text", debugBorder "Right x+5 yp hp w" DPIScaled(70), '0 kB')
fileSize.SetFont("cMaroon bold")

picCurrentShow := 1
pic := mygui.Add("Picture", "x10 y+0 w" DPIScaled(500) " h" DPIScaled(400) " 0xE 0x200 0x800000 -0x40")
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
	if(settings.hotkey_close != "") {
		Try {
			Hotkey settings.hotkey_close, myGui_Hide
		}
	}
	Hotkey "Esc", myGui_Hide
} else {
	if(settings.hotkey_close != "") {
		Try {
			Hotkey settings.hotkey_close, myGui_Close
		}
	}
	Hotkey "Esc", myGui_Close
}
Hotkey "Space", pic_on_click

if(settings.hotkey_swap != "") {
	Try {
		Hotkey settings.hotkey_swap, swap
	}
}
HotIf
if (settings.runbackgroud) {
	if(settings.hotkey_compare != "") {
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
		return byte "kB"
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

create_pic_bitmap_cache(index) {
	global picture_array, pic

	if (picture_array[index].pBitmap < 0) {
		return
	}
	pic.GetPos(, , , &ctrlH)
	if (picture_array[index].G) {
		Gdip_DeleteGraphics(picture_array[index].G), Gdip_DisposeImage(picture_array[index].pBitmapShow), DeleteObject(picture_array[index].hBitmapShow)
	}

	Gdip_GetImageDimensions(picture_array[index].pBitmap, &W, &H)
	percent := ctrlH / H
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
	maxW := 0.95 * Screen_Width
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
	global txt_indicator, pic, mygui, fileSize, picSize
	txt_indicator.Text := shortFilename(picture.name)
	fileSize.Text := picture.fileSize
	picSize.Text := picture.picSize
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
					exinfo := Filexpro(A_LoopFileFullPath, "", "System.Photo.Orientation", "System.Photo.FNumber", "System.Photo.ISOSpeed", "System.Photo.FocalLength", "System.Photo.ExposureTime", "System.Photo.ExposureTimeNumerator", "System.Photo.ExposureTimeDenominator", "System.Image.HorizontalSize", "System.Image.VerticalSize", "System.Size", "xInfo")
					if (StrLen(exinfo["System.Photo.FocalLength"]) > 0) {
						ex_focal := Round(exinfo["System.Photo.FocalLength"]) "mm"
						ex_apture := "F" Round(exinfo["System.Photo.FNumber"], 1)
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
