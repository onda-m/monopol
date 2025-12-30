# SkyWay iOS SDK Swift Sample

```
swift 4.0以上
Xcode 9.0以上
ios 9.0以上
Cocoapods 1.0.0以上

```

## 機能


- 1-1の映像サンプル
- 1-1のチャットサンプル

## セットアップ

### 1. ライブラリのインストール

```
$ pod install
```

### 2. APIKEY, DOMAINの書き換え

```
// AppDelegate.swift
// https://webrtc.ecl.ntt.com/からAPIKeyとDomainを取得してください
var skywayAPIKey:String? = "xxx"
var skywayDomain:String? = "xxx"

```

## SkyWay Room SDK を使った接続フロー

`SkywayManager` で SkyWay の Room 接続を扱うように整理しました。最低限の利用手順は以下の通りです。

1. 画面のライフサイクルに合わせて `SkywayManager.shared.startSession(delegate:)` で `SKWPeer` を初期化する（未初期化のまま `prepareLocalStream` を呼ぶとエラー通知が返ります）。
2. `prepareLocalStream(in:)` でローカル映像ストリームを生成し、`SKWVideo` に割り当てる。
3. `joinRoom(named:)` でメッシュ/ SFU ルームへ参加し、`SkywaySessionDelegate` でリモートストリームの増減を受け取る。
4. 退室や画面終了時は `leaveRoom()` や `endSession()` を呼び、ストリームと Peer を確実に破棄する。

コールバックはメインスレッドへ配送されるため、UI の更新を直接行えます。Room の publish/subscribe の状態変化は `SkywaySessionDelegate` で受け取り、必要に応じて `joinRoom` 呼び出し時の `optionBuilder` で SkyWay の `SKWRoomOption` をカスタマイズしてください。Peer ID を持たないストリームも破棄漏れなくクリーンアップされるようになっています。
