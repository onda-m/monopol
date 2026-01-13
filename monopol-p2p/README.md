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

### 2. 開発用 Secrets.xcconfig の準備（DEBUG限定）

```
cp Secrets.xcconfig.example Secrets.xcconfig
```

`Secrets.xcconfig` に以下を設定してください（DEBUGビルドのみで読み込まれます）。

```
SKYWAY_API_KEY=
SKYWAY_DOMAIN=
SKYWAY_AUTH_TOKEN=
```

### 3. トークン注入（TokenProvider）

- 本番では外部から Token を注入する設計です。
- DEBUG ビルドでは `Secrets.xcconfig` の `SKYWAY_AUTH_TOKEN` を利用します。

例: アプリ起動時に外部 TokenProvider を注入する場合

```swift
Util.skywayTokenProvider = YourTokenProvider()
```
