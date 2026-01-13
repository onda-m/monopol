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

`pod` コマンドが見つからない場合は、CocoaPods をインストールしてから再実行してください。

```
$ sudo gem install cocoapods
```

### 2. APIKEY, DOMAINの書き換え

```
// AppDelegate.swift
// https://webrtc.ecl.ntt.com/からAPIKeyとDomainを取得してください
var skywayAPIKey:String? = "xxx"
var skywayDomain:String? = "xxx"

```
