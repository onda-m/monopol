//
//  UtilFunc.swift
//  swift_skyway
//
//  Created by onda on 2018/12/05.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import SkyWayRoom
import Foundation
import UIKit
//import Firebase
import PINRemoteImage
import PINCache
import Photos

class UtilFunc {
    //相手との絆レベル取得用
    struct ConnectResult: Codable {
        let level: String//
        let bonus_rate: String//
    }
    struct ResultConnectJson: Codable {
        let count: Int
        let result: [ConnectResult]
    }

    //重要(UserDefaultsに関しては、これを使用するようにしたい)
    //UserDefaultsに保存する処理、取り出す処理
    // 保存する
    //UtilFunc.setUserDefaults(value:"abcd", key:"hoge")
    // 取得する
    //let str = UtilFunc.getUserDefaults(key: "hoge") as! String
    /*
    static func getUserDefaults(key: String) -> Any? {
        let userDefaults = UserDefaults.standard
        let data = userDefaults.object(forKey: key) as? Data
        
        if data != nil {
            return NSKeyedUnarchiver.unarchiveObject(with: data!)
        }
        else {
            return nil
        }
    }
    static func setUserDefaults(value : Any, key: String) -> Void {
        let userDefaults = UserDefaults.standard
        let data : Data = NSKeyedArchiver.archivedData(withRootObject: value)
        
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }
     */
    
    //タイマーの停止(よく使われるため共通化)
    //UtilFunc.stopTimer(timer:)
    static func stopTimer(timer: Timer){
        //もしタイマーが実行中だったら停止
        if(timer.isValid == true){
            //タイマー停止
            timer.invalidate()
        }
    }

    //ユーザーの情報UUIDを変更(SNSログインを利用の登録時のみ使用)
    //GET: user_id, uuid
    static func modifyUuidByUserId(user_id:Int, uuid:String){
        var stringUrl = Util.URL_MODIFY_UUID
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&uuid=")
        stringUrl.append(uuid)
        
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
        }
    }
    
    //ログ履歴の保存
    static func logRirekiDo(type:Int, user_id:Int, view_name:String, value01:String){
        //type 1:課金正常時 2:課金エラー時
        //user_id
        //view_name 発生したVIEW名など
        //value01 エラーメッセージなど

        var stringUrl = Util.URL_LOG_RIREKI_DO
        stringUrl.append("?type=")
        stringUrl.append(String(type))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&view_name=")
        stringUrl.append(view_name)
        stringUrl.append("&value01=")
        stringUrl.append(value01)
        print(stringUrl)

        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{

                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }

    /*
    //プラットフォーム取得（x86_64とか）
    func platform() -> String {
      var size : Int = 0
      sysctlbyname("hw.machine", nil, &size, nil, 0)
      var machine = [CChar](count: Int(size), repeatedValue: 0)
      sysctlbyname("hw.machine", &machine, &size, nil, 0)
      return String.fromCString(machine)!
    }
    */
    
    // WiFiインターフェース（en0）のIPアドレスを文字列として返す、または「nil」
    static func getWiFiAddress() -> String? {
        var address : String?

        // ローカルマシン上のすべてのインターフェースのリストを取得します。
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each インターフェース ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // IPv4またはIPv6インターフェースをチェックします。
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // インターフェース名をチェックします。
                let name = String(cString: interface.ifa_name)
                
                // wifi = ["en0"]
                // wired = ["en2", "en3", "en4"]
                // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                
                if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {

                    // インターフェイスアドレスをIPのアドレスの文字列に変換します。
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
    
    //IPアドレス履歴の保存
    static func logIpRirekiDo(type:Int, user_id:Int){
        //type 1:通常
        //user_id
        /*
        ipaddr
        value01 :UUID
        value02 :デバイス名
        value03 :OS名
        value04 :OSバージョン
        value05 :OSモデル名
        value06 :キャリア情報
        value07 :プラットフォーム情報
        //キャリア情報
        print(CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName)
        print(CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileCountryCode)
        print(CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileNetworkCode)
        print(CTTelephonyNetworkInfo().subscriberCellularProvider?.isoCountryCode)
         */

        var ipString = "0"
        // IPアドレスの取得関数の呼び出し
        if let addr = getWiFiAddress(){
            // Trueの場合
            //print(addr)
            //globalVar.ipString = addr
            ipString = addr
        }
        
        var stringUrl = Util.URL_LOG_IP_RIREKI_DO
        stringUrl.append("?type=")
        stringUrl.append(String(type))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&ipaddr=")
        stringUrl.append(ipString)
        stringUrl.append("&value01=")
        stringUrl.append("0")
        stringUrl.append("&value02=")
        stringUrl.append(UIDevice.current.name)
        stringUrl.append("&value03=")
        stringUrl.append(UIDevice.current.systemName)
        stringUrl.append("&value04=")
        stringUrl.append(UIDevice.current.systemVersion)
        stringUrl.append("&value05=")
        stringUrl.append(UIDevice.current.model)
        stringUrl.append("&value06=")
        stringUrl.append("0")
        stringUrl.append("&value07=")
        stringUrl.append("0")
        //print(stringUrl)

        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{

                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    //メンテ状態のチェック
    static func maintenanceCheck(){
        /***********************************************************/
        //  メンテナンス中かの判断
        /***********************************************************/
        //メンテナンスフラグ 1:メンテ中
        var mainte_flg = 0
        
        //static let URL_GET_PUBCODE = URL_BASE + "getPubcode.php"//メンテナンスかどうかのチェックetc
        var stringUrl = Util.URL_GET_PUBCODE
        stringUrl.append("?code_name=mainte_flg")
        print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultPubcodeJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //ただしゼロ番目のみ参照可能
                    for obj in json.result {
                        //データが取得できなかった場合を考慮
                        if(obj.value01 == "1"){
                            //メンテ中
                            mainte_flg = 1
                        }else{
                            mainte_flg = 0
                        }
                        
                        break
                    }
                    
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(mainte_flg == 1){
                //メンテ中の場合はメンテ画面へ
                UtilToViewController.toMaintenanceViewController()
            }
        }
        /***********************************************************/
        //  メンテナンス中かの判断(ここまで)
        /***********************************************************/
    }
    
    //最新アプリのバージョンを取得
    //古かったらアップストアに遷移する
    static func appVersionCheck(){
        //現在最新のモノポルアプリのバージョン
        var app_version = ""
        var get_count = 0
        
        var stringUrl = Util.URL_GET_PUBCODE
        stringUrl.append("?code_name=app_version_new")
        print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultPubcodeJson.self, from: data!)
                    //件数取得
                    get_count = json.count
                    
                    //ただしゼロ番目のみ参照可能
                    for obj in json.result {
                        app_version = obj.value02
                        //app_version_status = obj.status
                        
                        break
                    }
                    
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //インストール中のバージョンを取得
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            //let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

            /*
            print("バージョン")
            print(version)
            print("最新バージョン")
            print(app_version)
            */
            if(get_count > 0){
                if(version == app_version){
                    //すでにバージョンが新しい、または「チェックをしない」ステータスの場合
                    //何もしない
                    print("------------")
                    print("------version------")
                    print(get_count)
                    print(app_version)
                    print("------------")
                }else{
                    //新しいバージョンをインストールするように促す
                    // ダイアログ(AlertControllerのインスタンス)を生成します
                    let title = "アプリが更新されました。App storeから最新版をダウンロードしてください。"
                    let message = ""
                    let okText = "OK"
                    
                    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                    let okayButton = UIAlertAction(title: okText, style: UIAlertAction.Style.cancel, handler: { action in
                        //guard let url = URL(string: "https:/itunes.apple.com/app/id{Apple ID}?action=write-review") else { return }
                        guard let url = URL(string: "https://itunes.apple.com/app/id" + Util.APPLEID) else { return }
                        UIApplication.shared.open(url)
                        
                        //let itunesURL:String = "itms-apps://itunes.apple.com/app/XXXXX"
                        //let url = NSURL(string:itunesURL)
                        //let app:UIApplication = UIApplication.shared
                        //app.openURL(url!)
                    })
                    alert.addAction(okayButton)
                    
                    // 下記を追加する
                    alert.modalPresentationStyle = .fullScreen
                    
                    // 生成したダイアログを実際に表示します
                    let topController = UIApplication.topViewController()
                    topController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    /***********************************************************/
    // ライブ配信のリクエスト関連
    /***********************************************************/
    //リクエスト履歴に追加
    //GET:user_id, listener_user_id, type, request_status, status
    //static let URL_LIVE_REQUEST_DO: String = URL_BASE + "addLiveRequestDo.php"
    static func liveRequestRirekiDo(type:Int, user_id:Int, listener_user_id: Int, request_status: Int, status: Int){
        var stringUrl = Util.URL_LIVE_REQUEST_DO
        stringUrl.append("?type=")
        stringUrl.append(String(type))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&listener_user_id=")
        stringUrl.append(String(listener_user_id))
        stringUrl.append("&request_status=")
        stringUrl.append(String(request_status))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
        }
    }

    //リクエスト履歴の未読＞既読へ
    //GET:user_id, status
    //status 0:削除以外全て 1:既読 2:削除 3:未読
    static func modifyliveRequestRireki(user_id:Int, status: Int){
        var stringUrl = Util.URL_MODIFY_LIVE_REQUEST
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
            if(status == 1){
                //既読を指定した場合のみ、すべて既読になり未読数ゼロをセットする
                //未読数をゼロにする
                UserDefaults.standard.set(0, forKey: "requestRirekiNoreadCount")
            }
        }
    }
    
    //リクエスト状態の更新（リクエスト後に配信までしたのかなどの状態>最新の一件のみ更新）
    //GET:user_id, listener_user_id, request_status
    //request_status 1:リクエスト後配信 2:リクエスト後キャストが拒否 3:リクエストしてそのまま
    static func modifyLiveRequestStatusByOne(user_id:Int, listener_user_id:Int, request_status: Int){
        var stringUrl = Util.URL_MODIFY_LIVE_REQUEST_STATUS_ONE
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&listener_user_id=")
        stringUrl.append(String(listener_user_id))
        stringUrl.append("&request_status=")
        stringUrl.append(String(request_status))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
        }
    }
    
    //リクエスト未読数取得
    static func getLiveRequestNoreadCount(type:Int, user_id:Int){
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        //type=1:リスナーによる配信リクエスト
        var stringUrl = Util.URL_GET_LIVE_REQUEST_NOREAD_COUNT
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&type=")
        stringUrl.append(String(type))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultLiveRequestNoreadJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        //let strListenerUserId = obj.noread_count
                        //
                        UserDefaults.standard.set(obj.request_noread_count, forKey: "requestRirekiNoreadCount")
                    }
                    
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            
        }
    }
    /***********************************************************/
    // ライブ配信のリクエスト関連(ここまで)
    /***********************************************************/
    
    //プッシュ通知(type:1=視聴リクエスト)
    //GET:type,from_user_id,to_user_id,token(firebaseのトークン)
    //type 1:視聴リクエスト
    static func liveRequestDo(type:Int, from_user_id:Int, to_user_id: Int, token: String){
        var stringUrl = Util.URL_REQUEST_LIVE_NOTIFY
        stringUrl.append("?type=")
        stringUrl.append(String(type))
        stringUrl.append("&from_user_id=")
        stringUrl.append(String(from_user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(String(to_user_id))
        stringUrl.append("&token=")
        stringUrl.append(token)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
        }
    }

    //プッシュ通知(type:1=ストリーマー待機完了)
    //GET:type,from_user_id,to_user_id,token(firebaseのトークン)
    //type 1:視聴リクエスト
    static func castWaitNotifyDo(type:Int, from_user_id:Int, to_user_id: Int, token: String){
        var stringUrl = Util.URL_CAST_WAIT_NOTIFY
        stringUrl.append("?type=")
        stringUrl.append(String(type))
        stringUrl.append("&from_user_id=")
        stringUrl.append(String(from_user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(String(to_user_id))
        stringUrl.append("&token=")
        stringUrl.append(token)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
        }
    }
    
    //キャスト状態を変更
    //GET: user_id,status,live_user_id,reserve_flg,password
    //var reserve_flg: Int = 0//0:予約可能 1:予約を許可しない
    static func liveModifyStatusDo(user_id:Int, status:Int, live_user_id: Int, reserve_flg: Int, max_reserve_count: Int, password: String){
        var stringUrl = Util.URL_MODIFY_STATUS_INFO
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        stringUrl.append("&live_user_id=")
        stringUrl.append(String(live_user_id))
        stringUrl.append("&reserve_flg=")
        stringUrl.append(String(reserve_flg))
        stringUrl.append("&max_reserve_count=")
        stringUrl.append(String(max_reserve_count))
        stringUrl.append("&password=")
        stringUrl.append(password)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
        }
    }

    //キャスト状態を変更(タイムアウト対策)
    //GET: user_id,status,live_user_id,reserve_flg,password
    //更新対象のlive_user_id
    static func liveModifyStatusDoForTimeout(user_id:Int, status:Int, target_live_user_id: Int, live_user_id: Int){
        var stringUrl = Util.URL_MODIFY_STATUS_INFO_FOR_TIMEOUT
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        stringUrl.append("&target_live_user_id=")
        stringUrl.append(String(target_live_user_id))
        stringUrl.append("&live_user_id=")
        stringUrl.append(String(live_user_id))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
        }
    }

    //peerIdの接続リストの取得
    static func loadConnectedPeerIds(peer:SKWPeer, handler:@escaping (_ peerIds:[String]?)->Void){
        peer.listAllPeers({ (peers) -> Void in
            if let connectedPeerIds = peers as? [String]{
                let res = connectedPeerIds.filter({ (connectedPeerId) -> Bool in
                    return connectedPeerId != "0"
                })
                handler(res)
            }else{
                handler(nil)
            }
        })
    }
    
    //使用方法
    // Util.isPeerIdExist(peer: SKWPeer, peerId: String) { (flg) in ...
    //接続リストに自分のpeerIdが存在するかを判断
    static func isPeerIdExist(peer: SKWPeer, peerId: String, handler:@escaping (_ flg:Bool?)->Void){
        self.loadConnectedPeerIds(peer: peer) { (peerIds) in
            if(peerId == "0"){
                handler(false)
            }else{
                if let _peerIds = peerIds, _peerIds.count > 0{
                    if _peerIds.firstIndex(of: peerId) != nil {
                        //接続リストに自分のpeerIdがあった場合
                        handler(true)
                    }else{
                        handler(false)
                    }
                }else{
                    handler(false)
                    //UIAlertController.oneButton("確認", message: "接続中の他のPeerIdはありません", handler: nil)
                }
            }
        }
        //UtilLog.printf(str:"flg = " + String(flg))
        //return flg
    }
    
    /***********************************************************/
    //new予約システム関連
    //１連の配信が終わったら（または配信をスタートするタイミングで）、キャストIDに紐づくデータをdeleteする
    //ユーザー側では5秒おきにチェックタイムスタンプを現時刻に更新する。
    //キャスト側では、５秒おきに、前後のズレが１０秒以上のデータをstatus=2とする。
    /***********************************************************/
    //キャストをロックする
    //GET:user_id,type(1:待機状態への遷移ロック)
    static func addCastLock(cast_id:Int, user_id:Int, type:Int){
        var stringUrl = Util.URL_ADD_CAST_LOCK
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&type=")
        stringUrl.append(String(type))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }

    //キャストロック情報の削除(キャスト側で使用する)
    //GET:user_id,type(1:待機状態への遷移ロック)
    static func deleteCastLock(cast_id:Int, user_id:Int, type:Int){
        var stringUrl = Util.URL_DELETE_CAST_LOCK
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&type=")
        stringUrl.append(String(type))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }

    /*
    //予約情報の取得＞アプリ内の変数に格納
    //GET: cast_id, user_id
    //user_id = 0の場合は、予約最後の人を返す
    //status=0の場合は、status=1,3の両データを取得している
    static func getReserveInfoNew(cast_id:Int, user_id:Int, status:Int){
        var stringUrl = Util.URL_GET_RESERVE_INFO_NEW
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultReserveInfoJson.self, from: data!)
                    //self.idCount = json.count
                    //ただしゼロ番目のみ参照可能
                    if(json.count > 0){
                        for obj in json.result {
                            //待ち人数・待ち時間
                            //UserDefaults.standard.set(int, forKey: "reserve_wait_id")この値がゼロの時は予約はまだしていない
                            //UserDefaults.standard.set(int, forKey: "reserve_count")
                            //UserDefaults.standard.set(int, forKey: "reserve_sec")
                            
                            //データが取得できなかった場合を考慮
                            if(obj.id == "" || obj.id == "0"){
                                UserDefaults.standard.set("0", forKey: "reserve_wait_id")
                            }else{
                                UserDefaults.standard.set(obj.id, forKey: "reserve_wait_id")
                            }
                            
                            if(obj.wait_count == "" || obj.wait_count == "0"){
                                UserDefaults.standard.set("0", forKey: "reserve_count")
                            }else{
                                UserDefaults.standard.set(obj.wait_count, forKey: "reserve_count")
                            }
                            
                            if(obj.wait_sec == "" || obj.wait_sec == "0"){
                                UserDefaults.standard.set("0", forKey: "reserve_sec")
                            }else{
                                UserDefaults.standard.set(obj.wait_sec, forKey: "reserve_sec")
                            }
                            
                            break
                        }
                        //print(json.result)
                    }else{
                        //データがなかった場合
                        UserDefaults.standard.set("0", forKey: "reserve_wait_id")
                        UserDefaults.standard.set("0", forKey: "reserve_count")
                        UserDefaults.standard.set("0", forKey: "reserve_sec")
                    }
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
   */

    /*
    //配信情報の更新（ライブ時間を更新。予約情報などはゼロに更新）
    //キャスト側で使用する(ユーザー側では予約から配信の切り替え時のみに使用する)
    //GET: cast_id, user_id, live_sec
    static func modifyReserveInfoLiveSec(cast_id:Int, user_id:Int, live_sec:Int, status:Int){
        var stringUrl = Util.URL_MODIFY_RESERVE_INFO_LIVE_SEC
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&live_sec=")
        stringUrl.append(String(live_sec))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }
    */
    
    /*
    //配信情報の更新（チェック用のタイムスタンプ、待ち人数、待ち時間などの更新）
    //GET: cast_id, user_id, reserve_info_id
    static func modifyReserveInfo(cast_id:Int, user_id:Int, reserve_info_id:Int){
        var stringUrl = Util.URL_MODIFY_RESERVE_INFO
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&reserve_info_id=")
        stringUrl.append(String(reserve_info_id))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }
     */
    
    /*
    //配信の予約
    //GET: cast_id, user_id, user_peer_id, wait_count, wait_sec, live_sec, status
    //return:id_temp
    static func reserveDoNew(cast_id:Int, user_id:Int, user_peer_id:String, wait_count:Int, wait_sec:Int, live_sec:Int, status:Int){
        var stringUrl = Util.URL_RESERVE_DO_NEW
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&user_peer_id=")
        stringUrl.append(user_peer_id)
        stringUrl.append("&wait_count=")
        stringUrl.append(String(wait_count))
        stringUrl.append("&wait_sec=")
        stringUrl.append(String(wait_sec))
        stringUrl.append("&live_sec=")
        stringUrl.append(String(live_sec))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }
    */
    
    /*
    //（有効な）予約のリストを取得(予約しているユーザーのID,PEER_IDなどを取得)
    //GET: cast_id, sec, status, order(1がasc)
    static func getReserveInfoByCastId(cast_id:Int, sec:Int, status:Int, order:Int){
        var stringUrl = Util.URL_RESERVE_INFO_BY_CAST
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&sec=")
        stringUrl.append(String(sec))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        stringUrl.append("&order=")
        stringUrl.append(String(order))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultConnectJson.self, from: data!)
                    //self.idCount = json.count
                    //ただしゼロ番目のみ参照可能
                    for obj in json.result {

                        break
                    }
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    */
    
    /*
    //予約リストのクリア(キャストIDを軸)
    //GET:cast_id, status
    static func reserveListClearByCastId(cast_id:Int, status:Int){
        var stringUrl = Util.URL_RESERVE_LIST_CLEAR_CAST
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }
    */
    
    /*
    //予約リストのクリア(ユーザーIDを軸)
    //GET:user_id, status
    static func reserveListClearByUserId(user_id:Int, status:Int){
        var stringUrl = Util.URL_RESERVE_LIST_CLEAR_USER
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }
    */
    
    /*
    //予約リストのクリア(キャストIDを軸)
    //GET:cast_id, sec, wait_sec
    static func reserveListClearByCastIdSec(cast_id:Int, sec:Int, wait_sec:Int){
        var stringUrl = Util.URL_RESERVE_LIST_CLEAR_CAST_SEC
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&sec=")
        stringUrl.append(String(sec))
        stringUrl.append("&wait_sec=")
        stringUrl.append(String(wait_sec))
        print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }
 */

    /*
    //配信情報の更新（ステータスを更新）
    //GET: cast_id, user_id, status
    static func modifyReserveInfoStatus(cast_id:Int, user_id:Int, status:Int){
        var stringUrl = Util.URL_MODIFY_RESERVE_INFO_STATUS
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }*/
    
    /*
    //配信情報の更新（特定のストリーマーの配信に関して、現在のライブ時間を更新する）
    //GET: cast_id, sec(更新後の秒数)
    static func countdownCommonDo(cast_id:Int, sec:Int){
        var stringUrl = Util.URL_COUNTDOWN_COMMON_DO
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&sec=")
        stringUrl.append(String(sec))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }
    */
    
    /*
    //配信情報の更新（status=1のものを全部、wait_secを前倒しする機能）
    //（ストリーマーが配信リクエストをキャンセルした場合に必要）
    //GET: cast_id, count, sec
    static func modifyReserveWaitSecDecrease(cast_id:Int, count:Int, sec:Int){
        var stringUrl = Util.URL_RESERVE_WAIT_SEC_DECREASE
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&count=")
        stringUrl.append(String(count))
        stringUrl.append("&sec=")
        stringUrl.append(String(sec))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }*/
    
    /*
    //現在の予約・配信数のトータル更新
    //GET: cast_id, flg=1:追加（プラス１） 2:削除(マイナス１) 3:クリア（ゼロにする）
    static func modifyReserveTotalCount(cast_id:Int, flg:Int){
        var stringUrl = Util.URL_MODIFY_RESERVE_TOTAL_COUNT
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.setMyInfo()
        }
    }
     */

    /***********************************************************/
    //new予約システム関連(ここまで)
    /***********************************************************/
    
    //数秒後に勝手に閉じる
    //使い方
    //UtilFunc.showAlert(message:"", vc:self.parentViewController()!)
    //UtilFunc.showAlert(message:"", vc:self)
    static func showAlert(message:String, vc:UIViewController, sec:Double) {
        // アラート作成
        //let messageFont = [kCTFontAttributeName: UIFont(name: "Avenir-Roman", size: 9.0)!]
        let messageFont = [kCTFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
        
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont as [NSAttributedString.Key : Any])
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        //let alert = UIAlertController(title: nil, preferredStyle: .alert)
        
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        // 下記を追加する
        alert.modalPresentationStyle = .fullScreen
        
        // アラート表示
        vc.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + sec, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    //相手ユーザーとの絆レベルの取得
    static func getConnectInfo(my_user_id:Int, target_user_id:Int){
        //モデル詳細取得
        var stringUrl = Util.URL_GET_CONNECT_LEVEL_BY_USERID
        stringUrl.append("?user_id=")
        stringUrl.append(String(target_user_id))
        stringUrl.append("&my_user_id=")
        stringUrl.append(String(my_user_id))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultConnectJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //相手との情報(ライブ中もトークでも共通)
                    //値渡しするため（選択した人との絆レベル）
                    //UserDefaults.standard.set(String, forKey: "sendConnectLevel")
                    //値渡しするため（選択した人との課金ポイントのボーナス率）
                    //UserDefaults.standard.set(String, forKey: "sendConnectBonusRate")
                    //ただしゼロ番目のみ参照可能
                    for obj in json.result {
                        
                        //データが取得できなかった場合を考慮
                        if(obj.level == "" || obj.level == "0"){
                            UserDefaults.standard.set("1", forKey: "sendConnectLevel")
                        }else{
                            UserDefaults.standard.set(obj.level, forKey: "sendConnectLevel")
                        }

                        if(obj.bonus_rate == "" || obj.bonus_rate == "0"){
                            UserDefaults.standard.set("1.0", forKey: "sendConnectBonusRate")
                        }else{
                            UserDefaults.standard.set(obj.bonus_rate, forKey: "sendConnectBonusRate")
                        }
                        
                        break
                    }
                    
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {

        }
    }
    
    static func tabBarDo(selected_menu_num: Int, item: UITabBarItem, myController:UIViewController) {
        switch item.tag{
        case 1:
            if(selected_menu_num != 1){
                //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
                UserDefaults.standard.set(1, forKey: "selectedMenuNum")
                //ホーム画面へ
                UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
                UtilToViewController.toMainViewController()
            }
        case 2:
            if(selected_menu_num != 2){
                //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
                UserDefaults.standard.set(2, forKey: "selectedMenuNum")
                //タイムライン画面へ
                UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
                UtilToViewController.toTimelineViewController()
            }
        case 3:
            //ライブ待ち画面へ(ダイアログを重ねる)
            UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
            let waitDialog:WaitTopDialog = UINib(nibName: "WaitTopDialog", bundle: nil).instantiate(withOwner: myController,options: nil)[0] as! WaitTopDialog
            
            waitDialog.waitTopDialogSetting()
            
            //画面サイズに合わせる(selfでなく、superviewにすることが重要)
            waitDialog.frame = myController.view.frame
            // 貼り付ける
            myController.view.addSubview(waitDialog)
        case 4:
            if(selected_menu_num != 4){
                //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
                UserDefaults.standard.set(4, forKey: "selectedMenuNum")
                //トーク画面へ
                UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
                UtilToViewController.toTalkTopViewController()
            }
        case 5:
            if(selected_menu_num != 5){
                //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
                UserDefaults.standard.set(5, forKey: "selectedMenuNum")
                //マイページへ
                UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
                UtilToViewController.toMypageViewController()
            }
        default : return
            
        }
    }
    /*
     static var userInfo: [(user_id:String, uuid:String, user_name:String, value01:String, value02:String
     , value03:String, point:String, live_point:String, cast_rank:String
     , cast_official_flg:String, cast_month_ranking:String, cast_month_ranking_point:String
     , twitter:String, facebook:String, instagram:String, homepage:String
     , freetext:String, notice_text:String, notice_photo_path:String, login_status:String, login_time:String)] = []

    //ユーザーに通知を送る(Firebaseを使用)
    //https://qiita.com/Simmon/items/55da38514a4fe7bdb5d2
    static func notifyToUser(user_id: Int, title:String, message: String) {
        //user_idから必要な情報を取得
        let serverKey: String = Util.serverKey
        // プッシュ通知を送るユーザーのトークン
        var strFcmToken: String = ""
        //var strPhotoFlg: String = ""
        
        //自分のIDを取得
        let my_user_id = UserDefaults.standard.integer(forKey: "user_id")
        var stringUrl = Util.URL_USER_INFO
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&my_user_id=")
        stringUrl.append(String(my_user_id))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                    for obj in json.result {
                        //self.strUserId = obj.user_id
                        strFcmToken = obj.fcm_token
                        //self.strUuid = obj.uuid
                        //self.strUserName = obj.user_name
                        //strPhotoFlg = obj.photo_flg
                        //self.strValue01 = obj.value01
                        //self.strValue02 = obj.value02
                        //self.strValue03 = obj.value03
                        //strValue04 = obj.value04
                        //strValue05 = obj.value05
                        //self.strPoint = obj.point
                        //self.strLivePoint = obj.live_point
                        //self.strWatchLevel = obj.watch_level
                        //self.strLiveLevel = obj.live_level
                        //self.strCastRank = obj.cast_rank
                        //self.strCastOfficialFlg = obj.cast_official_flg
                        //self.strCastMonthRanking = obj.cast_month_ranking
                        //self.strCastMonthRankingPoint = obj.cast_month_ranking_point
                        //self.strTwitter = obj.twitter
                        //self.strFacebook = obj.facebook
                        //self.strInstagram = obj.instagram
                        //self.strHomepage = obj.homepage
                        //self.strFreetext = obj.freetext
                        //self.strNoticeText = obj.notice_text
                        //self.strLiveTotalCount = obj.live_total_count
                        //strNoticePhotoPath = obj.notice_photo_path
                        //strLoginStatus = obj.login_status
                        //strLoginTime = obj.login_time
                        //strInsTime = obj.ins_time
                        //self.strConnectLevel = obj.connect_level//絆レベル
                        //self.strConnectLiveCount = obj.connect_live_count//視聴回数
                        //self.strConnectPresentPoint = obj.connect_present_point//プレゼントしたポイント
                        //self.strBlackListId = obj.black_list_id
                        break
                    }
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        // badge アプリアイコンの右上の数字
        dispatchGroup.notify(queue: .main) {
            if(strFcmToken != "0" && strFcmToken != ""){
                let post: [String: Any] = ["to": strFcmToken,
                                           "priority": "high", // highにするとアプリが非起動時・バックグラウンドでも通知が来る
                    "notification": [
                        "badge": 0,
                        "body": message,
                        "title": title]
                ]
                
                var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
                request.httpMethod = "POST"
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: post, options: JSONSerialization.WritingOptions())
                    //print("Succeeded serialization.: \(post)")
                } catch {
                    //print("Failed serialization.: \(error)")
                }
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    if let realResponse = response as? HTTPURLResponse {
                        if realResponse.statusCode == 200 {
                            //print("Succeeded post!")
                        } else {
                            //print("Failed post: \(realResponse.statusCode)")
                        }
                    }
                    
                    if let postString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String? {
                        print("POST: \(postString)")
                    }
                }
                task.resume()
            }
        }
    }
     */
    
    //textViewのスクロール位置を最下部にする
    static func scrollToBottom(textView: UITextView) {
        textView.selectedRange = NSRange(location: textView.text.count, length: 0)
        textView.isScrollEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 1.0秒後に実行したい処理
            let scrollY = textView.contentSize.height - textView.bounds.height

            let scrollPoint = CGPoint(x: 0, y: scrollY > 0 ? scrollY : 0)
            textView.setContentOffset(scrollPoint, animated: false)
        }
        //下記を実行しないと、最下部にスクロールしていないことがたまにある(原因不明)
        //let scrollY2 = textView.contentSize.height - textView.bounds.height
        //let scrollPoint2 = CGPoint(x: 0, y: scrollY2 > 0 ? scrollY2 : 0)
        //textView.setContentOffset(scrollPoint2, animated: false)
    }
    
    //アイコン付きテキスト（NSMutableAttributedString）を返す
    //呼び出し方法
    //let iconSize: CGFloat = 13.0
    //let starIcon = FAKFontAwesome.starIcon(withSize: iconSize)
    //starIcon?.addAttribute(NSForegroundColorAttributeName, value: UIColor.red)
    //let starIconImage = (starIcon?.image(with: CGSize(width: iconSize, height: iconSize)))! as UIImage
    //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
    //label.attributedText = Utils.getInsertIconString(string: "10,000", iconImage: starIconImage, iconSize: iconSize)
    //lineHeight: 1.0だと１行を1行分として表示。1.5だと１行を1.5行分として表示。
    static func getInsertIconString(string: String, iconImage: UIImage, iconSize: CGFloat, lineHeight: CGFloat) -> NSMutableAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center//中央寄せ
        paragraphStyle.lineHeightMultiple = lineHeight//1.5あたりが適切？
        //paragraphStyle.minimumLineHeight = ceil(self.infoLbl.lineHeight)//行の高さの最小値
        //paragraphStyle.maximumLineHeight = ceil(self.infoLbl.lineHeight)//行の高さの最大値
        //paragraphStyle.lineSpacing = ceil(self.infoLbl.font.pointSize/2)// 行と行の間隔
        
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            ]
        
        let muAttString = NSMutableAttributedString.init(string: string, attributes: attributes as [NSAttributedString.Key : Any])
        
        //アイコン画像を先頭につけたテキストにします
        let txtAtt = NSTextAttachment.init()
        txtAtt.image = iconImage
        txtAtt.bounds = CGRect(x: 0, y: -2, width: iconSize, height: iconSize)
        let attAttString = NSAttributedString.init(attachment: txtAtt)
        muAttString.insert(attAttString, at: 0)
        
        //アイコン画像の左に余白をつけたテキストにします
        let txtAttEmpty = NSTextAttachment.init()
        let paddingWidth = iconSize * 0.2
        txtAttEmpty.image = self.getImageWithColor(color: UIColor.clear, size: CGSize(width: paddingWidth, height: iconSize))
        txtAttEmpty.bounds = CGRect(x: 0, y: -1, width: paddingWidth, height: iconSize)
        let attAttStringEmpty = NSAttributedString.init(attachment: txtAttEmpty)
        muAttString.insert(attAttStringEmpty, at: 1)
        
        return muAttString
    }
    
    //タイトル用
    static func getInsertIconStringTitle(y_height: Int, string: String, iconImage: UIImage, iconSize: CGFloat) -> NSMutableAttributedString {
        let muAttString = NSMutableAttributedString.init(string: string)
        
        //アイコン画像を先頭につけたテキストにします
        let txtAtt = NSTextAttachment.init()
        txtAtt.image = iconImage
        txtAtt.bounds = CGRect(x: 0, y: CGFloat(y_height), width: iconSize, height: iconSize)
        let attAttString = NSAttributedString.init(attachment: txtAtt)
        muAttString.insert(attAttString, at: 0)
        
        //アイコン画像の左に余白をつけたテキストにします
        let txtAttEmpty = NSTextAttachment.init()
        let paddingWidth = iconSize * 0.2
        txtAttEmpty.image = self.getImageWithColor(color: UIColor.clear, size: CGSize(width: paddingWidth, height: iconSize))
        txtAttEmpty.bounds = CGRect(x: 0, y: -1, width: paddingWidth, height: iconSize)
        let attAttStringEmpty = NSAttributedString.init(attachment: txtAttEmpty)
        muAttString.insert(attAttStringEmpty, at: 1)
        
        return muAttString
    }
    
    //空きの塗りつぶし画像を返す
    static func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    //本日の日付
    //print(getToday()) // 2016/11/28 14:41:07
    //print(getToday(format:"yyyy-MM-dd")) // 2016-11-28
    static func getToday(format:String = "yyyy/MM/dd HH:mm:ss") -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")//重要
        formatter.dateFormat = format
        return formatter.string(from: now as Date)
    }
    
    //ランダムの文字列を返す
    static func randomString(length: Int) -> String {
        let alphabet:String = "abcdefghijklmnopqrstuvwxyz"
        let upperBound = UInt32(alphabet.count)
        return String((0..<length).map { _ -> Character in
            let from = alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))
            return Character(String(alphabet[from...from]))
        })
    }
    
    //現在時刻を取得する
    //タイムスタンプ取得
    static func getNowClockString(flg: Int) -> String {
        if(flg == 1){
            //画像ファイルの拡張子用(キャッシュ画像を表示させないため)
            let formatter = DateFormatter()
            //formatter.setLocalizedDateFormatFromTemplate("yyyyMMddHHmmss")
            formatter.locale = Locale(identifier: "en_US_POSIX")//重要
            formatter.dateFormat = "yyyyMMddHHmmss"
            let now = Date()
            return formatter.string(from: now)
        }else{
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")//重要
            formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
            //formatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd' 'HH:mm:ss")
            let now = Date()
            return formatter.string(from: now)
        }
    }
    
    //数字を3桁区切り
    static func numFormatter(num:Int)->String{
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3//3桁に区切る
        //formatter.maximumFractionDigits = 2
        //formatter.positiveFormat = "0.00"
        //formatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp // 四捨五入
        // Swift 3.0
        // print(formatter.string(from: value as NSNumber))
        // Swift 4.0
        return formatter.string(from: num as NSNumber)!
    }
    
    /*
    // アルバム(Photo liblary)の閲覧権限の確認をするメソッド
    static func checkPermission(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("auth")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            //print("not Determined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        }
    }
    */
    
    // アルバム(Photo liblary)の閲覧権限の確認をするメソッド
    //PhotoLibraryManagerを使うこと
    /*
    static func checkPermissionAlbumn(){
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == PHAuthorizationStatus.authorized {
            // アクセス許可あり
        } else if status == PHAuthorizationStatus.restricted {
            // ユーザー自身にカメラへのアクセスが許可されていない
            // 利用制限（設定 -> 一般 -> 機能制限 で利用が制限されている）
            
        } else if status == PHAuthorizationStatus.notDetermined {
            // まだアクセス許可を聞いていない
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
        } else if status == PHAuthorizationStatus.denied {
            // アクセス許可されていない
            // 明示的拒否（設定 -> プライバシー で利用が制限されている）
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {(granted: Bool) in})
        }
    }
     */

    /*
    // カメラの閲覧権限の確認をするメソッド
    static func checkPermissionCamera(){
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if status == AVAuthorizationStatus.authorized {
            // アクセス許可あり
        } else if status == AVAuthorizationStatus.restricted {
            // ユーザー自身にカメラへのアクセスが許可されていない
            // 利用制限（設定 -> 一般 -> 機能制限 で利用が制限されている）
        } else if status == AVAuthorizationStatus.notDetermined {
            // まだアクセス許可を聞いていない
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {(granted: Bool) in})
        } else if status == AVAuthorizationStatus.denied {
            // アクセス許可されていない
            // 明示的拒否（設定 -> プライバシー で利用が制限されている）
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {(granted: Bool) in})
        }
    }*/

    //カメラ、マイクの閲覧権限の確認をするメソッド
    static func checkPermission(){
        
        //カメラのアクセス権限
        let statusCamera = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if statusCamera == AVAuthorizationStatus.authorized {
            // アクセス許可あり
            
            //マイクのアクセス権限
            //let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
            
            if status == AVAuthorizationStatus.authorized {
                // アクセス許可あり
            } else if status == AVAuthorizationStatus.notDetermined {
                // まだアクセス許可を聞いていない
                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (authentication) in
                    DispatchQueue.main.async {
                        //アプリの設定画面へ
                        if(authentication == false){
                            //マイクの認証がNGの場合＞設定画面へ
                            let url = URL(string: "app-settings:root=General&path=jp.monopol.p2p")
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        }
                    }
                })
            }else{
                //アクセス許可していない
                //通常のダイアログを表示
                
                // ダイアログ(AlertControllerのインスタンス)を生成します
                //   titleには、ダイアログの表題として表示される文字列を指定します
                //   messageには、ダイアログの説明として表示される文字列を指定します
                let dialog = UIAlertController(title: "配信準備に失敗しました", message: "カメラとマイクを許可してください", preferredStyle: .alert)
                // 選択肢(ボタン)を2つ(OKとCancel)追加します
                // titleには、選択肢として表示される文字列を指定します
                //styleには「.default」、キャンセルなど操作を無効に「.cancel」、削除など注意して選択「.destructive」を指定
                //dialog.addAction(UIAlertAction(title: "はい", style: .default, handler: nil))
                dialog.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
                dialog.addAction(UIAlertAction(title: "はい", style: .default,
                                               handler: { action in
                                                //マイクの認証がNGの場合＞設定画面へ
                                                let url = URL(string: "app-settings:root=General&path=jp.monopol.p2p")
                                                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }))
                
                // 下記を追加する
                dialog.modalPresentationStyle = .fullScreen
                
                // 生成したダイアログを実際に表示します
                let topController = UIApplication.topViewController()
                topController?.present(dialog, animated: true, completion: nil)
            }
        } else if statusCamera == AVAuthorizationStatus.notDetermined {
            // まだアクセス許可を聞いていない
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (authentication) in
                DispatchQueue.main.async {
                    //アプリの設定画面へ
                    if(authentication == false){
                        //マイクの認証がNGの場合＞設定画面へ
                        let url = URL(string: "app-settings:root=General&path=jp.monopol.p2p")
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    }
                }
            })
        }else{
            //アクセス許可していない
            //通常のダイアログを表示
            
            // ダイアログ(AlertControllerのインスタンス)を生成します
            //   titleには、ダイアログの表題として表示される文字列を指定します
            //   messageには、ダイアログの説明として表示される文字列を指定します
            let dialog = UIAlertController(title: "配信準備に失敗しました", message: "カメラとマイクを許可してください", preferredStyle: .alert)
            // 選択肢(ボタン)を2つ(OKとCancel)追加します
            // titleには、選択肢として表示される文字列を指定します
            //styleには「.default」、キャンセルなど操作を無効に「.cancel」、削除など注意して選択「.destructive」を指定
            //dialog.addAction(UIAlertAction(title: "はい", style: .default, handler: nil))
            dialog.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
            dialog.addAction(UIAlertAction(title: "はい", style: .default,
                                           handler: { action in
                                            //マイクの認証がNGの場合＞設定画面へ
                                            let url = URL(string: "app-settings:root=General&path=jp.monopol.p2p")
                                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }))
            
            // 下記を追加する
            dialog.modalPresentationStyle = .fullScreen
            
            // 生成したダイアログを実際に表示します
            let topController = UIApplication.topViewController()
            topController?.present(dialog, animated: true, completion: nil)
        }
    }
    
    //マイクのみアクセス権限確認
    static func checkPermissionAudio(){
        //マイクのアクセス権限
        //let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)

        if status == AVAuthorizationStatus.authorized {
            // アクセス許可あり
        } else if status == AVAuthorizationStatus.notDetermined {
            print("まだアクセス許可を聞いていない")
            // まだアクセス許可を聞いていない
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (authentication) in
                DispatchQueue.main.async {
                    //アプリの設定画面へ
                    //if(authentication == false){
                        //マイクの認証がNGの場合＞設定画面へ
                    //    let url = URL(string: "app-settings:root=General&path=jp.monopol.p2p")
                    //    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    //}
                }
            })
        }else{
            //アクセス許可していない

            //通常のダイアログを表示
            /*
            // ダイアログ(AlertControllerのインスタンス)を生成します
            //   titleには、ダイアログの表題として表示される文字列を指定します
            //   messageには、ダイアログの説明として表示される文字列を指定します
            let dialog = UIAlertController(title: "配信準備に失敗しました", message: "マイクを許可してください", preferredStyle: .alert)
            // 選択肢(ボタン)を2つ(OKとCancel)追加します
            // titleには、選択肢として表示される文字列を指定します
            //styleには「.default」、キャンセルなど操作を無効に「.cancel」、削除など注意して選択「.destructive」を指定
            //dialog.addAction(UIAlertAction(title: "はい", style: .default, handler: nil))
            dialog.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
            dialog.addAction(UIAlertAction(title: "はい", style: .default,
                                           handler: { action in
                                            //マイクの認証がNGの場合＞設定画面へ
                                            let url = URL(string: "app-settings:root=General&path=jp.monopol.p2p")
                                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }))
            
            // 下記を追加する
            dialog.modalPresentationStyle = .fullScreen
             
            // 生成したダイアログを実際に表示します
            let topController = UIApplication.topViewController()
            topController?.present(dialog, animated: true, completion: nil)
             */
        }
    }
    
    //透明なImageViewを作成
    //タブバーの背景を透明にする時に使用する
    static func toumeiImage(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // 背景を透明で塗りつぶす
        context.setFillColor(UIColor.clear.cgColor)
        let rect = CGRect(origin: .zero, size: size)
        context.fill(rect)
        
        // 画像に変換する
        let toumeiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = toumeiImage else {
            return nil
        }
        
        return image
    }
    
    //配信レベル・経験値の更新 user_infoテーブル(更新後に何も処理をしない場合に使用)
    //flg:1:値プラス、2:値マイナス
    //GET: user_id, point,star,live_count,seconds,flg
    static func saveLiveLevelNew(user_id:Int, point:Int, star:Int, live_count:Int, seconds:Int, flg:Int){

        var stringUrl = Util.URL_ADD_LIVE_POINT_DO_NEW
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&point=")
        stringUrl.append(String(point))
        stringUrl.append("&star=")
        stringUrl.append(String(star))
        stringUrl.append("&live_count=")
        stringUrl.append(String(live_count))
        stringUrl.append("&seconds=")
        stringUrl.append(String(seconds))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
        
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            self.setMyInfo()
        }
    }
    
    //絆レベルの更新・追加(更新後に何も処理をしない場合に使用)
    //flg:1:値プラス、2:値マイナス
    //GET: user_id, target_user_id,exp,live_count,present_point,flg
    //URL_SAVE_CONNECT_LEVEL_NEW = "https://p2p.monopol.jp/saveConnectLevelNew.php"//レベルの計算も含む
    static func saveConnectLevelNew(user_id:Int, target_user_id:Int, exp:Int, live_count:Int, present_point:Int, flg:Int){
        var stringUrl = Util.URL_SAVE_CONNECT_LEVEL_NEW
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&target_user_id=")
        stringUrl.append(String(target_user_id))
        stringUrl.append("&exp=")
        stringUrl.append(String(exp))
        stringUrl.append("&live_count=")
        stringUrl.append(String(live_count))
        stringUrl.append("&present_point=")
        stringUrl.append(String(present_point))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
        
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    //ペアランキング(絆ランキング)の更新・追加(更新後に何も処理をしない場合に使用)
    //GET: user_id,cast_id,exp
    static func savePairMonthRanking(user_id:Int, cast_id:Int, exp:Int){
        var stringUrl = Util.URL_SAVE_PAIR_RANKING
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&exp=")
        stringUrl.append(String(exp))
        
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    //コインの消費履歴を保存する
    //type=1:マイコレクションMAX値 2:トーク開封 3:トーク送信(テキスト) 4: トーク送信(画像)5:ライブ配信(1枠)6:プレゼント購入7:スクショ受け取り8:ライブ配信(延長) 99:コインの返却
    //type=5,8のみpointUseDより前に実行すること
    static func writePointUseRireki(type:Int, point:Double, user_id:Int, target_user_id:Int){
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let uuid = UserDefaults.standard.string(forKey: "uuid")
        
        //GET: point,type,user_id,target_user_id,user_uid
        var stringUrl = Util.URL_POINT_USE_RIREKI
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&user_uid=")
        stringUrl.append(uuid!)
        stringUrl.append("&type=")
        stringUrl.append(String(type))
        stringUrl.append("&point=")
        stringUrl.append(String(point))
        stringUrl.append("&target_user_id=")
        stringUrl.append(String(target_user_id))
        
        //print(stringUrl)
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }

    //コインの消費履歴を保存する(type=5,8用)
    //type=1:マイコレクションMAX値 2:トーク開封 3:トーク送信(テキスト) 4: トーク送信(画像)5:ライブ配信(1枠)6:プレゼント購入7:スクショ受け取り8:ライブ配信(延長) 99:コインの返却
    //type=5,8のみpointUseDより前に実行すること
    static func writePointUseRirekiType58(type:Int, point:Double, user_id:Int, target_user_id:Int){
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let uuid = UserDefaults.standard.string(forKey: "uuid")
        
        //GET: point,type,user_id,target_user_id,user_uid
        var stringUrl = Util.URL_POINT_USE_RIREKI
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&user_uid=")
        stringUrl.append(uuid!)
        stringUrl.append("&type=")
        stringUrl.append(String(type))
        stringUrl.append("&point=")
        stringUrl.append(String(point))
        stringUrl.append("&target_user_id=")
        stringUrl.append(String(target_user_id))
        
        //print(stringUrl)
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //コインの消費処理
            //type:1=コインの返却 0:コインの消費
            self.pointUseDo(type:0, userId:user_id, point:point)
        }
    }
    
    //配信ポイント(point)の獲得履歴に保存する
    //配信時のリスナー一覧にも表示される
    //GET:type,cast_id,user_id,point,star,seconds,re_star, status
    //type:1:配信による経験値 2:プレゼントによる経験値3:延長による経験値99:没収したスター
    static func writeLivePointRireki(type:Int, cast_id:Int, user_id:Int, point:Int, star:Int, seconds:Int, re_star:Int){
        var stringUrl = Util.URL_LIVE_POINT_RIREKI
        stringUrl.append("?status=1&type=")
        stringUrl.append(String(type))
        stringUrl.append("&cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&point=")
        stringUrl.append(String(point))
        stringUrl.append("&star=")
        stringUrl.append(String(star))
        stringUrl.append("&seconds=")
        stringUrl.append(String(seconds))
        stringUrl.append("&re_star=")
        stringUrl.append(String(re_star))
        
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    //チャット履歴保存
    //GET: type,from_user_id,to_user_id,present_id,chat_text,status
    //URL_SAVE_CHAT = "https://p2p.monopol.jp/saveChatRireki.php"//ユーザー、モデル間などの全てのチャット履歴を保存
    static func saveChatRireki(type:Int, from_user_id:Int, to_user_id:Int, present_id:Int, chat_text:String, status:Int){
        var stringUrl = Util.URL_SAVE_CHAT
        stringUrl.append("?type=")
        stringUrl.append(String(type))
        stringUrl.append("&from_user_id=")
        stringUrl.append(String(from_user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(String(to_user_id))
        stringUrl.append("&present_id=")
        stringUrl.append(String(present_id))
        stringUrl.append("&chat_text=")
        stringUrl.append(chat_text)
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    //トーク未読数取得
    static func getNoreadCount(user_id:Int){
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        var stringUrl = Util.URL_GET_TALK_NOREAD_COUNT
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultNoreadJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        //let strListenerUserId = obj.noread_count
                        //
                        UserDefaults.standard.set(obj.noread_count, forKey: "talkNoreadCount")
                    }
                    
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            
        }
    }
    
    //キャストがライブ配信する時(or 配信中)に予約フラグを変更
    //GET: user_id, flg:0=予約可能,1=予約不可
    static func modifyReserveFlg(user_id:Int, flg:Int){
        var stringUrl = Util.URL_MODIFY_RESERVE_FLG
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    if data != nil {
                        //ステータス変更が成功
                    }else{
                    }
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
            
        }
    }

    //fcm_tokenの更新(プッシュ通知用)
    //GET: user_id, token
    static func modifyFcmToken(user_id:Int, token:String){
        var stringUrl = Util.URL_MODIFY_TOKEN
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&token=")
        stringUrl.append(token)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    if data != nil {
                        //ステータス変更が成功
                    }else{
                    }
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
            
        }
    }
    
    /*
    //ログインの状態を変更
    //user_name ユーザー名
    static func modifyStatusDoByUserName(user_id:Int, status:Int, user_name:String){
        var stringUrl = Util.URL_MOD_STATUS_DO_BY_USER_NAME
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        stringUrl.append("&user_name=")
        stringUrl.append(user_name)
        
        print(stringUrl)
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    if data != nil {
                        //ステータス変更が成功
                        //print("ステータス変更が成功  " + String(status))
                    }else{
                    }
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
        }
    }
     */
    //ログインの状態を変更
    //live_user_id 現在ライブ中のユーザーID
    static func loginDo(user_id:Int, status:Int, live_user_id:Int, reserve_flg:Int, max_reserve_count:Int, password:String){
        //3:キャスト-ログオフ状態
        //待機ログイン処理
        //UUIDを取得
        //let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
        //let stringUrl = Util.URL_MOD_STATUS+"?uid="+String(phonedeviceId)+"&status=1";
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        var stringUrl = Util.URL_MOD_STATUS
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        stringUrl.append("&live_user_id=")
        stringUrl.append(String(live_user_id))
        stringUrl.append("&reserve_flg=")
        stringUrl.append(String(reserve_flg))
        stringUrl.append("&max_reserve_count=")
        stringUrl.append(String(max_reserve_count))
        stringUrl.append("&password=")
        stringUrl.append(password)

        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    if data != nil {
                        //ステータス変更が成功
                        //print("ステータス変更が成功  " + String(status))
                    }else{
                    }
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
            //UserDefaults.standard.set(status, forKey: "login_status")
        }
    }
    
    /*
    //ログインの状態を変更(予約がある場合)
    //live_user_id 現在ライブ中のユーザーID
    static func loginDoByReserve(user_id:Int, status:Int, live_user_id:Int){
        //3:キャスト-ログオフ状態
        //待機ログイン処理
        //UUIDを取得
        //let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
        //let stringUrl = Util.URL_MOD_STATUS+"?uid="+String(phonedeviceId)+"&status=1";
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        var stringUrl = Util.URL_MOD_STATUS_BY_RESERVE
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        stringUrl.append("&live_user_id=")
        stringUrl.append(String(live_user_id))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    if data != nil {
                        //ステータス変更が成功
                        //print("ステータス変更が成功  " + String(status))
                    }else{
                    }
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
        }
    }*/
    
    //ライブ配信情報を保存する
    //GET: cast_id, type, notes
    //type=1:まつさんからスクショリクエストがありました
    //2:まつさんにスクショを送りました
    //3:ランクがアップしました（R47）
    //4:やじさんが予約しました
    //・1枠目終了まであと1分
    //・1枠目終了まであと30秒
    //・1枠目終了まであと15秒
    static func saveLiveRireki(cast_id:Int, type:Int, notes:String, listener_id:Int) {
        var stringUrl = Util.URL_SAVE_LIVE_LOG
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&type=")
        stringUrl.append(String(type))
        stringUrl.append("&notes=")
        stringUrl.append(notes)
        stringUrl.append("&user_id=")
        stringUrl.append(String(listener_id))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }

    //待機時のタイムスタンプ
    //1:初回待機 2:ライブ開始 3:ライブ後の待機 4：待機解除 5:運営タイムスタンプ（待機確認）6:リスナーのリクエスト送信
    //GET: user_id,listener_user_id,type
    static func addActionRireki(user_id:Int, listener_id:Int, type:Int, value01:Int, value02:Int) {
        var stringUrl = Util.URL_ADD_ACTION_RIREKI
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&listener_user_id=")
        stringUrl.append(String(listener_id))
        stringUrl.append("&type=")
        stringUrl.append(String(type))
        stringUrl.append("&value01=")
        stringUrl.append(String(value01))
        stringUrl.append("&value02=")
        stringUrl.append(String(value02))
        print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            print("処理終了")
        }
    }
    
    //自分の情報をアプリ内に記憶する
    static func setMyInfo(){
        //いったんクリアしておく
        //userInfo.removeAll()
        var strUserId: String = ""
        var strNextId: String = ""
        var strNextPass: String = ""
        var strFcmToken: String = ""
        var strNotifyFlg: String = ""
        var strUuid: String = ""
        var strUserName: String = ""
        var strPhotoFlg: String = ""
        var strPhotoName: String = ""
        var strPhotoBackgroundFlg: String = ""
        var strPhotoBackgroundName: String = ""
        var strMovieFlg: String = ""
        var strMovieName: String = ""
        var strSnsUserid01: String = ""
        var strSnsUserid02: String = ""
        var strSnsUserid03: String = ""
        var strValue01: String = ""
        var strValue02: String = ""
        var strValue03: String = ""
        var strValue04: String = ""
        //var strValue05: String = ""
        var strMycollectionMax: String = ""
        var strPoint: String = ""
        var strPointPay: String = ""
        var strPointFree: String = ""
        var strLivePoint: String = ""
        var strWatchLevel: String = ""
        var strLiveLevel: String = ""
        var strCastRank: String = ""
        var strCastOfficialFlg: String = ""
        var strCastMonthRanking: String = ""
        var strCastMonthRankingPoint: String = ""
        var strTwitter: String = ""
        var strFacebook: String = ""
        var strInstagram: String = ""
        var strHomepage: String = ""
        var strFreetext: String = ""
        var strOfficialReadFlg: String = ""
        var strNoticeText: String = ""
        var strLiveTotalCount: String = ""
        var strLiveTotalSec: String = ""
        var strLiveTotalStar: String = ""
        var strLiveNowStar: String = ""
        var strPaymentRequestStar: String = ""
        var strLoginStatus: String = ""
        var strLiveUserId: String = ""
        var strReserveUserId: String = ""
        var strReserveFlg: String = ""
        var strMaxReserveCount: String = ""
        var strFirstFlg01: String = ""
        var strFirstFlg02: String = ""
        var strFirstFlg03: String = ""
        //var strLoginTime: String = ""
        //var strInsTime: String = ""
        var strBankInfo01: String = ""
        var strBankInfo02: String = ""
        var strBankInfo03: String = ""
        var strBankInfo04: String = ""
        var strBankInfo05: String = ""
        var strLastStarGetTime: String = ""
        var strPubRankName: String = ""
        var strPubGetLivePoint: String = ""
        var strPubExGetLivePoint: String = ""
        var strPubCoin: String = ""
        var strPubExCoin: String = ""
        var strPubMinReserveCoin: String = ""
        //var strCancelCoin: String = ""
        //var strCancelGetStar: String = ""
        //個別設定用
        var strExLiveSec: String = ""
        var strExGetLivePoint: String = ""
        var strExExGetLivePoint: String = ""
        var strExCoin: String = ""
        var strExExCoin: String = ""
        var strExMinReserveCoin: String = ""
        var strExStatus: String = ""//1有効2無効3設定済み無効
        
        //自分の情報取得
        //UUIDを取得
        let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let stringUrl = Util.URL_USER_INFO_BY_UUID + "?uuid=" + String(phonedeviceId);
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultJsonTemp.self, from: data!)
                    //self.idCount = json.count
                    
                    //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                    for obj in json.result {
                        strUserId = obj.user_id
                        strNextId = obj.next_id
                        strNextPass = obj.next_pass
                        strFcmToken = obj.fcm_token
                        strNotifyFlg = obj.notify_flg
                        strUuid = obj.uuid
                        strUserName = obj.user_name.toHtmlString()
                        strPhotoFlg = obj.photo_flg
                        strPhotoName = obj.photo_name
                        strPhotoBackgroundFlg = obj.photo_background_flg
                        strPhotoBackgroundName = obj.photo_background_name
                        strMovieFlg = obj.movie_flg
                        strMovieName = obj.movie_name
                        strSnsUserid01 = obj.sns_userid01
                        strSnsUserid02 = obj.sns_userid02
                        strSnsUserid03 = obj.sns_userid03
                        strValue01 = obj.value01
                        strValue02 = obj.value02
                        strValue03 = obj.value03
                        strValue04 = obj.value04
                        //strValue05 = obj.value05
                        strMycollectionMax = obj.mycollection_max
                        strPoint = obj.point
                        strPointPay = obj.point_pay
                        strPointFree = obj.point_free
                        strLivePoint = obj.live_point
                        strWatchLevel = obj.watch_level
                        strLiveLevel = obj.live_level
                        strCastRank = obj.cast_rank
                        strCastOfficialFlg = obj.cast_official_flg
                        strCastMonthRanking = obj.cast_month_ranking
                        strCastMonthRankingPoint = obj.cast_month_ranking_point
                        strTwitter = obj.twitter.toHtmlString()
                        strFacebook = obj.facebook.toHtmlString()
                        strInstagram = obj.instagram.toHtmlString()
                        strHomepage = obj.homepage.toHtmlString()
                        strFreetext = obj.freetext.toHtmlString()
                        strOfficialReadFlg = obj.official_read_flg
                        strNoticeText = obj.notice_text
                        //strNoticePhotoPath = obj.notice_photo_path
                        strLiveTotalCount = obj.live_total_count
                        strLiveTotalSec = obj.live_total_sec
                        strLiveTotalStar = obj.live_total_star
                        strLiveNowStar = obj.live_now_star
                        strPaymentRequestStar = obj.payment_request_star
                        strLoginStatus = obj.login_status
                        strLiveUserId = obj.live_user_id
                        strReserveUserId = obj.reserve_user_id
                        strReserveFlg = obj.reserve_flg
                        strMaxReserveCount = obj.max_reserve_count
                        strFirstFlg01 = obj.first_flg01
                        strFirstFlg02 = obj.first_flg02
                        strFirstFlg03 = obj.first_flg03
                        //strLoginTime = obj.login_time
                        //strInsTime = obj.ins_time
                        strBankInfo01 = obj.bank_info01.toHtmlString()
                        strBankInfo02 = obj.bank_info02
                        strBankInfo03 = obj.bank_info03
                        strBankInfo04 = obj.bank_info04
                        strBankInfo05 = obj.bank_info05
                        strLastStarGetTime = obj.last_star_get_time
                        strPubRankName = obj.pub_rank_name
                        strPubGetLivePoint = obj.pub_get_live_point
                        strPubExGetLivePoint = obj.pub_ex_get_live_point
                        strPubCoin = obj.pub_coin
                        strPubExCoin = obj.pub_ex_coin
                        strPubMinReserveCoin = obj.pub_min_reserve_coin
                        //strCancelCoin = obj.cancel_coin
                        //strCancelGetStar = obj.cancel_get_star
                        //個別設定用
                        strExLiveSec = obj.ex_live_sec
                        strExGetLivePoint = obj.ex_get_live_point
                        strExExGetLivePoint = obj.ex_ex_get_live_point
                        strExCoin = obj.ex_coin
                        strExExCoin = obj.ex_ex_coin
                        strExMinReserveCoin = obj.ex_min_reserve_coin
                        strExStatus = obj.ex_status
                        
                        break
                    }
                    
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            /*
             //self.CollectionView.reloadData()
             //self.nameField.text = "モデル名："+self.strNames[0]
             //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
             UserDefaults.standard.set(userInfo[0].cast_rank, forKey: "cast_rank")
             UserDefaults.standard.set(userInfo[0].cast_official_flg, forKey: "cast_official_flg")//1:公式
             //キャスト月間ランキング
             UserDefaults.standard.set(userInfo[0].cast_month_ranking, forKey: "cast_month_ranking")
             //キャスト月間ランキングポイント
             UserDefaults.standard.set(userInfo[0].cast_month_ranking_point, forKey: "cast_month_ranking_point")
             */
            UserDefaults.standard.set(strUserId, forKey: "user_id")
            UserDefaults.standard.set(strNextId, forKey: "next_id")
            UserDefaults.standard.set(strNextPass, forKey: "next_pass")
            UserDefaults.standard.set(strFcmToken, forKey: "fcm_token")
            UserDefaults.standard.set(strNotifyFlg, forKey: "notify_flg")
            UserDefaults.standard.set(strUuid, forKey: "uuid")
            UserDefaults.standard.set(strUserName, forKey: "myName")
            UserDefaults.standard.set(strPhotoFlg, forKey: "myPhotoFlg")
            UserDefaults.standard.set(strPhotoName, forKey: "myPhotoName")
            UserDefaults.standard.set(strPhotoBackgroundFlg, forKey: "myPhotoBackgroundFlg")
            UserDefaults.standard.set(strPhotoBackgroundName, forKey: "myPhotoBackgroundName")
            UserDefaults.standard.set(strMovieFlg, forKey: "myMovieFlg")
            UserDefaults.standard.set(strMovieName, forKey: "myMovieName")
            UserDefaults.standard.set(strSnsUserid01, forKey: "sns_userid01")
            UserDefaults.standard.set(strSnsUserid02, forKey: "sns_userid02")
            UserDefaults.standard.set(strSnsUserid03, forKey: "sns_userid03")
            UserDefaults.standard.set(strValue01, forKey: "sex_cd")
            UserDefaults.standard.set(strValue02, forKey: "follower_num")
            UserDefaults.standard.set(strValue03, forKey: "follow_num")
            UserDefaults.standard.set(strValue04, forKey: "organizer_webview_flg")
            UserDefaults.standard.set(strMycollectionMax, forKey: "myCollection_max")
            UserDefaults.standard.set(strPoint, forKey: "myPoint")//小数
            UserDefaults.standard.set(strPointPay, forKey: "myPointPay")//小数
            UserDefaults.standard.set(strPointFree, forKey: "myPointFree")//小数
            UserDefaults.standard.set(strLivePoint, forKey: "myLivePoint")
            UserDefaults.standard.set(strWatchLevel, forKey: "myWatchLevel")
            UserDefaults.standard.set(strLiveLevel, forKey: "myLiveLevel")
            //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
            UserDefaults.standard.set(strCastRank, forKey: "cast_rank")
            UserDefaults.standard.set(strCastOfficialFlg, forKey: "cast_official_flg")//1:公式
            //キャスト月間ランキング
            UserDefaults.standard.set(strCastMonthRanking, forKey: "cast_month_ranking")
            //キャスト月間ランキングポイント
            UserDefaults.standard.set(strCastMonthRankingPoint, forKey: "cast_month_ranking_point")
            UserDefaults.standard.set(strTwitter, forKey: "twitter")
            UserDefaults.standard.set(strFacebook, forKey: "facebook")
            UserDefaults.standard.set(strInstagram, forKey: "instagram")
            UserDefaults.standard.set(strHomepage, forKey: "homepage")
            UserDefaults.standard.set(strFreetext, forKey: "freetext")
            UserDefaults.standard.set(strOfficialReadFlg, forKey: "official_read_flg")
            UserDefaults.standard.set(strNoticeText, forKey: "notice_text")
            //UserDefaults.standard.set(strNoticePhotoPath, forKey: "notice_photo_path")
            UserDefaults.standard.set(strLiveTotalCount, forKey: "live_total_count")
            UserDefaults.standard.set(strLiveTotalSec, forKey: "live_total_sec")
            UserDefaults.standard.set(strLiveTotalStar, forKey: "live_total_star")
            UserDefaults.standard.set(strLiveNowStar, forKey: "live_now_star")
            UserDefaults.standard.set(strPaymentRequestStar, forKey: "payment_request_star")
            UserDefaults.standard.set(strLoginStatus, forKey: "login_status")
            UserDefaults.standard.set(strLiveUserId, forKey: "live_user_id")
            UserDefaults.standard.set(strReserveUserId, forKey: "reserve_user_id")
            UserDefaults.standard.set(strReserveFlg, forKey: "reserve_flg")
            UserDefaults.standard.set(strMaxReserveCount, forKey: "reserve_flg")
            UserDefaults.standard.set(strFirstFlg01, forKey: "first_flg01")
            UserDefaults.standard.set(strFirstFlg02, forKey: "first_flg02")
            UserDefaults.standard.set(strFirstFlg03, forKey: "first_flg03")
            UserDefaults.standard.set(strBankInfo01, forKey: "bank_info01")
            UserDefaults.standard.set(strBankInfo02, forKey: "bank_info02")
            UserDefaults.standard.set(strBankInfo03, forKey: "bank_info03")
            UserDefaults.standard.set(strBankInfo04, forKey: "bank_info04")
            UserDefaults.standard.set(strBankInfo05, forKey: "bank_info05")
            UserDefaults.standard.set(strLastStarGetTime, forKey: "last_star_get_time")
            UserDefaults.standard.set(strPubRankName, forKey: "rank_name")
            UserDefaults.standard.set(strExStatus, forKey: "ex_status")
            
            //1有効2無効3設定済み無効
            //if(strExStatus == "1" || strExStatus == "3"){
            if(strExStatus == "1"){
                //個別設定がされている
                UserDefaults.standard.set(strExGetLivePoint, forKey: "get_live_point")
                UserDefaults.standard.set(strExExGetLivePoint, forKey: "ex_get_live_point")
                UserDefaults.standard.set(strExCoin, forKey: "coin")
                UserDefaults.standard.set(strExExCoin, forKey: "ex_coin")
                UserDefaults.standard.set(strExMinReserveCoin, forKey: "min_reserve_coin")
                //UserDefaults.standard.set(strCancelCoin, forKey: "cancel_coin")
                //UserDefaults.standard.set(strCancelGetStar, forKey: "cancel_get_star")
                //１枠の秒数を設定
                UserDefaults.standard.set(strExLiveSec, forKey: "live_sec")
                //self.appDelegate.init_seconds = strExLiveSec
                
                //個別設定がされているかのフラグ（１：されている　２：されていない）
                //UserDefaults.standard.set("1", forKey: "streamer_individual_setting_flg")
            }else{
                //個別設定がされてない
                UserDefaults.standard.set(strPubGetLivePoint, forKey: "get_live_point")
                UserDefaults.standard.set(strPubExGetLivePoint, forKey: "ex_get_live_point")
                UserDefaults.standard.set(strPubCoin, forKey: "coin")
                UserDefaults.standard.set(strPubExCoin, forKey: "ex_coin")
                UserDefaults.standard.set(strPubMinReserveCoin, forKey: "min_reserve_coin")
                //UserDefaults.standard.set(strCancelCoin, forKey: "cancel_coin")
                //UserDefaults.standard.set(strCancelGetStar, forKey: "cancel_get_star")
                //１枠の秒数を設定
                UserDefaults.standard.set(Util.INIT_LIVE_SECONDS, forKey: "live_sec")
                //self.appDelegate.init_seconds = Util.INIT_LIVE_SECONDS
                
                //個別設定がされているかのフラグ（１：されている　２：されていない）
                //UserDefaults.standard.set("2", forKey: "streamer_individual_setting_flg")
            }
        }
    }
    
    //コインの購入履歴を保存
    //func purchaseRirekiDo(pathindex:Int, _ after:@escaping () -> Void){
    //func purchaseRirekiDo(pathindex:Int){
    static func purchaseRirekiDo(user_id:Int, user_uid:String, product_id:String, apple_id:String, price:String, point:String){
        //UUIDを取得
        //let user_uid = UIDevice.current.identifierForVendor!.uuidString
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        //let product_id = appDelegate.productList[pathindex].productId
        //let apple_id = appDelegate.productList[pathindex].appleId
        //let price = appDelegate.productList[pathindex].price
        //let point = appDelegate.productList[pathindex].point
        
        //GET:user_id,price,point,user_uid,product_id,apple_id
        var stringUrl = Util.URL_PURCHASE_RIREKI
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&user_uid=")
        stringUrl.append(user_uid)
        stringUrl.append("&product_id=")
        stringUrl.append(product_id)
        stringUrl.append("&apple_id=")
        stringUrl.append(apple_id)
        stringUrl.append("&price=")
        stringUrl.append(price)
        stringUrl.append("&point=")
        stringUrl.append(point)
        
        //let stringUrl = Util.URL_PURCHASE_RIREKI+"?user_id="+user_id+"&user_uid="+user_uid+"&product_id="+product_id+"&apple_id="+apple_id+"&price="+price+"&point="+point;
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        //print("aaaa")
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //リストの取得を待ってから更新
            //self.CollectionView.reloadData()
        }
    }
    
    //FirstFlg02の更新
    //FIRST_FLG02:初回フラグ(1:10人フォロー達成済 2:達成後コイン受取済)
    static func modifyFirstFlg02(flg:Int){
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        //Util.modifyFirstFlg01(user_id:user_id, flg:1)
        
        var stringUrl = Util.URL_MODIFY_FIRST_FLG02
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
        print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //リストの取得を待ってから更新
            //FIRST_FLG02:初回フラグ(1:10人フォロー達成済 2:達成後コイン受取済)
            UserDefaults.standard.set(String(flg), forKey: "first_flg02")
        }
    }
    
    //フォローした時にアプリ内の数値をプラス１する処理
    static func plusFollow(){
        var follow_num = UserDefaults.standard.integer(forKey: "follow_num")
        follow_num = follow_num + 1
        UserDefaults.standard.set(follow_num, forKey: "follow_num")
        
        //FIRST_FLG02:初回フラグ(1:10人フォロー達成済 2:達成後コイン受取済)
        let first_flg02 = UserDefaults.standard.integer(forKey: "first_flg02")
        
        //10人フォローした場合に更新する
        if(follow_num >= 10 && first_flg02 != 1 && first_flg02 != 2){
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            //Util.modifyFirstFlg01(user_id:user_id, flg:1)
        
            var stringUrl = Util.URL_MODIFY_FIRST_FLG02
            stringUrl.append("?user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&flg=1")
            print(stringUrl)
        
            // Swift4からは書き方が変わりました。
            let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
            //let decodedString:String = text.removingPercentEncoding!
            let req = URLRequest(url: url)
        
            //非同期処理を行う
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
            //var json_result :ResultJson? = nil
        
            dispatchGroup.enter()
            dispatchQueue.async {
                let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                //リストの取得を待ってから更新
                //FIRST_FLG02:初回フラグ(1:10人フォロー達成済 2:達成後コイン受取済)
                //let first_flg02 = UserDefaults.standard.integer(forKey: "first_flg02")
                UserDefaults.standard.set("1", forKey: "first_flg02")
            }
        }
    }
    
    //フォロー解除した時にアプリ内の数値をマイナス１する処理
    static func minusFollow(){
        var follow_num = UserDefaults.standard.integer(forKey: "follow_num")
        if(follow_num > 0){
            follow_num = follow_num - 1
        }
        UserDefaults.standard.set(follow_num, forKey: "follow_num")
    }
    
    //現在の時間取得
    static func getNowDate(pattern:Int)->String{
        let now = Date()
        let formatter = DateFormatter()
        if(pattern == 1){
            formatter.locale = Locale(identifier: "en_US_POSIX")//重要
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            //formatter.setLocalizedDateFormatFromTemplate("yyyy/MM/dd HH:mm:ss")
        }
        return formatter.string(from: now)
    }
    
    //先頭num文字＋･･･の文字列を作成
    static func strMin(str:String, num:Int)->String{
        let strCount = str.count
        if(strCount > num){
            let strTemp = String(str.prefix(num)) + "･･･"
            return strTemp
        }else{
            return str
        }
    }
    
    //N秒後＞適切な文字列に変換する>ストリーマーのライブ配信中のインフォで使用
    static func convertStrBySecOnLive(sec:Int)->String{
        if(sec < 30){
            //30秒未満
            return "まもなく開始"
        }else if(sec >= 30 && sec <= 60){
            return "開始まで約1分"
        }else{
            //切り上げる
            let temp_min = ceil(Double(sec) / 60)
            return "開始まで約" + String(Int(temp_min)) + "分"
        }
    }
    
    //N秒後＞適切な文字列に変換する>リスナー側が使用
    static func convertStrBySec(sec:Int)->String{
        if(sec < 30){
            //30秒未満
            return "まもなく"
        }else if(sec >= 30 && sec <= 60){
            return "約1分後に"
        }else{
            //切り上げる
            let temp_min = ceil(Double(sec) / 60)
            return "約" + String(Int(temp_min)) + "分後に"
        }
    }
    
    //N秒後＞適切な文字列に変換する(part2)>リスナー側が使用
    static func convertStrBySecReserve(sec:Int)->String{
        if(sec < 30){
            //30秒未満
            return "まもなくサシライブを開始します。"
        }else if(sec >= 30 && sec <= 60){
            return "開始まであと約1分\n(時間は多少前後します)"
        }else{
            //切り上げる
            let temp_min = ceil(Double(sec) / 60)
            return "開始まであと約" + String(Int(temp_min)) + "分\n(時間は多少前後します)"
        }
    }

    //予約ありの状態でリスナーが終了した場合のストリーマー待ち文章
    //N秒後＞適切な文字列に変換する(part3)>ストリーマー側が使用
    static func convertStrBySecNextLive(sec:Int)->String{
        if(sec < 30){
            //30秒未満
            return "次の配信までそのままお待ちください。"
        }else if(sec >= 30 && sec <= 60){
            return "次の配信まで約1分\n(時間は多少前後します)"
        }else{
            //切り上げる
            let temp_min = ceil(Double(sec) / 60)
            return "次の配信まで約" + String(Int(temp_min)) + "分\n(時間は多少前後します)"
        }
    }
    
    //横に長い画像ならwのサイズに、縦が長い画像ならhのサイズにアス比を維持して画像のリサイズをします
    /*
     static func resizeImage(image :UIImage, w:Int, h:Int) ->UIImage {
     // アスペクト比を維持
     let origRef    = image.cgImage
     let origWidth  = Int(origRef!.width)
     let origHeight = Int(origRef!.height)
     var resizeWidth:Int = 0, resizeHeight:Int = 0
     if (origWidth < origHeight) {
     resizeWidth = w
     resizeHeight = origHeight * resizeWidth / origWidth
     } else {
     resizeHeight = h
     resizeWidth = origWidth * resizeHeight / origHeight
     }
     
     let resizeSize = CGSize.init(width: CGFloat(resizeWidth), height: CGFloat(resizeHeight))
     
     UIGraphicsBeginImageContextWithOptions(resizeSize, false, 0.0)
     
     image.draw(in: CGRect.init(x: 0, y: 0, width: CGFloat(resizeWidth), height: CGFloat(resizeHeight)))
     
     let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     
     return resizeImage!
     }*/
    static func resizeImage(image: UIImage, width: Double, height: Double) -> UIImage {
        if(image.size.width > image.size.height){
            //横長の画像
            if(Double(image.size.height) < height){
                return image
            }else{
                // オリジナル画像のサイズからアスペクト比を計算
                let aspectScale = image.size.width / image.size.height
                
                // widthからアスペクト比を元にリサイズ後のサイズを取得
                let resizedSize = CGSize(width: height * Double(aspectScale), height: height)
                
                // リサイズ後のUIImageを生成して返却
                UIGraphicsBeginImageContext(resizedSize)
                image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return resizedImage!
            }
        }else{
            //縦長の画像
            if(Double(image.size.width) < width){
                return image
            }else{
                // オリジナル画像のサイズからアスペクト比を計算
                let aspectScale = image.size.height / image.size.width
                
                // widthからアスペクト比を元にリサイズ後のサイズを取得
                let resizedSize = CGSize(width: width, height: width * Double(aspectScale))
                
                // リサイズ後のUIImageを生成して返却
                UIGraphicsBeginImageContext(resizedSize)
                image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return resizedImage!
            }
        }
    }
    
    //プロフィールで使用する
    //固定サイズのサムネイルを生成するサンプル。画像を縮小し、中心から切り取る（Resize and crop）
    static func cropThumbnailImage(image: UIImage, width: Double, height: Double) -> UIImage {
        let image_temp:UIImage = self.resizeImage(image: image, width: width, height: height)
        
        // 切り抜き処理
        let cropRect  = CGRect.init(x: CGFloat((Double(image_temp.size.width) - width) / 2), y: CGFloat((Double(image_temp.size.height) - height) / 2), width: CGFloat(width), height: CGFloat(height))
        let cropRef = image_temp.cgImage!.cropping(to: cropRect)
        let cropImage = UIImage(cgImage: cropRef!)
        
        return cropImage
    }
    
    /*
     static func cropThumbnailImage(image :UIImage, w:Int, h:Int) ->UIImage
     {
     // リサイズ処理
     let origRef    = image.cgImage
     let origWidth  = Int(origRef!.width)
     let origHeight = Int(origRef!.height)
     var resizeWidth:Int = 0, resizeHeight:Int = 0
     
     if (origWidth < origHeight) {
     resizeWidth = w
     resizeHeight = origHeight * resizeWidth / origWidth
     } else {
     resizeHeight = h
     resizeWidth = origWidth * resizeHeight / origHeight
     }
     
     let resizeSize = CGSize.init(width: CGFloat(resizeWidth), height: CGFloat(resizeHeight))
     
     UIGraphicsBeginImageContext(resizeSize)
     
     image.draw(in: CGRect.init(x: 0, y: 0, width: CGFloat(resizeWidth), height: CGFloat(resizeHeight)))
     
     let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     
     // 切り抜き処理
     
     let cropRect  = CGRect.init(x: CGFloat((resizeWidth - w) / 2), y: CGFloat((resizeHeight - h) / 2), width: CGFloat(w), height: CGFloat(h))
     let cropRef   = resizeImage!.cgImage!.cropping(to: cropRect)
     let cropImage = UIImage(cgImage: cropRef!)
     
     return cropImage
     }
     */
    //コインの消費処理(消費したあとに更新処理など何もしない場合)
    //type:1=コインの返却 0:コインの消費
    static func pointUseDo(type:Int, userId:Int, point:Double){
        //GET:user_id,point,user_uid
        var stringUrl = Util.URL_POINT_USE_DO
        stringUrl.append("?user_id=")
        stringUrl.append(String(userId))
        stringUrl.append("&point=")
        stringUrl.append(String(point))
        stringUrl.append("&type=")
        stringUrl.append(String(type))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)

        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //リストの取得を待ってから更新
            //self.CollectionView.reloadData()
            //ポイントをセットする(残りポイント：＊＊＊＊ポイント)
            //point更新
            //ポイントをセットする(残りポイント：＊＊＊＊ポイント)
            var myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
            var myPointPay:Double = UserDefaults.standard.double(forKey: "myPointPay")
            if(type == 1){
                //コインの返却の場合
                myPoint = myPoint + Double(point)
                UserDefaults.standard.set(myPoint, forKey: "myPoint")
                //self.pointLabel.text = "残りポイント：" + Util.numFormatter(num: myPoint) + "ポイント"
            }else{
                //コインの消費の場合
                //有償コインから消費
                myPoint = myPoint - Double(point)
                myPointPay = myPointPay - Double(point)
                if(myPointPay < 0.0){
                    myPointPay = 0.0
                }
                UserDefaults.standard.set(myPoint, forKey: "myPoint")
                UserDefaults.standard.set(myPointPay, forKey: "myPointPay")
            }
        }
    }

    /******************************************/
    //ポイント計算関連
    /******************************************/
    //スターをゲットした時に実行される
    //type:0=スターのゲット 1=スターの没収
    static func getStar(type:Int, user_id:Int, star_num:Int){
        //スター加算処理
        let star_temp = UserDefaults.standard.integer(forKey: "live_now_star")
        
        if(type == 1){
            //スターの没収
            UserDefaults.standard.set(star_temp - star_num, forKey: "live_now_star")
        }else{
            //スターのゲット
            UserDefaults.standard.set(star_temp + star_num, forKey: "live_now_star")
        }
        
        //mySQL更新(スター加算)
        //スターの加算処理
        //GET: user_id, star, type
        //type 1:スターの没収
        var stringUrl = Util.URL_ADD_STAR_DO
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&star=")
        stringUrl.append(String(star_num))
        stringUrl.append("&type=")
        stringUrl.append(String(type))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    /*************************************************************/
    //重要(リスナーで使用する)
    //共通：コイン・スターの消費追加処理(消費したあとに更新処理など何もしない場合)
    //type=1:マイコレクションMAX値 2:トーク開封 3:トーク送信(テキスト) 4: トーク送信(画像)5:ライブ配信(1枠)6:プレゼント購入7:スクショ受け取り
    //connection_exp：絆レベルの経験値
    //coin:消費したコイン数
    //star:キャストに加算されるスター
    //絆レベルの更新・追加(更新後に何も処理をしない場合に使用)
    //connection_exp_flg:1:絆レベルの経験値をプラス、2:値マイナス
    //live_count:ライブ配信をした時のみ1を指定する
    //配信ポイントについて
    //live_point_type:0:配信ポイントなし 1:配信 2:プレゼント
    //live_point:キャストが得る配信ポイント
    /*************************************************************/
    /*
    static func commonStarDo(type:Int, user_id:Int, cast_id:Int, live_count:Int, coin:Double, star:Int, connection_exp:Int, connection_exp_flg:Int, connection_bonus_rate:Double, live_point_type:Int, live_point:Int, minutes:Double){
        //コインの消費処理
        UtilFunc.pointUseD(userId: user_id, point: coin)
        //コイン消費履歴に履歴を保存する
        UtilFunc.writePointUseRirek(type:type, point:coin, target_user_id:cast_id)
        
        //絆レベルの更新
        //connect_levelの更新、pair_month_rankingの更新が必要
        //取得する絆レベルの経験値
        //プレゼントの消費ポイント1コインにつき
        //static let CONNECTION_POINT_PRESENT: Double = 0.8
        //プレゼントを送った時に取得できる(無料・有料関わらず)
        //static let CONNECTION_POINT_PRESENT_SEND: Int = 5
        //現在の絆レベルの経験値
        let connection_point_temp: Double = Util.CONNECTION_POINT_PRESENT * Double(coin)
        //加算される経験値
        let add_point:Int = Util.CONNECTION_POINT_PRESENT_SEND + Int(connection_point_temp)
        
        //反映後の絆レベルの経験値
        //let connection_exp_modify_after:Int = connection_exp + add_point
        
        //絆レベルの更新(値プラス or マイナス)
        //present_point : 送ったギフトポイント＝スター
        self.saveConnectLevelNew(user_id:user_id, target_user_id:cast_id, exp:add_point, live_count:live_count, present_point:star, flg:connection_exp_flg)
        
        //let strConnectBonusRate = UserDefaults.standard.double(forKey:"sendConnectBonusRate")
        
        //ペアランキング(課金ポイント)の更新・追加(更新後に何も処理をしない場合に使用)
        UtilFunc.savePairMonthRanking(user_id:user_id, cast_id:cast_id, exp:Int(coin * connection_bonus_rate))
        
        //配信レベル・配信ポイントを更新（１スターにつき１ポイント）
        //配信ポイント履歴にキャストが得た配信ポイントなどの履歴を保存する
        UtilFunc.writeLivePointRireki(type:live_point_type, cast_id:cast_id, user_id:user_id, point:live_point, minutes:minutes)

        //プレゼントで贈るスターをセット
        //let present_data = ["present_star": Int(self.presentList[selectRow].star)!]
        //self.conditionRef.updateChildValues(present_data)
        
        //キャストへスターの追加＞キャスト側で行う
        
        //絆レベルなど相手との情報を取得
        //UtilFunc.getConnectInfo(my_user_id:self.user_id, target_user_id:self.appDelegate.request_cast_id)
        //self.getConnectInfo()
        
        //ペアランキング(絆ランキング)の更新・追加(更新後に何も処理をしない場合に使用)
        //flg:1:値プラス、2:値マイナス
        //Util.savePairMonthRankingNew(user_id:self.user_id, cast_id:cell_user_id, exp:exp_temp, flg:1)
    }
     */
    
    //マイコレクションのステータス変更
    //status 1:有効 2:削除 3:保留
    static func modifyMycollectionStatusDo(userId:Int, castId:Int, fileName:String, status:Int){
        var stringUrl = Util.URL_MYCOLLECTION_UPDATE_STATUS
        stringUrl.append("?user_id=")
        stringUrl.append(String(userId))
        stringUrl.append("&cast_id=")
        stringUrl.append(String(castId))
        stringUrl.append("&file_name=")
        stringUrl.append(fileName)
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        
        print(stringUrl)
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    /*
    //予約フラグの更新
    //user_id:予約する人のID
    //peer_id:予約する人のPEER_ID
    //cast_id:対象のキャストID
    //status 0:会員登録中 1:待機中 2:通話中 3:ログオフ状態 4:通話中(予約申請) 5:通話中(予約済) 98:削除 99:リストア済み
    static func reserveDo(user_id:Int, peer_id:String, cast_id:Int, status:Int) {
        var stringUrl = Util.URL_RESERVE_DO
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&peer_id=")
        stringUrl.append(peer_id)
        stringUrl.append("&cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&status=")
        stringUrl.append(String(status))
        
        print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    */
    
    //photo_flgを更新する
    //photo_name(画像ファイル名、ただし拡張子は省く)
    static func modifyPhotoFlg(user_id:Int, photo_flg:Int, photo_name: String){
        var stringUrl = Util.URL_MODIFY_PHOTO_FLG
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&photo_flg=")
        stringUrl.append(String(photo_flg))
        stringUrl.append("&photo_name=")
        stringUrl.append(photo_name)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                dispatchGroup.leave()//サブタスク終了時に記述
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    //photo_background_flgを更新する
    //photo_background_name(画像ファイル名、ただし拡張子は省く)
    static func modifyPhotoBackgroundFlg(user_id:Int, photo_background_flg:Int, photo_background_name: String){
        var stringUrl = Util.URL_MODIFY_PHOTO_BACKGROUND_FLG
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&photo_background_flg=")
        stringUrl.append(String(photo_background_flg))
        stringUrl.append("&photo_background_name=")
        stringUrl.append(photo_background_name)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                dispatchGroup.leave()//サブタスク終了時に記述
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    /******************************/
    //画像・動画のアップロード(引数なし)
    /******************************/
    static func httpBody(_ fileAsData: Data, fileName: String) -> Data {
        let boundary = "WebKitFormBoundaryZLdHZy8HNaBmUX0d"
        var data = "--\(boundary)\r\n".data(using: .utf8)!
        // サーバ側が想定しているinput(type=file)タグのname属性値とファイル名をContent-Dispositionヘッダで設定
        data += "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!
        data += "Content-Type: image/jpeg\r\n".data(using: .utf8)!
        data += "\r\n".data(using: .utf8)!
        data += fileAsData
        data += "\r\n".data(using: .utf8)!
        data += "--\(boundary)--\r\n".data(using: .utf8)!
        
        return data
    }
    
    /******************************/
    //画像・動画のアップロード
    //POST:castId,userId
    /******************************/
    static func httpBodyAlpha(_ fileAsData: Data, fileName: String, castId: String, userId: String) -> Data {
        let boundary = "WebKitFormBoundaryZLdHZy8HNaBmUX0d"
        
        
        var data = "--\(boundary)\r\n".data(using: .utf8)!
        
        if(castId != "0"){
            // サーバ側が想定しているinput(type=file)タグのname属性値とファイル名をContent-Dispositionヘッダで設定
            data += "Content-Disposition: form-data; name=\"castId\"\r\n\r\n\(castId)\r\n".data(using: .utf8)!
            data += "--\(boundary)\r\n".data(using: .utf8)!
        }
        
        if(userId != "0"){
            // サーバ側が想定しているinput(type=file)タグのname属性値とファイル名をContent-Dispositionヘッダで設定
            data += "Content-Disposition: form-data; name=\"userId\"\r\n\r\n\(userId)\r\n".data(using: .utf8)!
            data += "--\(boundary)\r\n".data(using: .utf8)!
        }
        
        // サーバ側が想定しているinput(type=file)タグのname属性値とファイル名をContent-Dispositionヘッダで設定
        data += "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!
        
        /*
         name="「フォームデータ名」"\r\n
         \r\n
         フォームデータの本体\r\n
         
         ------WebKitFormBoundaryO5quBRiT4G7Vm3R7
         Content-Disposition: form-data; name="message"
         
         Hello
         */
        
        data += "Content-Type: image/jpeg\r\n".data(using: .utf8)!
        data += "\r\n".data(using: .utf8)!
        data += fileAsData
        data += "\r\n".data(using: .utf8)!
        data += "--\(boundary)--\r\n".data(using: .utf8)!
        
        return data
    }
    
    // リクエストを生成してアップロード
    static func fileUpload(_ url: URL, data: Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let boundary = "WebKitFormBoundaryZLdHZy8HNaBmUX0d"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // マルチパートでファイルアップロード
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let urlConfig = URLSessionConfiguration.default
        urlConfig.httpAdditionalHeaders = headers
        
        let session = Foundation.URLSession(configuration: urlConfig)
        let task = session.uploadTask(with: request, from: data, completionHandler: completionHandler)
        task.resume()
    }
    
    // リクエストを生成してアクセス（画像キャッシュを作成専用）
    static func createCachePhotoByUrl(user_id:Int, file_name:String) {
        var stringUrl = Util.URL_CREATE_CACHE_PHOTO_BY_URL
        stringUrl.append("?domain_base=")
        stringUrl.append(Util.DOMAIN_BASE)
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&file_name=")
        stringUrl.append(file_name)
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    // リクエストを生成してアクセス（画像キャッシュを作成専用）
    static func createCachePhotoBackgroundByUrl(user_id:Int, file_name:String) {
        var stringUrl = Util.URL_CREATE_CACHE_PHOTO_BACKGROUND_BY_URL
        stringUrl.append("?domain_base=")
        stringUrl.append(Util.DOMAIN_BASE)
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&file_name=")
        stringUrl.append(file_name)
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    // リクエストを生成してアクセス（動画キャッシュを作成専用）
    static func createCacheMovieByUrl(user_id:Int, file_name:String) {
        var stringUrl = Util.URL_CREATE_CACHE_MOVIE_BY_URL
        stringUrl.append("?domain_base=")
        stringUrl.append(Util.DOMAIN_BASE)
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&file_name=")
        stringUrl.append(file_name)
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
        }
        
        /*
         以下ではキャッシュが作成されない
         // create the url-request
         var request = URLRequest(url: URL(string: urlString)!)
         
         // set the method(HTTP-POST)
         request.httpMethod = "POST"
         // set the header(s)
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         request.addValue("s-maxage=86400, public", forHTTPHeaderField: "Cache-Control")
         
         let postString = "name=cache-create"
         request.httpBody = postString.data(using: .utf8)
         //request.HTTPBody = JSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
         //request.httpBody = JSONSerialization.data(withJSONObject: params)
         
         // use NSURLSessionDataTask
         let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
         print("response: \(response!)")
         
         //let phpOutput = String(data: data!, encoding: .utf8)!
         //print("php output: \(phpOutput)")
         })
         task.resume()
         */
    }
    
    /*
     static func fileAccess(_ url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
     let boundary = "WebKitFormBoundaryZLdHZy8HNaBmUX0d"
     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     
     // マルチパートでファイルアップロード
     //let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
     //let urlConfig = URLSessionConfiguration.default
     //urlConfig.httpAdditionalHeaders = headers
     
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     
     let postString = "name=cache-create"
     request.httpBody = postString.data(using: .utf8)
     
     
     let task = URLSession.shared.dataTask(with: request, completionHandler: {
     (data, response, error) in
     
     if error != nil {
     print(error)
     return
     }
     
     print("response: \(response!)")
     
     let phpOutput = String(data: data!, encoding: .utf8)!
     print("php output: \(phpOutput)")
     })
     task.resume()
     }*/
    
    //subviewを削除(tagが99のもののみ)
    static func removeSubviews(parentView: UIView){
        let subviews = parentView.subviews
        for subview in subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
    }
    
    //subviewを削除
    static func removeAllSubviews(parentView: UIView){
        let subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    /************************************/
    //シェア関連
    //str01 1行目
    //str02 2行目
    /************************************/
    static func shareDo(parentVC: UIViewController, parentView: UIView, url:String, str01: String, str02:String){
        let url = URL(string: url)!
        //let image:UIImage = ...
        //let shareItems:[Any] = [image,  "Hi!"]
        //let shareItems:[Any] = ["このアプリいいよ！", "monopol sample", url]
        let shareItems:[Any] = [str01, str02, url]
        let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            //UIActivityType.postToFacebook,
            //UIActivityType.postToTwitter,
            UIActivity.ActivityType.mail,
            //UIActivityType.markupAsPDF,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.print
        ]
        activityVC.excludedActivityTypes = excludedActivityTypes
        
        // 下記を追加する
        activityVC.modalPresentationStyle = .fullScreen
        
        //これがないとiPadではクラッシュ
        activityVC.popoverPresentationController?.sourceView = parentView
        parentVC.present(activityVC, animated: true, completion: nil)
        /*
         // シェアしてくれたかの判定
         activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
         guard completed else {
         return
         }
         // シェア対象の一覧
         let targets = [
         "com.apple.UIKit.activity.PostToTwitter",
         "com.apple.UIKit.activity.PostToFacebook",
         "jp.naver.line.Share"
         ]
         
         // シェアされた方法は対象の方法か判定
         if let type = activityType, targets.index(of: type.rawValue) != nil {
         // 対象の方法でシェアしてくれた、なにかしてあげる
         print("ありがとう！これあげる！")
         } else {
         // 対象外の方法でシェアされた
         print("TwitterかfacebookかLINEでシェアしてね！")
         }
         }
         */
        
        /*
         // シェアしてくれたかの判定
         activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
         guard completed else {
         return
         }
         // シェア対象の一覧
         let targets = [
         "com.apple.UIKit.activity.PostToTwitter",
         "com.apple.UIKit.activity.PostToFacebook",
         "jp.naver.line.Share"
         ]
         
         // シェアされた方法は対象の方法か判定
         if let type = activityType, targets.index(of: type.rawValue) != nil {
         // 対象の方法でシェアしてくれた、なにかしてあげる
         print("ありがとう！これあげる！")
         } else {
         // 対象外の方法でシェアされた
         print("TwitterかfacebookかLINEでシェアしてね！")
         }
         }
         */
    }
}
