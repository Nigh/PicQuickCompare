#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)
#SingleInstance force
#include meta.ahk
#include *i compile_prop.ahk
;@Ahk2Exe-AddResource *10 %A_ScriptDir%\app_title.png

#include prod.ahk

; if you need admin privilege, enable it.
if (0)
{
	UAC()
}
#include update.ahk

#include PQC.ahk

setTray()
OnExit(trueExit)
Return

trueExit(ExitReason, ExitCode) {
	ExitApp
}

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
