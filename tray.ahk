

gotoWebpage_maker(page)
{
	webpage(*){
		Run(page)
	}
	return webpage
}

setTray()
{
	global version, trueExit, customTrayMenu
	trayExit(*){
		trueExit("","")
	}
	tray := A_TrayMenu
	tray.delete
	tray.add("v" . version, (*)=>{})
	tray.add()
	if (customTrayMenu.HasOwnProp("valid") && customTrayMenu.HasOwnProp("menu")) {
		For , Value in customTrayMenu.menu
		{
			tray.add(Value.name, Value.func)
			tray.Default := Value.name
		}
		tray.add()
	}
	tray.add("Github 页面", gotoWebpage_maker("https://github.com/Nigh/ahk-autoupdate-template"))
	tray.add("Donate 捐助", gotoWebpage_maker("https://ko-fi.com/xianii"))
	tray.add("Exit", trayExit)
	tray.ClickCount := 1
}
