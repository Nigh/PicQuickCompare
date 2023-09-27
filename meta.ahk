FileEncoding("UTF-8")
appName := "PicQuickCompare"
version := "0.2.5"
versionFilename := "version.txt"
ahkFilename := "app.ahk"
binaryFilename := "PicQuickCompare.exe"
downloadFilename := "PicQuickCompare.zip"
GitHubID := "Nigh"
repoName := "PicQuickCompare"
downloadUrl := "/" GitHubID "/" repoName "/releases/latest/download/"
update_log := "
(
v0.2.X 更新日志
1. 增加Exif信息显示
2. 根据Exif信息自动旋转图片
3. 增加后台运行模式，选中图片按Ctrl+Q即可直接比较
4. 重写了DPI缩放逻辑，图片控件不再因为DPI缩放而模糊
5. 更新了编译工具链，使用C重写了部分升级相关功能，使得打包体积减小了一半
6. 减小了字体的DPI缩放系数
7. 过长文件名缩略显示
8. 添加图片尺寸与文件大小显示
9. 对LOGO启用DPI缩放
)"
