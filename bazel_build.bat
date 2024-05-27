@echo off
@chcp 936

SET CC1=win_clang
SET CC2=win_mingw
SET CC3=win_msys

SET TGT_TF=//tensorflow:tensorflow.dll //tensorflow:tensorflow.lib //tensorflow:install_headers
SET TGT_PY=//tensorflow/tools/pip_package:wheel --repo_env=WHEEL_NAME=tf_nightly_cpu
SET TGT_TFL=//tensorflow/lite:tensorflowlite
SET TGT_FLEX=//tensorflow/lite/delegates/flex:tensorflowlite_flex

REM custom setting
SET ROT=E:/bazel_root
SET ROT_GDB=%ROT%_gdb
SET CC=%CC1%
SET TF_PYTHON_VERSION=3.12
SET link_with_wholearchive=false
SET TGT_DBG=%TGT_TF% %TGT_TFL% %TGT_FLEX%
SET TGT_REL=%TGT_TF% %TGT_TFL% %TGT_FLEX% %TGT_PY%
SET TGT_REL=%TGT_TF%

SET CMD_BUILD=build --noincompatible_do_not_split_linking_cmdline --config=windows --config=%CC% --verbose_failures --config=opt --local_ram_resources=2048
SET CMD=bazel --output_user_root="%ROT%" %CMD_BUILD%
SET CMD_GDB=bazel --output_user_root="%ROT_GDB%" %CMD_BUILD%

echo --------------------------------------------------------
echo ----------------------Debug-----------------------------
echo --------------------------------------------------------
echo %CMD% --config=dbg --config=skiplink %TGT_DBG%
echo --------------------------------------------------------
echo -----------------Release or gdb ------------------------
echo --------------------------------------------------------
echo %CMD% %TGT_REL%
echo --------------------------------------------------------
echo %CMD_GDB% --config=gdb --config=skiplink %TGT_REL%
echo --------------------------------------------------------
echo ----------------------Debug-----------------------------
echo --------------------------------------------------------
:: %CMD% --config=dbg --config=skiplink %TGT_DBG%
echo --------------------------------------------------------
echo -----------------Release or gdb ------------------------
echo --------------------------------------------------------
echo %CMD% %TGT_REL%
echo --------------------------------------------------------
%CMD_GDB% --config=gdb --config=skiplink %TGT_REL%

setlocal enabledelayedexpansion

set tag=WHOLEARCHIVE
::rd /S /Q .\bazel-bin\tensorflow\dumpbin
md .\bazel-bin\tensorflow\dumpbin

set header_path=".\bazel-bin\tensorflow\dumpbin\tf_static_libs.h"
set header_path_tmp=".\bazel-bin\tensorflow\dumpbin\tf_static_libs_tmp.h"
echo #ifndef TENSORFLOW_STATIC_LIBS_H_> %header_path_tmp%
echo #define TENSORFLOW_STATIC_LIBS_H_>> %header_path_tmp%
echo.>> %header_path_tmp%

for /f "tokens=1* delims=:" %%i in (.\bazel-bin\tensorflow\tensorflow.dll-2.params)  do (
	set target_opt=%%i
	set target_lib=%%j
	echo "!target_opt!" | findstr "%tag%" >nul && (
		call :extract "!target_lib!"
	) || (
		REM echo %%i
	)
)

echo.>> %header_path_tmp%
:: link symbol "__imp_RtlGetLastNtStatus"
echo #pragma comment(lib, "ntdll.lib"^)>> %header_path_tmp%
:: link symbol "__imp_htonl" "__imp_htons" "__imp_WSAGetLastError"
echo #pragma comment(lib, "ws2_32.lib"^)>> %header_path_tmp%
if "%link_with_wholearchive%" == "true" (
	:: link symbol "__imp_IdnToAscii" and "__imp_IdnToUnicode"
	echo #pragma comment(lib, "Normaliz.lib"^)>> %header_path_tmp%
	:: https://discourse.llvm.org/t/issue-with-clang-on-windows-and-compiler-rt-builtins/47288
	:: link symbol "__cpu_mode" at "X\bazel_root\vmobr63h\external\tf_runtime\lib\support\crc32c_accelerate.cc"
	echo #pragma comment(lib, "clang_rt.builtins-x86_64.lib"^)>> %header_path_tmp%
)
echo.>> %header_path_tmp%
echo #endif>> %header_path_tmp%
move /Y %header_path_tmp% %header_path%

goto exit

:extract
	rem 获取到文件路径
	rem echo %~dp1
	rem 获取到文件盘符
	rem echo %~d1
	rem 获取到文件名称
	rem echo %~n1
	rem 获取到文件后缀
	rem echo %~x1
	rem echo %1
	SET RELPATH=%~1
	SET RELPATH=%RELPATH:bazel-out/x64_windows-opt/bin/=%
	SET RELPATH=%RELPATH:bazel-out/x64_windows-dbg/bin/=%
	CALL file_changed.bat %1 ".\bazel-bin\tensorflow\dumpbin\libs\%RELPATH%"
	if "%ERRORLEVEL%" == "1" (
		xcopy /F /-I /Y %1 ".\bazel-bin\tensorflow\dumpbin\libs\%RELPATH%"
		if "%~x1" equ ".dll" (
			dumpbin.exe /exports %1 > ".\bazel-bin\tensorflow\dumpbin\libs\%RELPATH%_exports.txt"
		) else if "%~x1" equ ".lib" (
			dumpbin.exe /linkermember %1 > ".\bazel-bin\tensorflow\dumpbin\libs\%RELPATH%_linkermember.txt"
			if "%link_with_wholearchive%" == "true" (
				echo #pragma comment(linker, "/WHOLEARCHIVE:%RELPATH%"^)>> %header_path_tmp%
			) else (
				echo #pragma comment(lib, "%RELPATH%"^)>> %header_path_tmp%
			)
		) else if "%~x1" equ ".def" (
			REM echo [SKIP]: %1
		) else (
			dumpbin.exe /all %1 > ".\bazel-bin\tensorflow\dumpbin\libs\%RELPATH%_all.txt"
		)
	) else (
		if "%~x1" equ ".lib" (
			if "%link_with_wholearchive%" == "true" (
				echo #pragma comment(linker, "/WHOLEARCHIVE:%RELPATH%"^)>> %header_path_tmp%
			) else (
				echo #pragma comment(lib, "%RELPATH%"^)>> %header_path_tmp%
			)
		)
		REM echo [SKIP]: %1
	)
	goto:eof

:exit

python bazel_build.py