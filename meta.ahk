FileEncoding("UTF-8")
appName := "PicQuickCompare"
version := "0.2.4"
versionFilename := "version.txt"
ahkFilename := "app.ahk"
binaryFilename := "PicQuickCompare.exe"
downloadFilename := "PicQuickCompare.zip"
downloadUrl := "/Nigh/PicQuickCompare/releases/latest/download/"
update_log := "
(
1. 增加Exif信息显示
2. 根据Exif信息自动旋转图片
3. 修复v0.2.0版本Exif只能获取英文系统的问题
4. 修复v0.2.1版本读取不含Exif文件报错的问题
5. 增加后台运行模式，选中图片按Ctrl+Q即可直接比较
6. 重写了DPI缩放逻辑，图片控件不再因为DPI缩放而模糊
)"
