//
//  UtilLog.swift
//  swift_skyway
//
//  Created by onda on 2018/10/22.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation

class UtilLog {
    /*
    //リリース時にログを出力しない様にする
    #if !DEBUG
    func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        // なにもしない
    }
    #endif
     */

    // リクエストを生成してアップロード
    //UtilLog.printf(str:"test")
    static func printf(str: String) {
        if(Util.FILE_MODE == 1){
            //自分のuser_idを指定
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            
            let url = URL(string: Util.URL_BASE + "logs/loggingDo.php")
            var request = URLRequest(url: url!)
            // POSTを指定
            request.httpMethod = "POST"
            // POSTするデータをBodyとして設定
            let string_temp = "user_id=" + String(user_id) + "&str=" + str
            request.httpBody = string_temp.data(using: .utf8)
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if error == nil, let data = data, let response = response as? HTTPURLResponse {
                    // HTTPヘッダの取得
                    print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                    // HTTPステータスコード
                    //print("statusCode: \(response.statusCode)")
                    print(String(data: data, encoding: .utf8) ?? "")
                }
                }.resume()
        }else if(Util.FILE_MODE == 2){
            //print(str)
        }else{
            //何もしない
        }
    }
}
