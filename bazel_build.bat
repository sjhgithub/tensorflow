@echo off
@chcp 936

SET CC1=win_clang
SET CC2=win_mingw
SET CC3=win_msys
SET ROT=E:/bazel_root_static
SET TGT=//tensorflow:tensorflow.dll //tensorflow:tensorflow.lib //tensorflow:install_headers //tensorflow/tools/pip_package:wheel --repo_env=WHEEL_NAME=tf_nightly_cpu //tensorflow/lite:tensorflowlite //tensorflow/lite/delegates/flex:tensorflowlite_flex
SET CMD=bazel --output_user_root="%ROT%" build --noincompatible_do_not_split_linking_cmdline --config=windows --config=%CC1% --verbose_failures --config=opt --local_ram_resources=2048

echo --------------------------------------------------------
echo ----------------------Debug-----------------------------
echo --------------------------------------------------------
echo %CMD% --config=dbg %TGT%
echo --------------------------------------------------------
echo ---------------------Release----------------------------
echo --------------------------------------------------------
echo %CMD% %TGT%
echo --------------------------------------------------------
echo ----------------------Debug-----------------------------
echo --------------------------------------------------------
%CMD% --config=dbg %TGT%
echo --------------------------------------------------------
echo ---------------------Release----------------------------
echo --------------------------------------------------------
%CMD% %TGT%

pause