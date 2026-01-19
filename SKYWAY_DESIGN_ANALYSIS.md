# SkyWay iOS通話アプリ 設計棚卸しドキュメント

**作成日**: 2026-01-19
**対象**: monopol-p2p iOS/Swift アプリケーション
**SDK**: SkyWay Room SDK 3.1.1（新SDK）移行済み

---

## ⚠️ 重要な前提事項

このリポジトリは**すでにSkyWay Room SDK 3.1.1（新世代SDK）へ移行完了**しています。
- 旧SDK（`SKWPeer`, `MediaConnection` 等）の痕跡なし
- 本ドキュメントの目的：**現行実装の複雑性整理と改善設計の提示**

---

## 1. 現状アーキテクチャ概要

### 1.1 主要コンポーネント一覧

| コンポーネント | ファイルパス | 責務 | 行数 | 複雑度 |
|-------------|------------|------|------|--------|
| **SkywayManager** | `swift/SkywayManager.swift` | 汎用SkyWay管理（シングルトン）<br>- 1 Room管理（P2P）<br>- ストリーム生成・publish/subscribe<br>- ビデオレンダリング制御 | 325 | ★★☆☆☆ |
| **WaitViewController** | `swift/cast/WaitViewController.swift` | キャスター待機画面UI<br>- ローカルビデオプレビュー<br>- リスナー受け入れ<br>- 予約管理 | - | ★★★☆☆ |
| **WaitViewController+CommonSkyway** | `swift/cast/WaitViewController+CommonSkyway.swift` | キャスター側SkyWay実装<br>- **Dual Room管理**（P2P + SFU）<br>- ストリーム管理・コールバック<br>- オーディオセッション制御<br>- Firebase連携（ポイント計算） | 781 | ★★★★★ |
| **MediaConnectionViewController** | `swift/user/MediaConnectionViewController.swift` | リスナー視聴画面UI<br>- リモートビデオ表示<br>- チャット・エフェクト<br>- ポイント管理 | - | ★★★☆☆ |
| **MediaConnectionViewController+CommonSkyway** | `swift/user/MediaConnectionViewController+CommonSkyway.swift` | リスナー側SkyWay実装<br>- **Dual Room管理**（P2P + SFU）<br>- ストリーム購読<br>- データ通信・チャット<br>- Firebase同期（ライブ状態） | 1202 | ★★★★★ |
| **Util** | `swift/common/Util.swift` | SkyWay Context初期化<br>- `setupSkyWayRoomContextIfNeeded()`<br>- タスクキャッシング機構 | - | ★★☆☆☆ |

### 1.2 責務マトリクス

| 責務 | SkywayManager | WaitVC+Skyway | MediaVC+Skyway | 備考 |
|------|--------------|---------------|----------------|------|
| **Context初期化** | ✓ (Util経由) | ✓ (Util経由) | ✓ (Util経由) | 全てUtilで統一 |
| **Room Join/Leave** | ✓ (1個) | ✓ (2個) | ✓ (2個) | Dual-Room構造 |
| **ストリーム生成** | ✓ | ✓ | ✓ | 重複実装 |
| **Publish** | ✓ | ✓ | ✓ | 重複実装 |
| **Subscribe** | ✓ | ✓ | ✓ | 重複実装 |
| **ビデオレンダリング** | ✓ | ✓ | ✓ | 重複実装 |
| **オーディオルート制御** | ✗ | ✓ | ✓ | ViewControllerに散在 |
| **データ通信（チャット）** | ✗ | ✓ | ✓ | ViewControllerに散在 |
| **Firebase同期** | ✗ | ✓ | ✓ | ビジネスロジックと密結合 |
| **ポイント計算** | ✗ | ✓ | ✓ | ビジネスロジックと密結合 |
| **エラーハンドリング** | Delegate | print文 | print文 | 統一性なし |

### 1.3 依存関係図

```
[AppDelegate]
    ↓
[Util.setupSkyWayRoomContextIfNeeded()]
    ├─ SkyWayRoom.Context.setupForDev(appId, secretKey)
    └─ タスクキャッシング（skywayRoomContextTask）

[SkywayManager (Singleton)]
    ├─ Room (P2P) × 1
    ├─ LocalRoomMember × 1
    ├─ ストリーム管理（Audio/Video/Data）
    └─ SkywaySessionDelegate（コールバック）

[WaitViewController] ━━━━━━━━━┓
    ↓                        ┃
[WaitViewController+CommonSkyway] ┃ 密結合
    ├─ Room (P2P) × 1      ┃
    ├─ WaitRoom (SFU) × 1  ┃
    ├─ Firebase監視        ┃
    ├─ ポイント計算         ┃
    └─ オーディオ制御       ┃

[MediaConnectionViewController] ━━━┛
    ↓
[MediaConnectionViewController+CommonSkyway]
    ├─ Room (P2P) × 1
    ├─ WaitRoom (SFU) × 1
    ├─ Firebase監視
    ├─ チャット・エフェクト
    └─ ポイント消費
```

### 1.4 アーキテクチャ上の問題点

1. **責務の重複**: SkywayManager と各ViewController で同じストリーム管理ロジックが重複
2. **Dual-Room構造の複雑性**:
   - P2P Room（1対1通話用）
   - SFU WaitRoom（待機中リスナー監視用）
   - 2つのRoomを同時管理し、状態が散在
3. **ビジネスロジックとの密結合**: Firebase・ポイント計算がSkyWay処理と混在
4. **SkywayManagerの未活用**: 汎用設計だが実際は各ViewControllerで独自実装

---

## 2. 通話フローの状態遷移

### 2.1 キャスター側（WaitViewController）状態遷移図

```
[初期状態: Idle]
    │
    │ setup() 呼び出し
    ↓
[状態1: Initializing]
    │ - Util.setupSkyWayRoomContextIfNeeded()
    │ - joinRoomIfNeeded(roomName: user_id)        [P2P Room]
    │ - joinWaitRoomIfNeeded(roomName: "waiting-room") [SFU Room]
    ↓
[状態2: WaitingForListener]
    │ - publishLocalStreams() 完了
    │ - 待機UI表示
    │ - リスナー参加待ち
    │
    │ onMemberJoined イベント（リスナー参加）
    ↓
[状態3: ConnectingToListener]
    │ - リモートメンバー検出
    │ - room.members.count チェック（>2なら退出）
    │
    │ onPublicationPublished イベント
    ↓
[状態4: InCall]
    │ - subscribeToPublication()
    │ - handleRemoteMediaConnected()
    │ - startConnection() ← ポイント計算・タイマー開始
    │ - Firebase監視開始
    │ - オーディオ監視（addAudioSessionObservers）
    │
    │ 許可操作: チャット送信、マイクON/OFF、終了ボタン
    │
    │ ─── 正常終了 ───
    │ endCallButton タップ
    ↓
[状態5: Disconnecting]
    │ - closeMedia()
    │ - cleanupRoomResources()
    │ - leaveRoomIfNeeded() / leaveWaitRoomIfNeeded()
    ↓
[状態6: Idle]

    │ ─── 異常終了 ───
    │ onMemberLeft イベント（リスナー離脱）
    ↓
[状態7: AbnormalDisconnection]
    │ - handleRemoteMediaDisconnected()
    │ - listenerStatus = 1（異常フラグ）
    │ - Firebase状態確認
    ↓
[状態6: Idle]
```

### 2.2 リスナー側（MediaConnectionViewController）状態遷移図

```
[初期状態: Idle]
    │
    │ setup() 呼び出し（キャスター選択後）
    ↓
[状態1: Initializing]
    │ - Util.setupSkyWayRoomContextIfNeeded()
    │ - joinRoomIfNeeded(roomName: liveCastId)     [P2P Room]
    │ - joinWaitRoomIfNeeded(roomName: "waiting-room") [SFU Room]
    ↓
[状態2: JoiningRoom]
    │ - room.join() 完了
    │ - publishLocalStreams()（リスナー側もpublish）
    │ - attachRoomCallbacks()
    │
    │ onPublicationPublished イベント（キャスターのストリーム）
    ↓
[状態3: SubscribingStreams]
    │ - subscribeToPublication()
    │   ├─ RemoteVideoStream → attachRemoteVideo()
    │   ├─ RemoteAudioStream → 保持
    │   └─ RemoteDataStream → setupRemoteDataCallbacks()
    ↓
[状態4: InCall]
    │ - handleRemoteMediaConnected()
    │ - handleDataConnectionOpen()
    │   ├─ ポイント消費処理
    │   ├─ 絆レベル更新
    │   ├─ タイマー開始
    │   └─ Firebase監視開始
    │ - オーディオ監視（addAudioSessionObservers）
    │
    │ 許可操作: チャット送信、エフェクト選択、画面リフレッシュ、終了
    │
    │ ─── 正常終了 ───
    │ onMemberLeft イベント（キャスター退出）
    ↓
[状態5: CheckingCasterStatus]
    │ - handleRemoteMediaDisconnected()
    │ - API: キャスター状態確認
    │ - login_status チェック
    ↓
[状態6: Disconnecting]
    │ - endLiveDo()
    │ - Firebase データ削除
    │ - closeMedia()
    ↓
[状態7: Idle]

    │ ─── 画面リフレッシュ ───
    │ refreshAction() 呼び出し
    ↓
[状態8: Refreshing]
    │ - isReconnect = true
    │ - sessionClose() → 1秒後
    │ - setup() → 3秒後（再接続）
    ↓
[状態4: InCall]（復帰）
```

### 2.3 状態別の詳細仕様

| 状態 | 主要処理 | 発火イベント | UI更新 | エラー処理 |
|------|---------|------------|--------|-----------|
| **Idle** | - | - | 待機画面 | - |
| **Initializing** | Context setup, Room作成・Join | - | ローディング表示 | connectError() |
| **WaitingForListener** | publish完了、待機 | onMemberJoined | 「待機中」表示 | タイムアウト |
| **ConnectingToListener** | リモートメンバー検出 | onPublicationPublished | 接続中UI | subscribe失敗 |
| **InCall** | ストリーム表示、Firebase同期 | onData（チャット）<br>AVAudioSession通知 | リモートビデオ表示<br>チャット更新 | 音声断、ネットワーク断 |
| **Disconnecting** | リソースクリーンアップ | - | 終了アニメーション | leave失敗は無視 |
| **AbnormalDisconnection** | 状態確認、返金判定 | - | エラーダイアログ | - |
| **Refreshing** | 再接続シーケンス | - | 「リフレッシュ中」 | 再接続失敗 |

---

## 3. 新SDK API・イベント使用パターン整理

> **注**: 本プロジェクトは新SDK移行済みのため、旧SDK対応表ではなく**現行の新SDK使用パターン**を整理

### 3.1 SkyWay Room SDK 3.1.1 使用API一覧

| カテゴリ | API/イベント | 利用箇所 | 目的 | 注意点 |
|---------|-------------|---------|------|--------|
| **初期化** | `Context.setupForDev(appId:secretKey:)` | `Util.swift:77` | Context初期化（開発用） | **@MainActor**, タスクキャッシング実装済み |
| **Room管理** | `Room.findOrCreate(with:)` | SkywayManager:155<br>WaitVC:208<br>MediaVC:105 | Room検索・作成 | `async throws` |
| | `Room.join(with:)` | SkywayManager:159<br>WaitVC:213<br>MediaVC:110 | Room参加 | `LocalRoomMember` 返却 |
| | `LocalRoomMember.leave()` | SkywayManager:263<br>WaitVC:374<br>MediaVC:295 | Room退出 | `try?`でエラー無視 |
| **ストリーム生成** | `MicrophoneAudioSource()` | 全箇所 | オーディオソース生成 | - |
| | `CameraVideoSource.shared()` | 全箇所 | ビデオソース生成（シングルトン） | - |
| | `DataSource()` | 全箇所 | データソース生成 | - |
| | `audioSource.createStream()` | 全箇所 | LocalAudioStream生成 | - |
| | `videoSource.createStream()` | 全箇所 | LocalVideoStream生成 | startCapturing必須 |
| | `dataSource.createStream()` | 全箇所 | LocalDataStream生成 | - |
| **Publish** | `localMember.publish(_:options:)` | SkywayManager:206-213<br>WaitVC:303-310<br>MediaVC:224-231 | ストリーム配信 | `RoomPublication` 返却 |
| | `localMember.unpublish(publicationId:)` | SkywayManager:282 | 配信停止 | cleanupで使用 |
| **Subscribe** | `localMember.subscribe(publicationId:options:)` | SkywayManager:244<br>WaitVC:345<br>MediaVC:266 | ストリーム購読 | `RoomSubscription` 返却 |
| | `localMember.unsubscribe(subscriptionId:)` | SkywayManager:278 | 購読停止 | cleanupで使用 |
| **イベント** | `room.onMemberJoined { }` | SkywayManager:182<br>WaitVC:256<br>MediaVC:152 | メンバー参加通知 | `[weak self]` 必須 |
| | `room.onPublicationPublished { }` | WaitVC:265<br>MediaVC:161 | ストリーム発行通知 | subscribe契機 |
| | `room.onMemberLeft { }` | WaitVC:275<br>MediaVC:171 | メンバー退出通知 | 切断処理契機 |
| | `remoteDataStream.onData { }` | WaitVC:365<br>MediaVC:286 | データ受信通知 | チャット実装 |
| **ビデオ** | `CameraVideoSource.startCapturing(with:options:)` | SkywayManager:229<br>WaitVC:329<br>MediaVC:250 | カメラ起動 | `async throws` |
| | `cameraVideoSource.attach(_:)` | SkywayManager:297 | プレビュー表示 | CameraPreviewView |
| | `remoteVideoStream.attach(_:)` | SkywayManager:311<br>WaitVC:400<br>MediaVC:79 | リモート映像表示 | VideoView |
| **オーディオ** | `localAudioStream.setEnabled(_:)` | WaitVC:438-443 | マイクON/OFF | - |
| | `remoteAudioStream.setEnabled(_:)` | MediaVC:339-558 | リモート音声ON/OFF | - |
| **データ** | `localDataStream.write(_:)` | WaitVC:735<br>MediaVC:1094 | データ送信 | Data型 |

### 3.2 設計上の問題点

| 問題 | 詳細 | 影響度 |
|-----|------|--------|
| **重複実装** | ストリーム生成・publish/subscribeが各所に重複 | ★★★★☆ |
| **エラーハンドリングの不統一** | `try?`でエラー無視、`print`文のみ | ★★★★★ |
| **@MainActor不徹底** | 一部関数のみ`@MainActor`、UI更新の安全性不明 | ★★★☆☆ |
| **コールバック地獄** | クロージャが多重ネスト、可読性低下 | ★★★☆☆ |
| **Task管理の曖昧性** | `roomTask`のキャンセルタイミングが不明瞭 | ★★★☆☆ |

### 3.3 移行時の注意点（新SDK特有）

| 項目 | 注意内容 |
|-----|---------|
| **スレッド安全性** | `@MainActor`必須の関数多数。UI更新前に`DispatchQueue.main.async`不要 |
| **非同期処理** | `async/await`ベース。`Task { }`でラップ必要 |
| **メモリ管理** | クロージャに`[weak self]`必須。循環参照リスク高 |
| **ライフサイクル** | Room/Publication/Subscriptionの寿命管理が複雑 |
| **Null安全** | Optional多用。`guard let`チェーン長い |

---

## 4. "最小で動く"新SDK骨格（MVP）の設計

### 4.1 MVP要件定義

**最小MVPの条件**:
1. ✅ Context初期化（`setupForDev`）
2. ✅ Room Join（P2P形態）
3. ✅ ローカルストリーム Publish（Audio + Video + Data）
4. ✅ リモートPublication検知（`onPublicationPublished`）
5. ✅ Subscribe実行
6. ✅ ビデオ表示（Local Preview + Remote View）
7. ✅ Leave処理（リソースクリーンアップ）

**除外する機能**:
- ❌ Dual-Room構造（SFU WaitRoom）
- ❌ Firebase連携
- ❌ ポイント計算
- ❌ チャット履歴保存
- ❌ エフェクト機能
- ❌ 予約管理
- ❌ 再接続ロジック（画面リフレッシュ）

### 4.2 責務分割（推奨アーキテクチャ）

```
┌─────────────────────────────────────────┐
│   UI Layer (ViewController)            │
│   - ユーザー操作受付                      │
│   - UI更新                              │
│   - CallSessionDelegateの実装            │
└────────────┬────────────────────────────┘
             │
             ↓ 依存
┌─────────────────────────────────────────┐
│   CallSession (状態管理)                 │
│   - 通話状態のFSM管理                     │
│   - UIとSkyWayの仲介                     │
│   - ビジネスロジック連携                   │
└────────────┬────────────────────────────┘
             │
             ↓ 依存
┌─────────────────────────────────────────┐
│   SkyWayService (SkyWay専用層)          │
│   - Room管理（1対1のみ）                 │
│   - Stream管理                          │
│   - Publish/Subscribe                   │
│   - イベント集約・変換                    │
└────────────┬────────────────────────────┘
             │
             ↓ 依存
┌─────────────────────────────────────────┐
│   SkyWay Room SDK 3.1.1                │
└─────────────────────────────────────────┘
```

### 4.3 新設計のクラス構成

#### 4.3.1 SkyWayService（新規作成推奨）

**責務**: SkyWay Room SDK の薄いラッパー

```swift
protocol SkyWayServiceDelegate: AnyObject {
    func skyway(didChangeState state: CallState)
    func skyway(didReceiveRemoteVideo stream: RemoteVideoStream)
    func skyway(didReceiveRemoteAudio stream: RemoteAudioStream)
    func skyway(didReceiveData data: Data)
    func skyway(didEncounterError error: SkyWayError)
}

@MainActor
class SkyWayService {
    // MARK: - Properties
    private var room: Room?
    private var localMember: LocalRoomMember?
    private var publications: [RoomPublication] = []
    private var subscriptions: [RoomSubscription] = []
    private var streams: StreamContainer
    private weak var delegate: SkyWayServiceDelegate?

    // MARK: - Public Methods
    func initialize() async throws
    func join(roomName: String, memberName: String) async throws
    func publishStreams() async throws
    func leave() async
    func sendData(_ data: Data)

    // MARK: - Private Methods
    private func attachCallbacks()
    private func subscribeToPublication(_ publication: RoomPublication) async
    private func cleanupResources()
}
```

**特徴**:
- SkyWayロジックのみに集中
- ビジネスロジック（Firebase、ポイント）を含まない
- テスタブル（Protocol化）

#### 4.3.2 CallSession（新規作成推奨）

**責務**: 通話セッションの状態管理

```swift
enum CallState {
    case idle
    case initializing
    case waiting
    case connecting
    case inCall
    case disconnecting
}

protocol CallSessionDelegate: AnyObject {
    func callSession(_ session: CallSession, didChangeState state: CallState)
    func callSession(_ session: CallSession, didUpdateDuration duration: Int)
    func callSession(_ session: CallSession, didReceiveMessage message: String)
    func callSession(_ session: CallSession, didEncounterError error: Error)
}

@MainActor
class CallSession {
    private(set) var state: CallState = .idle
    private let skyWayService: SkyWayService
    private weak var delegate: CallSessionDelegate?

    func start(roomName: String, memberName: String) async throws
    func end()
    func sendMessage(_ message: String)

    private func transitionTo(_ newState: CallState)
}
```

**特徴**:
- 状態遷移の明確化
- SkyWayServiceとビジネスロジックの仲介
- タイマー・ライフサイクル管理

#### 4.3.3 既存クラスの役割変更

| クラス | 現状の役割 | 新設計での役割 | 変更内容 |
|-------|----------|--------------|---------|
| **SkywayManager** | シングルトンで汎用管理 | **削除**または**SkyWayService**へ統合 | 重複排除 |
| **WaitViewController** | UI + SkyWay実装 | UIのみ | SkyWay処理をCallSessionへ委譲 |
| **MediaConnectionViewController** | UI + SkyWay実装 | UIのみ | SkyWay処理をCallSessionへ委譲 |

### 4.4 「残すもの」「置換するもの」「ラップするもの」

| 要素 | 判定 | 理由 |
|-----|------|------|
| **SkywayManager** | 🔴 置換 | 新SkyWayServiceへ統合。Singleton不要 |
| **各VC+CommonSkyway Extension** | 🔴 置換 | CallSessionへ移動 |
| **Util.setupSkyWayRoomContextIfNeeded** | 🟢 残す | 既に最適化済み（タスクキャッシング） |
| **SkywaySessionDelegate** | 🟡 ラップ | CallSessionDelegateに再設計 |
| **Dual-Room構造** | 🟡 段階的削除 | まずP2Pのみ対応、SFU Roomは別機能化 |
| **Firebase監視** | 🟢 残す（分離） | 別サービス層へ移動（CallSessionから切り離し） |
| **ポイント計算** | 🟢 残す（分離） | ビジネスロジック層へ移動 |
| **オーディオセッション管理** | 🟢 残す（整理） | AudioSessionManagerとして独立 |

---

## 5. 移行手順（PR分割案）

### PR#1: ビルドを通す/依存整理
**目的**: 設計変更の下準備

| 項目 | 内容 |
|-----|------|
| **触るファイル** | - `Podfile`（SkyWay Room SDK バージョン確認）<br>- プロジェクト設定（警告修正）<br>- `Util.swift`（Context初期化の確認） |
| **作業内容** | - 未使用コードの削除（コメントアウト部分）<br>- Deprecation警告の修正<br>- ビルド設定の整理 |
| **完了条件** | - ビルドエラー0<br>- 警告0<br>- 現行機能が正常動作 |
| **想定リスク** | - Firebase依存の破壊<br>- ビルド時間の増加 |
| **推定工数** | 1日 |

---

### PR#2: SkyWayService抽出（MVP実装）
**目的**: SkyWayロジックの独立化

| 項目 | 内容 |
|-----|------|
| **新規ファイル** | - `SkyWayService.swift`（新規）<br>- `SkyWayServiceProtocol.swift`（新規）<br>- `StreamContainer.swift`（新規） |
| **変更ファイル** | - `SkywayManager.swift`（非推奨化） |
| **作業内容** | 1. SkyWayServiceクラス作成<br>　　- Room管理（P2P 1個のみ）<br>　　- Stream生成・Publish・Subscribe<br>　　- イベントコールバック集約<br>2. ユニットテスト作成<br>3. SkywayManagerから段階的移行 |
| **完了条件** | - SkyWayServiceでjoin→publish→subscribe→leave完結<br>- ユニットテスト通過（Mock使用）<br>- 既存機能に影響なし |
| **想定リスク** | - @MainActor境界でのスレッド問題<br>- メモリリーク（循環参照）<br>- イベントタイミングのズレ |
| **推定工数** | 3日 |

---

### PR#3: CallSession実装（状態管理層）
**目的**: 通話状態のFSM化

| 項目 | 内容 |
|-----|------|
| **新規ファイル** | - `CallSession.swift`（新規）<br>- `CallState.swift`（Enum）<br>- `CallSessionDelegate.swift`（Protocol） |
| **変更ファイル** | - `WaitViewController+CommonSkyway.swift`（一部移行）<br>- `MediaConnectionViewController+CommonSkyway.swift`（一部移行） |
| **作業内容** | 1. CallSessionクラス作成<br>　　- 状態遷移ロジック実装<br>　　- SkyWayServiceとの連携<br>　　- タイマー管理<br>2. ViewControllerからSkyWay処理を委譲<br>3. 状態遷移テスト作成 |
| **完了条件** | - 状態遷移が意図通り動作<br>　　Idle → Initializing → Waiting → InCall → Idle<br>- UIが状態変化に追従<br>- 既存の通話フローが維持 |
| **想定リスク** | - 状態遷移の抜け漏れ<br>- Firebase同期タイミングのズレ<br>- UI更新の遅延 |
| **推定工数** | 4日 |

---

### PR#4: Dual-Room構造の整理
**目的**: P2P Room と SFU WaitRoom の分離

| 項目 | 内容 |
|-----|------|
| **新規ファイル** | - `WaitRoomService.swift`（SFU専用） |
| **変更ファイル** | - `WaitViewController+CommonSkyway.swift`<br>- `MediaConnectionViewController+CommonSkyway.swift` |
| **作業内容** | 1. WaitRoomService作成（SFU Room専用）<br>　　- 待機メンバー数管理<br>　　- リスナー一覧取得<br>2. CallSessionからWaitRoom処理を分離<br>3. 2つのRoomの独立管理 |
| **完了条件** | - P2P Room と SFU Room が独立動作<br>- 待機メンバー数が正確<br>- Room間の干渉なし |
| **想定リスク** | - Room切り替えタイミングの問題<br>- メンバー数カウントの不整合<br>- メモリ使用量の増加 |
| **推定工数** | 3日 |

---

### PR#5: 切断・再接続・画面遷移の整理
**目的**: 例外フローの安定化

| 項目 | 内容 |
|-----|------|
| **変更ファイル** | - `CallSession.swift`<br>- `SkyWayService.swift`<br>- `MediaConnectionViewController+CommonSkyway.swift:935`（refreshAction） |
| **作業内容** | 1. 再接続ロジックの整理<br>　　- `isReconnect`フラグの削除<br>　　- 状態ベースの再接続判定<br>2. 切断検知の統一<br>　　- `onMemberLeft`処理の共通化<br>3. 画面リフレッシュの改善<br>　　- 1秒後close → 3秒後setup の見直し |
| **完了条件** | - 正常切断・異常切断が適切に区別される<br>- 再接続時にポイント計算が重複しない<br>- 画面リフレッシュが安定動作 |
| **想定リスク** | - タイミング競合（close中にsetup呼び出し）<br>- Firebase状態の不整合<br>- メモリリーク（Task未キャンセル） |
| **推定工数** | 3日 |

---

### PR#6: 例外系（権限、バックグラウンド、ネットワーク断、トークン期限）
**目的**: エッジケースの網羅

| 項目 | 内容 |
|-----|------|
| **新規ファイル** | - `PermissionManager.swift`（権限管理）<br>- `NetworkMonitor.swift`（ネットワーク監視） |
| **変更ファイル** | - `CallSession.swift`<br>- `SkyWayService.swift`<br>- `AppDelegate.swift`（バックグラウンド処理） |
| **作業内容** | 1. 権限管理の統一<br>　　- カメラ・マイク権限の事前確認<br>　　- 権限拒否時のエラー表示<br>2. バックグラウンド対応<br>　　- `applicationDidEnterBackground`時の処理<br>　　- 通話中のバックグラウンド維持<br>3. ネットワーク断検知<br>　　- Reachability監視<br>　　- 再接続トリガー<br>4. トークン期限エラー対応<br>　　- Context再初期化 |
| **完了条件** | - カメラ権限なしで適切なエラー表示<br>- バックグラウンド→フォアグラウンド復帰で通話継続<br>- Wi-Fi断→復帰で自動再接続<br>- トークン期限切れで再認証 |
| **想定リスク** | - バックグラウンドでのメモリ警告<br>- ネットワーク切り替え時のクラッシュ<br>- 権限ダイアログの重複表示 |
| **推定工数** | 4日 |

---

### PR#7: オーディオセッション管理の改善
**目的**: 音声ルート制御の安定化

| 項目 | 内容 |
|-----|------|
| **新規ファイル** | - `AudioSessionManager.swift`（新規） |
| **変更ファイル** | - `WaitViewController+CommonSkyway.swift:420-446`（削除）<br>- `MediaConnectionViewController+CommonSkyway.swift:316-576`（削除） |
| **作業内容** | 1. AudioSessionManager作成<br>　　- AVAudioSession設定の集約<br>　　- ヘッドフォン接続/切断監視<br>　　- スピーカー/レシーバー切り替え<br>2. 既存の分散コードを統合<br>3. 1秒遅延ロジックの改善 |
| **完了条件** | - ヘッドフォン抜き差しで音声が途切れない<br>- スピーカー出力が正常<br>- 電話割り込み後に通話復帰 |
| **想定リスク** | - iOS バージョン間の挙動差<br>- Bluetooth機器での動作不安定<br>- 遅延時間の調整必要 |
| **推定工数** | 2日 |

---

### PR#8: ログ/計測/監視基盤
**目的**: デバッグ性・運用性の向上

| 項目 | 内容 |
|-----|------|
| **新規ファイル** | - `CallMetrics.swift`（計測）<br>- `SkyWayLogger.swift`（ログ） |
| **変更ファイル** | - 全SkyWay関連ファイル（print文をLogger化） |
| **作業内容** | 1. 構造化ログ実装<br>　　- ログレベル（Debug/Info/Warning/Error）<br>　　- ファイル出力対応<br>2. メトリクス収集<br>　　- join成功率<br>　　- subscribe成功率<br>　　- 再接続回数<br>　　- 平均通話時間<br>3. エラーレポート送信 |
| **完了条件** | - `print`文が全てLogger経由<br>- メトリクスがFirebase Analyticsに送信<br>- エラー発生時にスタックトレース取得 |
| **想定リスク** | - ログ量の増加によるパフォーマンス低下<br>- プライバシー情報の誤記録 |
| **推定工数** | 2日 |

---

### PR#9: QA・統合テスト
**目的**: 全体の動作保証

| 項目 | 内容 |
|-----|------|
| **作業内容** | 1. 統合テストシナリオ作成<br>　　- 正常系フローテスト<br>　　- 異常系フローテスト<br>2. 手動QA（デバイス実機）<br>　　- iPhone/iPad各世代<br>　　- iOS 15/16/17<br>3. パフォーマンステスト<br>　　- メモリ使用量<br>　　- CPU使用率<br>　　- 通信量 |
| **完了条件** | - 全テストシナリオ通過<br>- クラッシュ0<br>- メモリリーク0<br>- 既存機能の後退なし |
| **想定リスク** | - デバイス依存の不具合<br>- iOS バージョン依存の問題<br>- ネットワーク環境依存の問題 |
| **推定工数** | 5日 |

---

## 6. 既存の"複雑さ"の原因特定

### 6.1 複雑化の主要因

| 原因 | 詳細 | 該当箇所 | 影響範囲 |
|-----|------|---------|---------|
| **1. Dual-Room構造** | P2P Room（通話用）とSFU Room（待機用）を同時管理<br>→ 状態が2倍、イベントハンドラが2倍 | WaitVC:178-188<br>MediaVC:45-54 | ★★★★★ |
| **2. 責務混在** | SkyWay処理 + Firebase同期 + ポイント計算 + UI更新が全て1ファイルに | WaitVC+Skyway:15-780<br>MediaVC+Skyway:15-1202 | ★★★★★ |
| **3. 重複実装** | ストリーム生成・publish・subscribeが3箇所に重複 | SkywayManager<br>WaitVC+Skyway<br>MediaVC+Skyway | ★★★★☆ |
| **4. グローバル状態** | `appDelegate`経由で状態を共有<br>→ 変更の影響範囲が不明 | 全ViewController | ★★★★☆ |
| **5. フラグ地獄** | `isReconnect`, `listenerStatus`, `listenerErrorFlg`, `roomClosed` 等が散在 | WaitVC+Skyway:17-19<br>MediaVC+Skyway:593 | ★★★★☆ |
| **6. エラーハンドリングの欠如** | `try?`でエラーを無視、リトライロジックなし | 全箇所 | ★★★★☆ |
| **7. 非同期処理の複雑化** | `Task { }`, `DispatchQueue.main.async`, `asyncAfter`が混在 | WaitVC+Skyway:440<br>MediaVC+Skyway:957 | ★★★☆☆ |
| **8. コールバック多重登録** | Firebase監視・AVAudioSession監視が複数箇所で登録 | WaitVC+Skyway:579<br>MediaVC+Skyway:873 | ★★★☆☆ |
| **9. ハードコード** | 遅延時間（1秒、2秒、3秒、5秒）がマジックナンバー | WaitVC:192, 440<br>MediaVC:341, 555 | ★★☆☆☆ |
| **10. コメントアウト大量** | 削除できない過去コードが500行以上残存 | MediaVC:360-577 | ★☆☆☆☆ |

### 6.2 新SDK移行で事故りやすいポイント Top10

| No | ポイント | 詳細 | 該当箇所 | 対策 |
|----|---------|------|---------|------|
| 1 | **Task漏れ** | `roomTask?.cancel()`忘れ<br>→ メモリリーク | WaitVC:124, 179<br>MediaVC:17, 46 | Taskを配列管理し、`deinit`で全キャンセル |
| 2 | **@MainActor不足** | UI更新を非MainActorで実行<br>→ クラッシュ | 多数箇所 | 全UI関連関数に`@MainActor`付与 |
| 3 | **循環参照** | クロージャで`self`を強参照<br>→ メモリリーク | WaitVC:256, 265<br>MediaVC:152, 161 | 全クロージャに`[weak self]` |
| 4 | **Publication/Subscription未解放** | `unsubscribe`/`unpublish`忘れ<br>→ リソースリーク | SkywayManager:277-284 | 必ず`cleanupResources()`呼び出し |
| 5 | **Room.leave()失敗無視** | `try?`でエラーを握りつぶす<br>→ 次回join失敗 | WaitVC:374<br>MediaVC:295 | エラーログ記録 + リトライ |
| 6 | **onPublicationPublishedタイミング** | 自分のPublicationもイベント発火<br>→ 無限ループ | WaitVC:267-269<br>MediaVC:163-165 | publisherIdフィルタリング必須 |
| 7 | **Context重複初期化** | 複数箇所で`setupForDev`呼び出し<br>→ クラッシュ | Util:66-85 | タスクキャッシング（既に実装済み） |
| 8 | **AudioSession競合** | AVAudioSessionを複数箇所で設定<br>→ 音声出力不安定 | WaitVC:420<br>MediaVC:316 | AudioSessionManager統一 |
| 9 | **状態不整合** | `roomClosed=true`後に`joinRoomIfNeeded`呼び出し<br>→ 処理スキップ | WaitVC:149, 201<br>MediaVC:98 | 状態遷移をFSMで管理 |
| 10 | **DataStream文字コード** | `String.Encoding.utf8`決め打ち<br>→ 絵文字で文字化け | WaitVC:685<br>MediaVC:909 | UTF-8検証 + エラー処理 |

---

## 7. テスト観点

### 7.1 手動試験観点（20項目）

#### 基本フロー

| No | 観点 | 手順 | 期待結果 | 優先度 |
|----|-----|------|---------|--------|
| 1 | **初回起動** | アプリ起動 | カメラ・マイク権限ダイアログ表示 | 高 |
| 2 | **キャスター待機** | キャスターが待機ボタン押下 | ローカルビデオプレビュー表示 | 高 |
| 3 | **リスナー接続** | リスナーがキャスター選択 | 3秒以内に通話開始 | 高 |
| 4 | **双方向通話** | 通話中に両者が話す | 音声・映像が双方向で届く | 高 |
| 5 | **チャット送信** | リスナーがメッセージ送信 | キャスター側にリアルタイム表示 | 中 |
| 6 | **正常切断** | キャスターが終了ボタン押下 | 両者とも待機画面に戻る | 高 |

#### 例外フロー

| No | 観点 | 手順 | 期待結果 | 優先度 |
|----|-----|------|---------|--------|
| 7 | **権限拒否** | カメラ権限を拒否して通話開始 | エラーダイアログ表示、設定画面誘導 | 高 |
| 8 | **ネットワーク断** | 通話中にWi-FiをOFF | 再接続試行、5秒後にエラー表示 | 高 |
| 9 | **バックグラウンド** | 通話中にホームボタン押下 | バックグラウンドで通話継続 | 高 |
| 10 | **着信割り込み** | 通話中に電話着信 | 通話一時停止、電話終了後に自動復帰 | 高 |
| 11 | **ヘッドフォン抜き** | 通話中にイヤホン抜く | スピーカーから音声出力継続 | 中 |
| 12 | **ヘッドフォン挿し** | 通話中にイヤホン挿す | イヤホンから音声出力 | 中 |
| 13 | **メモリ警告** | 他アプリを大量起動後に通話 | 通話継続、クラッシュなし | 高 |
| 14 | **低速回線** | 3G回線で通話 | 映像品質低下も通話継続 | 中 |

#### 画面遷移

| No | 観点 | 手順 | 期待結果 | 優先度 |
|----|-----|------|---------|--------|
| 15 | **画面リフレッシュ** | リスナーがリフレッシュ実行 | 3秒以内に再接続、ポイント重複なし | 中 |
| 16 | **画面回転** | 通話中にデバイスを回転 | レイアウト崩れなし | 低 |
| 17 | **複数起動防止** | 通話中に別キャスターを選択 | 現在の通話を終了してから接続 | 中 |

#### ビジネスロジック

| No | 観点 | 手順 | 期待結果 | 優先度 |
|----|-----|------|---------|--------|
| 18 | **ポイント消費** | 1分間通話 | 正確なポイントが減算 | 高 |
| 19 | **スター獲得** | キャスターが1分間配信 | 正確なスターが加算 | 高 |
| 20 | **異常終了返金** | 30秒以内にキャスターが切断 | リスナーのコイン返却なし（仕様） | 中 |

### 7.2 自動テスト観点

#### ユニットテスト

| 対象 | テストケース | 実装方法 |
|-----|------------|---------|
| **SkyWayService** | - Context初期化成功/失敗<br>- Room Join成功/失敗<br>- Publish成功/失敗<br>- Subscribe成功/失敗 | MockRoomを使用 |
| **CallSession** | - 状態遷移の網羅<br>- タイマー動作<br>- エラー伝播 | Protocol化してMock |
| **AudioSessionManager** | - ヘッドフォン検出<br>- スピーカー切り替え | AVAudioSessionのMock |

#### 統合テスト

| シナリオ | 検証項目 |
|---------|---------|
| **正常通話** | Context初期化 → Join → Publish → Subscribe → Leave の全フロー |
| **異常切断** | Subscribe中にリモートメンバーがleave → 適切なエラー処理 |
| **再接続** | ネットワーク断 → 復帰 → 自動再接続 |

### 7.3 ログで確認すべき指標（メトリクス）

| 指標名 | 計算方法 | 目標値 | 記録タイミング |
|-------|---------|--------|--------------|
| **Join成功率** | `成功回数 / 試行回数 × 100%` | 98%以上 | `room.join()`完了時 |
| **Subscribe成功率** | `成功回数 / Publication受信回数 × 100%` | 95%以上 | `localMember.subscribe()`完了時 |
| **再接続回数** | 1セッションあたりの平均回数 | 0.5回以下 | `refreshAction()`呼び出し時 |
| **平均通話時間** | 全通話の平均秒数 | - | `leave()`時 |
| **異常切断率** | `異常切断 / 全切断 × 100%` | 5%以下 | `handleRemoteMediaDisconnected()`時 |
| **オーディオ再起動回数** | `audioSessionRouteChanged`の発火回数 | - | イベント発火時 |
| **メモリ使用量** | 通話中のピークメモリ | 150MB以下 | 1秒ごと |
| **CPU使用率** | 通話中の平均CPU使用率 | 30%以下 | 1秒ごと |
| **ネットワーク送信量** | 1分あたりのMB数 | 2MB以下 | 1分ごと |
| **クラッシュ率** | `クラッシュ / セッション開始回数 × 100%` | 0.1%以下 | アプリ起動時 |

### 7.4 ログ出力フォーマット（推奨）

```swift
// 構造化ログの例
struct SkyWayLog {
    let timestamp: Date
    let level: LogLevel // Debug/Info/Warning/Error
    let category: String // "Context", "Room", "Stream", "Audio"
    let event: String // "join_success", "subscribe_failed"
    let userId: Int?
    let roomName: String?
    let error: String?
    let metadata: [String: Any]?
}

// 使用例
SkyWayLogger.info(
    category: "Room",
    event: "join_success",
    userId: 12345,
    roomName: "user_12345",
    metadata: ["memberCount": 2, "roomType": "P2P"]
)
```

### 7.5 Firebase Analytics送信イベント

| イベント名 | パラメータ | 送信タイミング |
|----------|-----------|--------------|
| `skyway_join_attempt` | `user_id`, `room_name`, `room_type` | `room.join()`呼び出し前 |
| `skyway_join_success` | `user_id`, `room_name`, `duration_ms` | `room.join()`成功後 |
| `skyway_join_failed` | `user_id`, `error_code`, `error_message` | `room.join()`失敗時 |
| `skyway_subscribe_success` | `user_id`, `stream_type` | `subscribe()`成功後 |
| `skyway_subscribe_failed` | `user_id`, `error_code` | `subscribe()`失敗時 |
| `skyway_call_ended` | `user_id`, `duration_sec`, `reason` | `leave()`時 |
| `skyway_reconnect` | `user_id`, `attempt_count` | 再接続試行時 |
| `skyway_error` | `user_id`, `error_type`, `stack_trace` | エラー発生時 |

---

## 8. まとめと推奨アクション

### 8.1 現状の評価

| 項目 | 評価 | コメント |
|-----|------|---------|
| **新SDK移行状況** | ✅ 完了 | SkyWay Room SDK 3.1.1へ移行済み |
| **基本機能** | ✅ 動作 | 1対1通話は正常動作 |
| **コード品質** | ⚠️ 課題あり | 責務混在、重複実装、エラー処理不足 |
| **保守性** | ❌ 低い | 1200行のExtension、複雑な状態管理 |
| **テスト可能性** | ❌ 低い | Protocol化不足、Mockingが困難 |
| **ドキュメント** | ❌ 不足 | コメントが少なく意図不明な箇所多数 |

### 8.2 優先度の高い改善（Quick Wins）

1. **PR#2（SkyWayService抽出）を最優先実施**
   - 効果が最も大きい
   - 以降のPRの土台となる

2. **エラーハンドリングの改善**
   - `try?`を`do-catch`に変更
   - エラーログの記録

3. **コメントアウトコードの削除**
   - 500行以上の削除でコード可読性向上

### 8.3 長期的な改善方向性

1. **Dual-Room構造の再検討**
   - SFU WaitRoomの必要性を検証
   - 別機能として分離可能か検討

2. **Firebase連携の分離**
   - FirebaseServiceとして独立
   - SkyWay処理との疎結合化

3. **ポイント計算ロジックの分離**
   - ビジネスロジック層の新設
   - テスト可能な設計

4. **3人以上通話への拡張**
   - SFU Roomの本格活用
   - Subscribe数の動的管理

---

## 付録A: ファイル別詳細分析

### A.1 SkywayManager.swift

**概要**: シングルトンパターンでSkyWay機能を提供する汎用クラス

**主要メソッド**:
- `sessionStart(delegate:)` - Context初期化
- `connectStart(connectPeerId:delegate:)` - 通話開始
- `closeMedia(localView:remoteView:)` - 通話終了

**問題点**:
- 各ViewControllerが独自実装しており、実質未使用
- Delegate設計が古い（Combine/async-awaitが望ましい）
- 1 Roomのみ管理（Dual-Room非対応）

**推奨対応**: PR#2で新SkyWayServiceへ統合

---

### A.2 WaitViewController+CommonSkyway.swift

**概要**: キャスター側のSkyWay実装（781行）

**複雑性の原因**:
- Dual-Room管理（P2P + SFU）
- Firebase監視（`conditionRef.observe`）
- ポイント計算（`startConnection:15-120`）
- オーディオセッション管理（`addAudioSessionObservers:420-446`）

**主要処理フロー**:
```
setup()
 ├─ joinRoomIfNeeded() [P2P]
 ├─ joinWaitRoomIfNeeded() [SFU]
 ├─ publishLocalStreams()
 └─ attachRoomCallbacks()
      └─ onPublicationPublished → subscribeToPublication()
           └─ handleRemoteMediaConnected()
                └─ startConnection() ← ポイント計算
```

**推奨対応**: PR#3でCallSessionへ移行

---

### A.3 MediaConnectionViewController+CommonSkyway.swift

**概要**: リスナー側のSkyWay実装（1202行）

**複雑性の原因**:
- Dual-Room管理（P2P + SFU）
- Firebase監視（`conditionRef.observe:873`）
- チャット・エフェクト機能
- 異常終了時のキャスター状態確認API（`handleRemoteMediaDisconnected:592-765`）

**巨大な関数**:
- `handleDataConnectionOpen()` - 156行
- `handleRemoteMediaDisconnected()` - 173行
- `effectDo(effect_id:)` - 92行

**推奨対応**: PR#3でCallSessionへ移行 + 機能分割

---

## 付録B: 用語集

| 用語 | 説明 |
|-----|------|
| **SkyWay Room SDK** | NTTコミュニケーションズ提供のWebRTC SDK |
| **P2P Room** | Peer-to-Peer形態のRoom（1対1通話用） |
| **SFU Room** | Selective Forwarding Unit形態（多対多通信用） |
| **Publication** | ストリーム配信の単位 |
| **Subscription** | ストリーム購読の単位 |
| **LocalRoomMember** | 自分自身のRoom内表現 |
| **RemoteRoomMember** | 相手のRoom内表現 |
| **Context** | SkyWay SDKの初期化コンテキスト |
| **MainActor** | SwiftのメインスレッドでのUI更新保証 |

---

**次のアクション**: PR#1（ビルド整理）から着手を推奨します。
