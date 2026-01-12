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

### 2. SkyWay Context の初期化

`swift/AppDelegate.swift` に SkyWay Room SDK の `Context.setup` 呼び出しとトークン取得のプレースホルダが追加されています。実運用ではバックエンドから発行したトークンを返すように `fetchSkyWayToken()` を置き換えてください。
