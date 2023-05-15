rmdir /s /Q "%~dp0sdlb-viewer-windows\config"
Xcopy /E /I "%~dp0config" "%~dp0sdlb-viewer-windows\config"
Xcopy /E /I "%~dp0envConfig" "%~dp0sdlb-viewer-windows\config"
cd "%~dp0sdlb-viewer-windows"
.\lighttpd\lighttpd.exe -D -f .\lighttpd.conf
