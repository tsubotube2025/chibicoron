@echo off
chcp 65001 > nul

REM 管理者権限チェック
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 管理者権限で再起動中...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title uDesktopMascot フォルダ権限修正

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║    uDesktopMascot フォルダの書き込み権限を修正             ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM uDesktopMascotのパスを検索
set INSTALL_PATH=

if exist "C:\Program Files (x86)\Steam\steamapps\common\uDesktopMascot\uDesktopMascot.exe" (
    set INSTALL_PATH=C:\Program Files (x86)\Steam\steamapps\common\uDesktopMascot
    echo ✓ Steam版を検出
)

if exist "C:\Program Files\MidraLab\uDesktopMascot\uDesktopMascot.exe" (
    set INSTALL_PATH=C:\Program Files\MidraLab\uDesktopMascot
    echo ✓ MidraLab版を検出
)

if "%INSTALL_PATH%"=="" (
    echo ✗ uDesktopMascotが見つかりません
    pause
    exit /b 1
)

echo.
echo インストール先: %INSTALL_PATH%
echo.

echo ⚠ 警告:
echo このスクリプトは、uDesktopMascotフォルダに対して
echo 現在のユーザーに書き込み権限を追加します。
echo.
echo 続行しますか？
set /p CONFIRM="(Y/N): "

if /i not "%CONFIRM%"=="Y" (
    echo キャンセルしました
    pause
    exit /b
)

echo.
echo 権限を修正中...
echo.

REM 現在のユーザー名を取得
set CURRENT_USER=%USERNAME%

REM StreamingAssetsフォルダに書き込み権限を追加
icacls "%INSTALL_PATH%\StreamingAssets" /grant "%CURRENT_USER%:(OI)(CI)F" /T

if %errorlevel% equ 0 (
    echo ✓ 権限修正成功
    echo.
    echo ════════════════════════════════════════════════════════════
    echo  完了！
    echo ════════════════════════════════════════════════════════════
    echo.
    echo 修正内容:
    echo - ユーザー: %CURRENT_USER%
    echo - フォルダ: %INSTALL_PATH%\StreamingAssets
    echo - 権限: フルコントロール
    echo.
    echo 【次のステップ】
    echo 1. application_settings.txt を配置
    echo 2. uDesktopMascot を起動
    echo.
) else (
    echo ✗ 権限修正失敗
    echo.
    echo 代わりに以下の方法をお試しください:
    echo 1. launch_forex_mascot_admin.bat を使用（管理者権限で起動）
    echo 2. install_settings_userdir.bat を使用（ユーザーフォルダに配置）
    echo.
)

pause