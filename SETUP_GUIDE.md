# 為替監視マスコット セットアップ完全ガイド

## 🎯 システム構成

```
┌─────────────────────────────────────────────────────────┐
│                    為替監視システム                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐    ┌─────────────────┐               │
│  │ spikweatch-  │───>│  forex_mascot   │               │
│  │    mt5       │    │    .py          │               │
│  │              │    │                 │               │
│  │ (為替監視)   │    │  (音声発話制御) │               │
│  └──────────────┘    └────────┬────────┘               │
│         │                     │                         │
│         │                     ↓                         │
│         │            ┌─────────────────┐               │
│         │            │   VOICEVOX      │               │
│         │            │  (音声合成)     │               │
│         │            └────────┬────────┘               │
│         │                     │                         │
│         │            ┌────────↓────────┐               │
│         └───────────>│ uDesktopMascot  │               │
│                      │ (キャラ表示)    │               │
│                      └─────────────────┘               │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## 📋 必要なもの

### 必須
1. **Windows 10/11** または **macOS**
2. **uDesktopMascot** - [Display]
Opacity=1.0
AlwaysOnTop=True

[Performance]
TargetFrameRate=60
QualityLevel=2
```

### ステップ4: mascot_config.jsonの設定

```json
{
  "voicevox_url": "http://localhost:50021",
  "spikweatch_ws_url": "ws://localhost:8000",
  "speaker_id": 1,
  "enable_system_messages": false,
  "enable_mascot_filter": true
}
```

**話者IDの選び方:**
- `1`: 四国めたん（ノーマル）- 落ち着いた声
- `2`: ずんだもん（ノーマル）- 元気な声
- `3`: 春日部つむぎ（ノーマル）- やわらかい声
- `8`: 四国めたん（あまあま）- かわいい声

AItuberKitと違う話者を使うと区別しやすいです。

### ステップ5: 起動順序

#### 自動起動（推奨）

1. `launch_forex_mascot.bat`を編集してパスを確認
2. バッチファイルをダブルクリック
3. すべて自動で起動します

#### 手動起動

```bash
# 1. VOICEVOXを起動
# GUIから起動してください

# 2. spikweatch-mt5を起動
python spikweatch_mt5.py

# 3. uDesktopMascotを起動
# アプリケーションを起動してください

# 4. 為替監視スクリプトを起動
python forex_mascot.py
```

## 🎨 カスタマイズ

### キャラクターの位置調整

`application_settings.txt`で調整：

```ini
[Character]
# 画面右下に配置したい場合
PositionX=1600  # 画面幅に応じて調整
PositionY=-800  # マイナスで下に移動
PositionZ=0

# サイズを大きくしたい場合
Scale=5  # 数値を大きくする
```

### 音量調整

```ini
[Sound]
VoiceVolume=0.8  # 少し小さく
BGMVolume=0.0    # BGMなし（推奨）
SEVolume=1.0     # 効果音はそのまま
```

### 透明度調整

```ini
[Display]
Opacity=0.9  # 少し透明に（0.0～1.0）
```

### 発話内容のカスタマイズ

`mascot_config.json`で調整：

```json
{
  "enable_mascot_filter": true,  // シンプルなメッセージに
  "enable_system_messages": false  // システムメッセージは喋らない
}
```

## 🔧 トラブルシューティング

### 問題1: キャラクターが表示されない

**原因と解決方法:**
- uDesktopMascotが起動していない
  → アプリケーションを起動
- モデルファイルが見つからない
  → `application_settings.txt`の`ModelPath`を確認
- 画面外に配置されている
  → `PositionX`, `PositionY`を`0`にリセット

### 問題2: 音声が出ない

**原因と解決方法:**
- VOICEVOXが起動していない
  → `http://localhost:50021`にアクセスして確認
- spikweatch-mt5が動作していない
  → コンソールでエラーを確認
- 音量がゼロになっている
  → `application_settings.txt`の`VoiceVolume`を確認

### 問題3: WebSocket接続エラー

**原因と解決方法:**
- spikweatch-mt5が起動していない
  → 先にspikweatch-mt5を起動
- ポート番号が違う
  → `mascot_config.json`の`spikweatch_ws_url`を確認
- ファイアウォールでブロックされている
  → Windows Defenderの設定を確認

### 問題4: AItuberKitと音声が重なる

**解決済み:**
- スクリプト内で排他制御を実装済み
- 自動的に順番に再生されます

### 問題5: 為替変動があっても喋らない

**確認事項:**
1. spikweatch-mt5のコンソールにアラートが表示されているか
2. forex_mascot.pyのコンソールに「受信」ログが出ているか
3. WebSocket接続が成功しているか

```bash
# 接続テスト
curl ws://localhost:8000
```

## 📊 動作確認

すべて正常に動作している場合：

```
✓ uDesktopMascotでキャラクターが画面に表示されている
✓ spikweatch-mt5のコンソールに価格更新が表示されている
✓ forex_mascot.pyのコンソールに「✓ 接続成功」と表示されている
✓ 為替変動時にキャラクターが喋る
```

## 🎯 使用例

### 起動ログ（正常時）

```
[1/5] VOICEVOX起動確認...
✓ VOICEVOX起動中

[2/5] spikweatch-mt5起動確認...
✓ spikweatch-mt5起動中

[3/5] AItuberKit起動確認...
✓ スキップ

[4/5] uDesktopMascot起動...
✓ uDesktopMascot起動

[5/5] 為替監視スクリプト起動...
✓ 為替監視スクリプト起動（バックグラウンド）

すべて起動完了！
```

### 動作ログ

```
為替監視マスコット起動
VOICEVOX: http://localhost:50021
spikweatch-mt5: ws://localhost:8000
話者ID: 1
============================================================
spikweatch-mt5に接続中... (ws://localhost:8000)
✓ 接続成功

[10:30:45] 受信: どるえんが52.5pips上昇しました。えええっ～びっくりです。大変です。
```

## 💡 応用アイデア

### 1. 複数通貨ペアごとに異なる話者

```json
{
  "speaker_mapping": {
    "USDJPY": 1,   // 四国めたん
    "EURJPY": 2,   // ずんだもん
    "GBPJPY": 3    // 春日部つむぎ
  }
}
```

### 2. 時間帯で音量調整

```python
import datetime

hour = datetime.datetime.now().hour
if 22 <= hour or hour <= 7:
    volume = 0.5  # 夜間は小さく
else:
    volume = 1.0  # 日中は通常
```

### 3. VRMの表情変更（今後の拡張）

uDesktopMascotのAPI経由で表情を変更：
- 上昇時: 喜び表情
- 下降時: 困り表情
- 大変動: びっくり表情

## 📚 参考リンク

- [uDesktopMascot GitHub](https://github.com/MidraLab/uDesktopMascot)
- [VOICEVOX公式](https://voicevox.hiroshiba.jp/)
- [spikweatch-mt5 GitHub](https://github.com/tsubo2025/spikweatch-mt5)
- [VRM Consortium](https://vrm.dev/)GitHub](https://github.com/MidraLab/uDesktopMascot) または [Steam](https://store.steampowered.com/app/2950010/uDesktopMascot/)
3. **VOICEVOX** - [公式サイト](https://voicevox.hiroshiba.jp/)
4. **Python 3.8以上**
5. **MetaTrader 5**
6. **spikweatch-mt5** - [GitHub](https://github.com/tsubo2025/spikweatch-mt5)

### 任意
- **AItuberKit** - 同時起動する場合

## 🚀 セットアップ手順

### ステップ1: 各ソフトウェアのインストール

#### 1.1 uDesktopMascotのインストール

**Steam版の場合:**
1. Steamを起動
2. uDesktopMascotを検索してインストール
3. インストール先: `C:\Program Files (x86)\Steam\steamapps\common\uDesktopMascot\`

**GitHub版の場合:**
1. [Releases](https://github.com/MidraLab/uDesktopMascot/releases)から最新版をダウンロード
2. 任意の場所に展開

#### 1.2 VRMモデルの配置（お好みで）

```
uDesktopMascot/
└── StreamingAssets/
    └── Models/
        └── your_model.vrm  ← ここにVRMファイルを配置
```

デフォルトモデルでも問題ありません。

#### 1.3 VOICEVOXのインストール

1. [VOICEVOX公式サイト](https://voicevox.hiroshiba.jp/)からダウンロード
2. インストール後、起動して `http://localhost:50021` で動作確認

#### 1.4 Python環境のセットアップ

```bash
# 必要なパッケージのインストール
pip install requests websockets
```

### ステップ2: ファイル配置

以下のようにファイルを配置してください：

```
為替監視マスコット/
├── forex_mascot.py              # メインスクリプト
├── mascot_config.json           # 設定ファイル
├── application_settings.txt     # uDesktopMascot設定
├── launch_forex_mascot.bat      # 一括起動スクリプト
└── temp_audio/                  # 自動生成（音声ファイル一時保存）
```

### ステップ3: application_settings.txtの設定

uDesktopMascotのインストールフォルダに`application_settings.txt`を配置：

**Windowsの場合:**
```
C:\Program Files (x86)\Steam\steamapps\common\uDesktopMascot\application_settings.txt
```

**設定内容:**
```ini
[Character]
ModelPath=default.vrm
Scale=3
PositionX=0
PositionY=0
PositionZ=0
RotationX=0
RotationY=0
RotationZ=0

[Sound]
VoiceVolume=1.0
BGMVolume=0.0
SEVolume=1.0

[