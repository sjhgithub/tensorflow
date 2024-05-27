@echo off
@chcp 936

SET TF_PYTHON_VERSION=3.12

SET CC1=win_clang
SET CC2=win_mingw
SET CC3=win_msys
SET ROT=E:/bazel_root

SET TGT_TF=//tensorflow:tensorflow.dll //tensorflow:tensorflow.lib //tensorflow:install_headers
SET TGT_PY=//tensorflow/tools/pip_package:wheel --repo_env=WHEEL_NAME=tf_nightly_cpu
SET TGT_TFL=//tensorflow/lite:tensorflowlite
SET TGT_FLEX=//tensorflow/lite/delegates/flex:tensorflowlite_flex

SET TGT_DBG=%TGT_TF% %TGT_TFL% %TGT_FLEX%
SET TGT_REL=%TGT_TF% %TGT_TFL% %TGT_FLEX% %TGT_PY%

SET CMD=bazel --output_user_root="%ROT%" build --noincompatible_do_not_split_linking_cmdline --config=windows --config=%CC1% --verbose_failures --config=opt --local_ram_resources=2048

echo --------------------------------------------------------
echo ----------------------Debug-----------------------------
echo --------------------------------------------------------
echo %CMD% --config=dbg --config=skiplink %TGT_DBG%
echo --------------------------------------------------------
echo ---------------------Release----------------------------
echo --------------------------------------------------------
echo %CMD% %TGT_REL%
echo --------------------------------------------------------
echo ----------------------Debug-----------------------------
echo --------------------------------------------------------
%CMD% --config=dbg --config=skiplink %TGT_DBG%
echo --------------------------------------------------------
echo ---------------------Release----------------------------
echo --------------------------------------------------------
%CMD% %TGT_REL%

setlocal enabledelayedexpansion

set tag=bazel-out
::rd /S /Q .\bazel-bin\tensorflow\dumpbin
md .\bazel-bin\tensorflow\dumpbin

echo #ifndef TENSORFLOW_STATIC_LIBS_H_>> ".\bazel-bin\tensorflow\dumpbin\tf_static_libs.h"
echo #define TENSORFLOW_STATIC_LIBS_H_>> ".\bazel-bin\tensorflow\dumpbin\tf_static_libs.h"
echo.>> ".\bazel-bin\tensorflow\dumpbin\tf_static_libs.h"

for /f "tokens=1* delims=:" %%i in (.\bazel-bin\tensorflow\tensorflow.dll-2.params)  do (
	set target=%%j
	echo "!target!" | findstr %tag% >nul && (
		call :extract "!target!"
	) || (
		echo %%i
	)
)

echo.>> ".\bazel-bin\tensorflow\dumpbin\tf_static_libs.h"
echo #endif>> ".\bazel-bin\tensorflow\dumpbin\tf_static_libs.h"

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
			dumpbin.exe /exports %1 >> ".\bazel-bin\tensorflow\dumpbin\libs\%RELPATH%_exports.txt"
		) else if "%~x1" equ ".lib" (
			dumpbin.exe /linkermember %1 >> ".\bazel-bin\tensorflow\dumpbin\libs\%RELPATH%_linkermember.txt"
		) else (
			dumpbin.exe /all %1 >> ".\bazel-bin\tensorflow\dumpbin\libs\%RELPATH%_all.txt"
		)
	)
	echo #pragma comment(lib, "%RELPATH%"^)>> ".\bazel-bin\tensorflow\dumpbin\tf_static_libs.h"
	goto:eof

:exit
