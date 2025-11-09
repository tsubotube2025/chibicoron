"""
為替レート監視uDesktopMascot統合スクリプト
spikweatch-mt5のWebSocketから通知を受信し、VOICEVOXで発話
"""

import asyncio
import json
import threading
import requests
import websockets
from pathlib import Path
from datetime import datetime
import sys

class VOICEVOXManager:
    """VOICEVOX音声合成マネージャー（AItuberKitと共存可能）"""
    
    def __init__(self, voicevox_url="http://localhost:50021"):
        self.voicevox_url = voicevox_url
        self.lock = threading.Lock()
        
    def speak(self, text, speaker=1):
        """
        テキストを音声合成して再生
        speaker: 話者ID（1=四国めたん（ノーマル）など）
        """
        with self.lock:
            try:
                # VOICEVOXサーバーの動作確認
                health = requests.get(f"{self.voicevox_url}/version", timeout=2)
                if health.status_code != 200:
                    print("VOICEVOX server not responding")
                    return False
                
                # 音声クエリ作成
                query_response = requests.post(
                    f"{self.voicevox_url}/audio_query",
                    params={"text": text, "speaker": speaker},
                    timeout=10
                )
                query_response.raise_for_status()
                query_data = query_response.json()
                
                # 音声合成
                synthesis_response = requests.post(
                    f"{self.voicevox_url}/synthesis",
                    params={"speaker": speaker},
                    json=query_data,
                    timeout=30
                )
                synthesis_response.raise_for_status()
                
                # 一時ファイルに保存
                temp_dir = Path("temp_audio")
                temp_dir.mkdir(exist_ok=True)
                audio_file = temp_dir / f"voice_{int(asyncio.get_event_loop().time() * 1000)}.wav"
                
                with open(audio_file, "wb") as f:
                    f.write(synthesis_response.content)
                
                # 音声再生
                self._play_audio(str(audio_file))
                
                # 再生後、少し待ってからファイル削除
                import time
                time.sleep(0.5)
                try:
                    audio_file.unlink()
                except:
                    pass
                
                return True
                
            except requests.exceptions.ConnectionError:
                print("VOICEVOXサーバーに接続できません。起動しているか確認してください。")
                return False
            except Exception as e:
                print(f"VOICEVOX Error: {e}")
                return False
    
    def _play_audio(self, audio_file):
        """プラットフォーム別音声再生"""
        import platform
        import os
        
        system = platform.system()
        if system == "Windows":
            import winsound
            winsound.PlaySound(audio_file, winsound.SND_FILENAME)
        elif system == "Darwin":
            os.system(f"afplay '{audio_file}'")
        else:
            os.system(f"aplay '{audio_file}'")


class ForexMascot:
    """為替監視マスコット本体（spikweatch-mt5のWebSocketクライアント）"""
    
    def __init__(self, config_path="mascot_config.json"):
        self.config = self._load_config(config_path)
        self.voicevox = VOICEVOXManager(
            self.config.get("voicevox_url", "http://localhost:50021")
        )
        self.speaker_id = self.config.get("speaker_id", 1)
        self.ws_url = self.config.get("spikweatch_ws_url", "ws://localhost:8000")
        self.running = False
        self.reconnect_delay = 5  # 再接続待機時間（秒）
        
    def _load_config(self, config_path):
        """設定ファイル読み込み"""
        default_config = {
            "voicevox_url": "http://localhost:50021",
            "spikweatch_ws_url": "ws://localhost:8000",
            "speaker_id": 1,
            "enable_system_messages": False,  # システムメッセージを喋るか
            "enable_mascot_filter": True,  # マスコット用にメッセージを簡潔化
            "custom_templates": {
                # カスタムメッセージテンプレート（オプション）
                "spike_up": "{jp_name}が{pips}pips上昇です",
                "spike_down": "{jp_name}が{pips}pips下落です"
            }
        }
        
        try:
            if Path(config_path).exists():
                with open(config_path, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                default_config.update(user_config)
        except Exception as e:
            print(f"Config load error: {e}, using defaults")
        
        return default_config
    
    def format_message_for_mascot(self, message_data):
        """
        spikweatch-mt5からのメッセージをマスコット用に整形
        """
        try:
            msg_type = message_data.get("type", "message")
            role = message_data.get("role", "assistant")
            text = message_data.get("text", "")
            
            # システムメッセージをスキップ（設定による）
            if role == "system" and not self.config.get("enable_system_messages", False):
                return None
            
            # マスコット用にシンプル化（設定による）
            if self.config.get("enable_mascot_filter", True):
                # 改行を削除してシンプルに
                text = text.replace("\n", "。")
                # 絵文字を読み上げないように削除
                import re
                text = re.sub(r'[📊⚠️🚨]', '', text)
            
            return text
            
        except Exception as e:
            print(f"Message format error: {e}")
            return None
    
    async def connect_and_listen(self):
        """WebSocketサーバーに接続してメッセージを受信"""
        while self.running:
            try:
                print(f"spikweatch-mt5に接続中... ({self.ws_url})")
                
                async with websockets.connect(self.ws_url) as websocket:
                    print("✓ 接続成功")
                    
                    # 接続成功メッセージ
                    self.voicevox.speak("為替監視システムに接続しました", self.speaker_id)
                    
                    # メッセージ受信ループ
                    async for message in websocket:
                        try:
                            data = json.loads(message)
                            
                            # メッセージをマスコット用に整形
                            text = self.format_message_for_mascot(data)
                            
                            if text:
                                timestamp = datetime.now().strftime("%H:%M:%S")
                                print(f"[{timestamp}] 受信: {text}")
                                
                                # VOICEVOXで発話（別スレッドで実行して非同期処理をブロックしない）
                                loop = asyncio.get_event_loop()
                                await loop.run_in_executor(
                                    None, 
                                    self.voicevox.speak, 
                                    text, 
                                    self.speaker_id
                                )
                        
                        except json.JSONDecodeError as e:
                            print(f"JSON parse error: {e}")
                        except Exception as e:
                            print(f"Message processing error: {e}")
            
            except websockets.exceptions.ConnectionClosed:
                print("✗ 接続が切断されました")
            except ConnectionRefusedError:
                print(f"✗ 接続拒否: spikweatch-mt5が起動していません")
            except Exception as e:
                print(f"✗ 接続エラー: {e}")
            
            if self.running:
                print(f"{self.reconnect_delay}秒後に再接続します...")
                await asyncio.sleep(self.reconnect_delay)
    
    async def start(self):
        """監視開始"""
        self.running = True
        print("=" * 60)
        print("為替監視マスコット起動")
        print(f"VOICEVOX: {self.config['voicevox_url']}")
        print(f"spikweatch-mt5: {self.ws_url}")
        print(f"話者ID: {self.speaker_id}")
        print("=" * 60)
        
        try:
            await self.connect_and_listen()
        except KeyboardInterrupt:
            print("\n停止中...")
        finally:
            self.stop()
    
    def stop(self):
        """監視停止"""
        self.running = False
        print("為替監視マスコット停止")


async def main():
    """メイン関数"""
    import argparse
    
    parser = argparse.ArgumentParser(description="為替監視マスコット（WebSocket版）")
    parser.add_argument("--config", default="mascot_config.json", help="設定ファイルパス")
    parser.add_argument("--ws-url", help="spikweatch-mt5 WebSocket URL (例: ws://localhost:8000)")
    parser.add_argument("--speaker", type=int, help="VOICEVOX話者ID")
    parser.add_argument("--auto", action="store_true", help="自動起動モード（Enter待ちをスキップ）")
    args = parser.parse_args()
    
    mascot = ForexMascot(args.config)
    
    # コマンドライン引数で上書き
    if args.ws_url:
        mascot.ws_url = args.ws_url
    if args.speaker:
        mascot.speaker_id = args.speaker
    
    await mascot.start()


if __name__ == "__main__":
    # コマンドライン引数をチェック
    auto_start = "--auto" in sys.argv or "--background" in sys.argv
    
    print("\n" + "=" * 60)
    print("為替監視マスコット (uDesktopMascot + VOICEVOX)")
    print("=" * 60)
    print("\n【起動前の確認】")
    print("1. VOICEVOX が起動していること (http://localhost:50021)")
    print("2. spikweatch-mt5 が起動していること (WebSocketサーバー)")
    print("3. AItuberKit が起動していること（同じVOICEVOXを使用）")
    
    # 自動起動モードでなければEnter待ち
    if not auto_start:
        print("\n※ Enterキーで起動します...")
        input()
    else:
        print("\n※ 自動起動モード: すぐに起動します...")
        import time
        time.sleep(1)
    
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n✓ 終了しました")