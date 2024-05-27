@echo off & setlocal

rem 参数去引号处理
set arg1=%~1
set arg2=%~2

rem arg1文件路径不能为空
if "%arg1%"=="" (
    echo input file empty!
    goto usage
)
if not exist %arg1% (
    echo %arg1% not exist!
    goto usage
)

rem arg2 md5临时文件名，为空默认为文件名.md5
if "%arg2%"=="" set arg2=%arg1%

rem 先读取旧的md5值
if exist %arg2%.md5 (set /p md5_old=<%arg2%.md5)

rem 计算文件md5值，保存到md5文件
certutil -hashfile %arg1% MD5 | find /v ":" > %arg2%.md5

rem 读取新的md5值
set /p md5=<%arg2%.md5
set flag=1

rem 比较md5值是否变化，判断文件是否发生变化
if defined md5_old (
    if "%md5_old%" == "%md5%" ( set flag=0 )
)

rem 输出1文件发生变化，0文件没发生变化
::echo %flag%
exit /b %flag%

:usage
::echo %0 filepath [md5name]
exit /b -1
