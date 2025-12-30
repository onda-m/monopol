# SkyWay iOS SDK Swift Sample

## 対応環境

```
Swift 5.0以上
Xcode 12.0以上
iOS 13.0以上
CocoaPods 1.10.0以上
```

## 機能

- 1-1の映像サンプル
- 1-1のチャットサンプル

## セットアップ

### 1. ライブラリのインストール

Podfile に SkyWay の公式 Specs レポジトリを追加済みです。`monopol-p2p` ディレクトリで以下を実行して依存ライブラリを取得してください。

```
$ pod install
```

### 2. APIKEY, DOMAINの書き換え

`swift/SkywayManager.swift` 内の `apiKey` と `domain` を、新SkyWay コンソールで発行した値に差し替えてください。テンプレートのままでは接続前にエラー通知が返るため、確実に設定漏れを検知できます。

## SkyWay Room SDK を使った接続フロー

`SkywayManager` で SkyWay の Room 接続を扱うように整理しました。最低限の利用手順は以下の通りです。

1. 画面のライフサイクルに合わせて `SkywayManager.shared.startSession(delegate:)` で `SKWPeer` を初期化する（未初期化のまま `prepareLocalStream` を呼ぶとエラー通知が返ります）。
2. `prepareLocalStream(in:)` でローカル映像ストリームを生成し、`SKWVideo` に割り当てる。
3. `joinRoom(named:)` でメッシュ/ SFU ルームへ参加し、`SkywaySessionDelegate` でリモートストリームの増減を受け取る。
4. 退室や画面終了時は `leaveRoom()` や `endSession()` を呼び、ストリームと Peer を確実に破棄する。

コールバックはメインスレッドへ配送されるため、UI の更新を直接行えます。Room の publish/subscribe の状態変化は `SkywaySessionDelegate` で受け取り、必要に応じて `joinRoom` 呼び出し時の `optionBuilder` で SkyWay の `SKWRoomOption` をカスタマイズしてください。

Peer ID を持たないストリームも破棄漏れなくクリーンアップされるようになっています。
