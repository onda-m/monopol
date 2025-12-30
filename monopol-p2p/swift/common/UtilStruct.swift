//
//  UtilStruct.swift
//  swift_skyway
//
//  Created by onda on 2019/04/28.
//  Copyright © 2019年 worldtrip. All rights reserved.
//

import Foundation

class UtilStruct {
    /**********************************************/
    //共通で使用
    /**********************************************/
    //メンテナンスフラグ取得用
    struct PubcodeResult: Codable {
        let value01: String//
        let value02: String//
        let value03: String//
        let value04: String//
        let value05: String//
    }
    struct ResultPubcodeJson: Codable {
        let count: Int
        let result: [PubcodeResult]
    }
    
    //ブラックリストの一覧用
    struct BlackResult: Codable {
        let from_user_id: String
        let to_user_id: String
        let ins_time: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
    }
    struct ResultBlackJson: Codable {
        let count: Int
        let result: [BlackResult]
    }
    
    //配信リクエスト未読数取得用
    struct LiveRequestNoreadResult: Codable {
        let request_noread_count: String
    }
    struct ResultLiveRequestNoreadJson: Codable {
        let count: Int
        let result: [LiveRequestNoreadResult]
    }
    
    //トークの未読数取得用
    struct NoreadResult: Codable {
        let noread_count: String
    }
    struct ResultNoreadJson: Codable {
        let count: Int
        let result: [NoreadResult]
    }
    
    //マイイベント数取得用
    struct MyEventCountResult: Codable {
        let my_event_count: String
    }
    struct ResultMyEventCountJson: Codable {
        let count: Int
        let result: [MyEventCountResult]
    }
    
    //親イベント取得用
    struct MyEventParentResult: Codable {
        let my_event_parent_id: String
        let from_year: String
        let from_month: String
        let from_day: String
    }
    struct ResultMyEventParentJson: Codable {
        let count: Int
        let result: [MyEventParentResult]
    }
    
    //フォロワーの一覧用
    //相互フォローを考慮する必要がある
    struct FollowerResult: Codable {
        let from_user_id: String
        let from_user_name: String
        let from_notice_type: String
        let from_notice_text: String
        let from_notice_rireki_id: String
        let from_notice_rireki_ins_time: String
        let value01: String//1:待機通知オン 2:待機通知オフ
        let mod_time: String
        let from_photo_flg: String
        let from_photo_name: String
        let each_other_flg: String//1 or 2:相互フォロー中
    }
    struct ResultFollowerJson: Codable {
        let count: Int
        let result: [FollowerResult]
    }
    
    //予約リストの取得用
    struct ReserveListResult: Codable {
        let id: String
        let cast_id: String
        let user_id: String
        let user_peer_id: String
        let wait_sec: String
        let reserve_user_name: String
        let reserve_photo_flg: String
        let reserve_photo_name: String
    }
    struct ResultReserveListJson: Codable {
        let count: Int
        let result: [ReserveListResult]
    }
    
    //ストリーマー待機時のタイムアウト対策
    struct StatusInfoResult: Codable {
        let login_status: String//
        let live_user_id: String//
    }
    struct ResultStatusInfoJson: Codable {
        let count: Int
        let result: [StatusInfoResult]
    }
    
    //ユーザー情報取得用
    struct UserResultTemp: Codable {
        let user_id: String
        let next_id: String
        let next_pass: String
        let uuid: String
        let fcm_token: String
        let notify_flg: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let photo_background_flg: String
        let photo_background_name: String
        let movie_flg: String
        let movie_name: String
        let sns_userid01: String//LineのユーザーID
        let sns_userid02: String//AppleのユーザーID
        let sns_userid03: String//未使用
        let value01: String//性別
        let value02: String//フォロワー数
        let value03: String//フォロー数
        let value04: String//報酬一覧のWebViewの表示・非表示フラグ
        //let value05: String//未使用
        let mycollection_max: String//マイコレクションのMAX値
        let point: String//所有しているポイント(coin)
        let point_pay: String
        let point_free: String
        let live_point: String//配信ポイント(リストのトップに表示する配信ポイント、別紙ロジック参照)
        let watch_level: String//視聴レベル
        let live_level: String//配信レベル
        let cast_rank: String//1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
        let cast_official_flg: String//1:公式
        let cast_month_ranking: String//キャスト月間ランキング
        let cast_month_ranking_point: String//キャスト月間ランキングポイント
        let twitter: String//
        let facebook: String//
        let instagram: String//
        let homepage: String//
        let freetext: String//
        let official_read_flg: String//1:未読
        let notice_text: String//
        let live_total_count: String//
        let live_total_sec: String//
        let live_total_star: String//
        let live_now_star: String//
        let payment_request_star: String//
        let login_status: String//
        let live_user_id: String//
        let reserve_user_id: String//
        let reserve_flg: String//
        let max_reserve_count: String//
        let first_flg01: String//
        let first_flg02: String//
        let first_flg03: String//
        //let login_time: String//
        //let ins_time: String//
        let bank_info01: String//
        let bank_info02: String//
        let bank_info03: String//
        let bank_info04: String//
        let bank_info05: String//
        let last_star_get_time: String//
        let pub_rank_name: String//
        let pub_get_live_point: String//
        let pub_ex_get_live_point: String//
        let pub_coin: String//
        let pub_ex_coin: String//
        let pub_min_reserve_coin: String//
        //let cancel_coin: String//
        //let cancel_get_star: String//
        //個別設定用
        let ex_live_sec: String//
        let ex_get_live_point: String//
        let ex_ex_get_live_point: String//
        let ex_coin: String//
        let ex_ex_coin: String//
        let ex_min_reserve_coin: String//
        let ex_status: String//
    }
    struct ResultJsonTemp: Codable {
        let count: Int
        let result: [UserResultTemp]
    }
    
    //ユーザー情報取得用(ランク以外を取得用)
    struct UserResultTempNoRank: Codable {
        let user_id: String
        let next_id: String
        let next_pass: String
        let uuid: String
        let fcm_token: String
        let notify_flg: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let photo_background_flg: String
        let photo_background_name: String
        let movie_flg: String
        let movie_name: String
        let sns_userid01: String//LineのユーザーID
        let sns_userid02: String//AppleのユーザーID
        let sns_userid03: String//未使用
        let value01: String//性別
        let value02: String//フォロワー数
        let value03: String//フォロー数
        let value04: String//報酬一覧のWebViewの表示・非表示フラグ
        //let value05: String//未使用
        let mycollection_max: String//マイコレクションのMAX値
        let point: String//所有しているポイント(coin)
        let point_pay: String
        let point_free: String
        let live_point: String//配信ポイント(リストのトップに表示する配信ポイント、別紙ロジック参照)
        let watch_level: String//視聴レベル
        let live_level: String//配信レベル
        let cast_rank: String//1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
        let cast_official_flg: String//1:公式
        let cast_month_ranking: String//キャスト月間ランキング
        let cast_month_ranking_point: String//キャスト月間ランキングポイント
        let twitter: String//
        let facebook: String//
        let instagram: String//
        let homepage: String//
        let freetext: String//
        let official_read_flg: String//1:未読
        let notice_text: String//
        let live_total_count: String//
        let live_total_sec: String//
        let live_total_star: String//
        let live_now_star: String//
        let payment_request_star: String//
        let login_status: String//
        let live_user_id: String//
        let reserve_user_id: String//
        let reserve_flg: String//
        let max_reserve_count: String//
        let first_flg01: String//
        let first_flg02: String//
        let first_flg03: String//
        //let login_time: String//
        //let ins_time: String//
        let bank_info01: String//
        let bank_info02: String//
        let bank_info03: String//
        let bank_info04: String//
        let bank_info05: String//
        //let last_star_get_time: String//
        let ins_time: String
        //個別設定用
        let ex_live_sec: String//
        let ex_get_live_point: String//
        let ex_ex_get_live_point: String//
        let ex_coin: String//
        let ex_ex_coin: String//
        let ex_min_reserve_coin: String//
        let ex_status: String//
    }
    struct ResultJsonTempNoRank: Codable {
        let count: Int
        let result: [UserResultTempNoRank]
    }
    
    /**********************************************/
    //ストリーマー側で使用
    /**********************************************/
    //ストリーマーでライブ時に使用
    /*
    //予約申請時用
    struct ReserveInfoResult: Codable {
        let reserve_user_id: String
        let reserve_peer_id: String
        let reserve_user_name: String
        let reserve_photo_flg: String
        let reserve_photo_name: String
        let reserve_flg: String
        let reserve_status: String
    }
    struct ResultReserveInfoJson: Codable {
        let count: Int
        let result: [ReserveInfoResult]
    }*/
    
    //リクエスト履歴の一覧用
    struct RequestRirekiResult: Codable {
        let type: String
        let listener_user_id: String
        let year: String
        let month: String
        let day: String
        let request_status: String//リクエストの結果(そのままかライブまで行ったかなど)
        let value01: String//未使用
        let status: String//
        let ins_time: String//
        let mod_time: String//
        let listener_user_name: String//
        let listener_photo_flg: String//
        let listener_photo_name: String//
    }
    struct ResultRequestRirekiJson: Codable {
        let count: Int
        let result: [RequestRirekiResult]
    }
    
    //ストリーマー側でライブ時に使用
    //予約数の取得用
    struct ReserveCountResult: Codable {
        let reserve_count: String
    }
    struct ResultReserveCountJson: Codable {
        let count: Int
        let result: [ReserveCountResult]
    }

    //ストリーマー側でライブ時に使用
    //エフェクトフラグ取得用(キャスト側では、待機が完了したタイミングで一度だけDBから取得する)
    struct EffectResult: Codable {
        let effect_flg01: String//
        let effect_flg02: String//
        let effect_flg03: String//
    }
    struct ResultEffectJson: Codable {
        let count: Int
        let result: [EffectResult]
    }
    
    //ストリーマー側でライブ時に使用
    struct ScreenshotResult: Codable {
        let id: String
        let user_id: String
        let file_name: String
        let value01: String
        let value02: String
        let value03: String
        let value04: String
        let value05: String
        let status: String
        let ins_time: String
        let mod_time: String
    }
    struct ScreenshotResultJson: Codable {
        let count: Int
        let result: [ScreenshotResult]
    }
    
    //リスナー情報取得用
    struct UserResultMin: Codable {
        let user_id: String
        let uuid: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        //let login_status: String//
        //let login_time: String//
        //let ins_time: String//
        let connect_level: String//
        //let connect_live_count: String//
        //let connect_present_point: String//
        //let black_list_id: String//ブラックリストに入っている場合はゼロ以外が入る
    }
    struct ResultJsonMin: Codable {
        let count: Int
        let result: [UserResultMin]
    }
    
    /*
    //プレゼントの取得用
    struct PresentResult: Codable {
        let present_id: String
        let present_name: String
        let coin: String
        let star: String
        let live_point: String
        let photo_flg: String
    }
    struct ResultPresentJson: Codable {
        let count: Int
        let result: [PresentResult]
    }
     */
    
    /**********************************************/
    //リスナー側で使用
    /**********************************************/
    //ストリーマー一覧取得用
    struct UserListResult: Codable {
        let user_id: String
        let notify_flg: String
        let uuid: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let photo_background_flg: String
        let photo_background_name: String
        let movie_flg: String
        let movie_name: String
        let value02: String//フォロワー数
        let value03: String//フォロー数
        let value06: String//直前イベントフラグ　1:直前イベントあり
        let watch_level: String
        let live_level: String
        let cast_rank: String//1:フリー 2:有料
        let cast_official_flg: String//1:公式
        let cast_month_ranking_point: String//月間ランキングポイント
        let freetext: String
        let live_password: String
        let login_status: String
        let live_user_id: String
        let reserve_user_id: String
        let reserve_flg: String
        let max_reserve_count: String
        let effect_flg02: String//1:イベント表示あり
        let first_flg01: String//
        let first_flg02: String//
        let first_flg03: String//
        //let login_time: String//
        //let ins_time: String//
        let bank_info01: String//銀行メモで使用？
        let bank_info02: String//イベントフラグ１
        let bank_info03: String//イベントフラグ２
        let bank_info04: String//イベントフラグ３
        let bank_info05: String//イベントフラグ４
        let ins_time: String
        let user_follow_id: String//followしている場合はその人のuser_id
        //個別設定用
        let ex_live_sec: String
        let ex_get_live_point: String
        let ex_ex_get_live_point: String
        let ex_coin: String
        let ex_ex_coin: String
        let ex_min_reserve_coin: String
        let ex_status: String
    }
    struct ResultUserListJson: Codable {
        let count: Int
        let result: [UserListResult]
    }
    
    //選択したキャストと現在ライブ中のリスナー情報取得用（主に現在のコイン数）
    struct UserLiveNowResult: Codable {
        let user_name: String
        let point: String
    }
    struct ResultUserLiveNowJson: Codable {
        let count: Int
        let result: [UserLiveNowResult]
    }
    
    //予約申請時のチェック用(MAXの予約数)
    //視聴時のキャスト情報の格納用
    struct CastInfoResult: Codable {
        let login_status: String//
        let live_user_id: String//
        let reserve_user_id: String//
        let reserve_peer_id: String//
        let reserve_flg: String//
        let max_reserve_count: String//
        let now_reserve_have: String//
    }
    struct ResultCastInfoJson: Codable {
        let count: Int
        let result: [CastInfoResult]
    }
    
    //１回目,２回目を0.5秒間隔くらいで取得し、両方ともゼロの時だけ処理実行する
    //ロック情報数取得用（１回目）
    struct LockResult: Codable {
        let lock_count: String
    }
    struct ResultLockJson: Codable {
        let count: Int
        let result: [LockResult]
    }
    
    //プレゼントの取得用
    struct PresentResult: Codable {
        let present_id: String
        let present_name: String
        let coin: String
        let star: String
        let live_point: String
        let photo_flg: String
        let status: String
        let present_count: String
    }
    struct ResultPresentJson: Codable {
        let count: Int
        let result: [PresentResult]
    }
    
    //ストリーマーの情報格納用
    struct UserResult: Codable {
        let user_id: String
        let uuid: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let value01: String//性別
        let value02: String//フォロワー数
        let value03: String//フォロー数
        //let value04: String//未使用
        //let value05: String//未使用
        let point: String//所有しているポイント
        let live_point: String//配信ポイント
        let watch_level: String//視聴レベル
        let live_level: String//配信レベル
        let cast_rank: String//1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
        let cast_official_flg: String//1:公式
        let cast_month_ranking: String//キャスト月間ランキング
        let cast_month_ranking_point: String//キャスト月間ランキングポイント
        let twitter: String//
        let facebook: String//
        let instagram: String//
        let homepage: String//
        let freetext: String//
        let notice_text: String//
        let live_total_count: String//累計配信数
        //let login_status: String//
        //let login_time: String//
        //let ins_time: String//
        let connect_level: String//
        let connect_exp: String//
        let connect_live_count: String//
        let connect_present_point: String//
        let black_list_id: String//ブラックリストに入っている場合はゼロ以外が入る
    }
    struct ResultJson: Codable {
        let count: Int
        let result: [UserResult]
    }
    
    //ストリーマーの情報格納用（無料・有料の判断用）
    struct UserFreeResult: Codable {
        let live_level: String//配信レベル
        let cast_rank: String//1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
        let ex_live_sec: String//無料・有料ストリーマーの判断用
    }
    struct ResultFreeJson: Codable {
        let count: Int
        let result: [UserFreeResult]
    }
    
    //イベントの価格設定リスト用
    struct EventStarPriceResult: Codable {
        let id: String
        let star: String
        let price: String
        let value01: String//プルダウンへの表示文字列
        let order_cd: String//プルダウンへの表示順
        let status: String//
    }
    struct ResultEventStarPriceJson: Codable {
        let count: Int
        let result: [EventStarPriceResult]
    }
}
