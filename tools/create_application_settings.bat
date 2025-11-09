@echo off
chcp 65001 > nul
title application_settings.txt 自動作成

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║     application_settings.txt 自動作成スクリプト            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM 既存ファイルチェック
if exist "application_settings.txt" (
    echo ⚠ application_settings.txt が既に存在します
    echo.
    set /p OVERWRITE="上書きしますか？ (Y/N): "
    
    if /i not "%OVERWRITE%"=="Y" (
        echo キャンセルしました
        pause
        exit /b
    )
    
    REM バックアップ作成
    copy "application_settings.txt" "application_settings.txt.backup" >nul
    echo ✓ バックアップ作成: application_settings.txt.backup
    echo.
)

echo [1/2] application_settings.txt を作成中...

REM ファイル作成
(
echo [Character]
echo ModelPath=default.vrm
echo Scale=3
echo PositionX=0
echo PositionY=0
echo PositionZ=0
echo RotationX=0
echo RotationY=0
echo RotationZ=0
echo.
echo [Sound]
echo VoiceVolume=1.0
echo BGMVolume=0.0
echo SEVolume=1.0
echo.
echo [Display]
echo Opacity=1.0
echo AlwaysOnTop=True
echo.
echo [Performance]
echo TargetFrameRate=60
echo QualityLevel=2
) > application_settings.txt

if exist "application_settings.txt" (
    echo ✓ 作成成功
    echo.
) else (
    echo ✗ 作成失敗
    pause
    exit /b 1
)

echo [2/2] ユーザーフォルダに配置中...
echo.

REM ユーザー設定フォルダのパス
set USER_CONFIG_DIR=%LOCALAPPDATA%Low\MidraLab\uDesktopMascot

REM フォルダ作成
if not exist "%USER_CONFIG_DIR%" (
    mkdir "%USER_CONFIG_DIR%"
    echo ✓ フォルダ作成: %USER_CONFIG_DIR%
) else (
    echo ✓ フォルダ確認済み
)

REM ファイルをコピー
copy /Y "application_settings.txt" "%USER_CONFIG_DIR%\application_settings.txt" >nul

if %errorlevel% equ 0 (
    echo ✓ コピー成功
    echo.
    echo ════════════════════════════════════════════════════════════
    echo  完了！
    echo ════════════════════════════════════════════════════════════
    echo.
    echo 【作成したファイル】
    echo   1. カレントディレクトリ:
    echo      %CD%\application_settings.txt
    echo.
    echo   2. ユーザー設定フォルダ:
    echo      %USER_CONFIG_DIR%\
    echo      application_settings.txt
    echo.
    echo 【設定内容】
    echo   - キャラクター: default.vrm
    echo   - サイズ: 3倍
    echo   - BGM: オフ
    echo   - 常に最前面: オン
    echo.
    echo 【カスタマイズ】
    echo   application_settings.txt をメモ帳で編集してください
    echo   編集後、このスクリプトを再実行すれば反映されます
    echo.
    echo 【次のステップ】
    echo   1. (オプション) VRMファイルを配置
    echo   2. uDesktopMascot を起動
    echo   3. LAUNCH_FOREX_MASCOT.bat で為替監視開始
    echo.
    echo フォルダを開きますか？
    set /p OPEN="(Y/N): "
    
    if /i "%OPEN%"=="Y" (
        start "" "%USER_CONFIG_DIR%"
        start "" "%CD%"
    )
) else (
    echo ✗ コピー失敗
    echo.
    echo 手動でコピーしてください:
    echo   コピー元: %CD%\application_settings.txt
    echo   コピー先: %USER_CONFIG_DIR%\
)

echo.
pause