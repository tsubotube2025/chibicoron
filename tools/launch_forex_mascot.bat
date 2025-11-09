@echo off
chcp 65001 > nul
title 為替監視マスコット起動システム

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║       為替監視マスコット一括起動スクリプト                 ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM ==================== 設定 ====================
REM uDesktopMascotのパスを環境に合わせて変更してください
set UDESKTOPMASCOT_PATH=C:\Program Files (x86)\Steam\steamapps\common\uDesktopMascot\uDesktopMascot.exe

REM Pythonスクリプトのパス
set PYTHON_SCRIPT=forex_mascot.py

REM ==================== 起動前チェック ====================

REM Pythonのインストール確認
echo [0/5] Python環境確認...
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Pythonが見つかりません
    echo.
    echo 【解決方法】
    echo 1. Pythonをインストールしてください
    echo 2. https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)
echo ✓ Python環境OK
echo.

echo [1/5] VOICEVOX起動確認...
timeout /t 2 /nobreak > nul
curl -s http://localhost:50021/version > nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ VOICEVOXが起動していません
    echo.
    echo 【解決方法】
    echo 1. VOICEVOXを起動してください
    echo 2. http://localhost:50021 で起動していることを確認
    echo.
    pause
    exit /b 1
)
echo ✓ VOICEVOX起動中
echo.

echo [2/5] spikweatch-mt5起動確認...
timeout /t 2 /nobreak > nul
powershell -Command "(New-Object Net.WebClient).DownloadString('http://localhost:8000')" > nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠ spikweatch-mt5が起動していないようです
    echo.
    echo このまま続行しますか？
    echo （続行する場合は Y、中止する場合は N）
    set /p confirm=選択 (Y/N): 
    if /i not "%confirm%"=="Y" (
        echo 起動を中止します
        pause
        exit /b 1
    )
    echo ⚠ 警告: spikweatch-mt5なしで起動します
) else (
    echo ✓ spikweatch-mt5起動中
)
echo.

echo [3/5] AItuberKit起動確認...
echo （AItuberKitは任意です。起動していない場合はスキップ）
timeout /t 1 /nobreak > nul
echo ✓ スキップ
echo.

echo [4/5] uDesktopMascot起動...
if not exist "%UDESKTOPMASCOT_PATH%" (
    echo ✗ uDesktopMascot.exeが見つかりません
    echo パス: %UDESKTOPMASCOT_PATH%
    echo.
    echo 【解決方法】
    echo このバッチファイルの UDESKTOPMASCOT_PATH を正しいパスに変更してください
    echo.
    pause
    exit /b 1
)

start "" "%UDESKTOPMASCOT_PATH%"
echo ✓ uDesktopMascot起動
timeout /t 3 /nobreak > nul
echo.

echo [5/5] 為替監視スクリプト起動...
if not exist "%PYTHON_SCRIPT%" (
    echo ✗ %PYTHON_SCRIPT% が見つかりません
    echo.
    echo 【解決方法】
    echo このバッチファイルと同じフォルダに forex_mascot.py を配置してください
    echo.
    pause
    exit /b 1
)

REM 必要なPythonパッケージの確認
echo.
echo Pythonパッケージ確認中...
python -c "import requests" 2>nul
if %errorlevel% neq 0 (
    echo ⚠ requestsパッケージがインストールされていません
    echo   インストールコマンド: pip install requests
    echo.
)

REM デバッグモード: エラーを表示する通常起動
echo.
echo 【起動モード選択】
echo 1. 通常起動（エラーを表示）- 初回起動や問題発生時推奨
echo 2. バックグラウンド起動（ウィンドウなし）- 安定動作確認後
echo.
set /p mode=選択 (1 or 2): 

if "%mode%"=="2" (
    REM バックグラウンドで起動（ウィンドウを表示しない）
    start "" pythonw "%PYTHON_SCRIPT%"
    echo ✓ 為替監視スクリプト起動（バックグラウンド）
) else (
    REM 通常起動（コンソール表示・エラー確認可能）
    start "為替監視スクリプト" python "%PYTHON_SCRIPT%"
    echo ✓ 為替監視スクリプト起動（コンソール表示）
    echo   ※ エラーがある場合は新しいウィンドウに表示されます
)
echo.

echo ╔════════════════════════════════════════════════════════════╗
echo ║                  すべて起動完了！                          ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 【起動したもの】
echo   ✓ uDesktopMascot（キャラクター表示）
echo   ✓ forex_mascot.py（為替監視・音声発話）
echo.
echo 【使い方】
echo   - キャラクターが画面に表示されます
echo   - 為替の変動があると自動的に喋ります
echo   - 終了する場合は各ウィンドウを閉じてください
echo.
echo 【トラブルシューティング】
echo   - キャラクターが表示されない場合
echo     → uDesktopMascotの設定でモデルを確認
echo   - 喋らない場合
echo     → VOICEVOXが起動しているか確認
echo     → spikweatch-mt5が動作しているか確認
echo   - スクリプトがすぐ終了する場合
echo     → 起動モード1（通常起動）でエラーメッセージを確認
echo.
pause