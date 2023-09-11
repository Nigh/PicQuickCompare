;Filexpro() file extended properties
;AHK v2.beta.3 version by neogna2 https://www.autohotkey.com/r?p=434132
;based on SKAN's v1 orginal version https://www.autohotkey.com/r?p=252539
Filexpro(sFile := "", Kind := "", P*) {
	Static mDetails
	;deinitialize mDetails with blank parameter sFile
	If (sFile = "")
	{
		mDetails := ""
		Return
	}

	;initialize output Map
	mFex := Map()

	;verify file parameter
	Loop Files RTrim(sfile, "\*/."), "DF"
	{
		If !FileExist(sFile := A_LoopFileFullPath)
			Return
		SplitPath(sFile, &_FileExt, &_Dir, &_Ext, &_File, &_Drv)
		break
	}
	If !IsSet(_FileExt)
		Return

	;if last parameter is string "xInfo" get extra file info
	If (p[p.length] = "xInfo")
	{
		p.Pop()
		mFex["_Attrib"] := A_LoopFileAttrib
		mFex["_Dir"] := _Dir
		mFex["_Drv"] := _Drv
		mFex["_Ext"] := _Ext
		mFex["_File"] := _File
		mFex["_File.Ext"] := _FileExt
		mFex["_FilePath"] := sFile
		mFex["_FileSize"] := A_LoopFileSize
		mFex["_FileTimeA"] := A_LoopFileTimeAccessed
		mFex["_FileTimeC"] := A_LoopFileTimeCreated
		mFex["_FileTimeM"] := A_LoopFileTimeModified
	}

	;ComObject for reading file properties
	objShl := ComObject("Shell.Application")
	objDir := objShl.NameSpace(_Dir)
	objItm := objDir.ParseName(_FileExt)

	;create static Map of each possible property name/index, later used to read properties via index
	;"GetDetailsOf(0" gets data from Explorer column details view, https://stackoverflow.com/a/37061433
	;Windows 10 found 308 properties in December 2021 but search for 400 in case more gets added
	If !isSet(mDetails)
	{
		mDetails := Map()
		i := -1
		While (i++ < 400)
			mDetails[objDir.GetDetailsOf(0, i)] := i
		;remove any empty key
		mDetails.Delete("")
	}

	;if parameter Kind is set then file must match it
	If (Kind and Kind != objDir.GetDetailsOf(objItm, 11))
		Return

	;for each property name string in parameter p get the property value
	;get "System.Audio.ChannelCount" style names (no spaces, dot separator) with ExtendedProperty
	;https://docs.microsoft.com/en-us/windows/win32/shell/shellfolderitem-extendedproperty
	;get "Product version" style names (spaces, no dots) with GetDetailsOf
	;https://docs.microsoft.com/en-us/windows/win32/shell/folder-getdetailsof
	For i, Prop in p
	{
		if mDetails.Has(Prop)
			mFex[Prop] := ObjDir.GetDetailsOf(objItm, PropNum := mDetails[Prop])
		else if ((Dot := InStr(Prop, ".")) and (Prop := (Dot = 1 ? "System" : "") . Prop))
			mFex[Prop] := objItm.ExtendedProperty(Prop)
	}

	Return mFex
}
