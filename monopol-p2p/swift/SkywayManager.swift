//
//  SkywayManager.swift
//  swift_skyway
//
//  Created by onda on 2018/04/10.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import UIKit
import SkyWay
import AVFoundation

private var instance:SkywayManager? = nil

class SkywayManager: NSObject {
    
    //API Key
    static let apiKey:String = "<あなたのID>"
    
    //Domain
    static let domain:String = "<あなたの指定したdomain>"
    
    //Peer
    private var peer:SKWPeer? = nil
    private var localStream:SKWMediaStream? = nil
    
    private var remoteStream:SKWMediaStream? = nil
    private var mediaConnection:SKWMediaConnection? = nil
    private var conected:Bool = false
    private var peerId: String!
    private var connectStart:Bool = false;
    private var sessionDelegate:SkywaySessionDelegate?
    
    class func sharedManager() -> SkywayManager{
        
        if (instance == nil) {
            instance = SkywayManager()
            instance!.configInit()
        }
        
        return instance!
    }
    
    // MARK: Session
    func sessionStart(delegate:SkywaySessionDelegate) {
        sessionDelegate = nil
        sessionDelegate = delegate
        
        //Initialize SkyWay Peer
        let option:SKWPeerOption = SKWPeerOption.init()
        option.key = SkywayManager.apiKey
        option.domain = SkywayManager.domain
        
        //Peer初期化
        peer = SKWPeer(options: option)
        setCallbacks()
    }
    
    func getPeerId()->String {
        return peerId
    }
    
    // MARK: callbacks
    private func setCallbacks(){
        
        peer!.on(.PEER_EVENT_OPEN, callback: {obj in
            if obj is NSString{
                print("peer onopen")
                self.peerId = obj as! String!
                
                guard let delegate:SkywaySessionDelegate = self.sessionDelegate else {
                    return
                }
                
                delegate.sessionStart()
            }
        })
        
        //PeerServerへの接続が確立すると発生
        peer!.on(.PEER_EVENT_CALL, callback: {obj in
            print("peer call")
            
            if let connection = obj as? SKWMediaConnection{
                self.mediaConnection = connection
                self.setMediaCallbacks(media: self.mediaConnection)
                self.mediaConnection!.answer(self.localStream!)
                
                
                guard let delegate:SkywaySessionDelegate = self.sessionDelegate else {
                    return
                }
                
                delegate.connectSucces()
            }
        })
        
        peer!.on(.PEER_EVENT_CLOSE, callback: {obj in
            print("peer close")
            
            guard let delegate:SkywaySessionDelegate = self.sessionDelegate else {
                return
            }
            
            delegate.connectEnd()
        })
        
        peer!.on(.PEER_EVENT_DISCONNECTED, callback: {obj in
            print("peer disconnected")
            
            guard let delegate:SkywaySessionDelegate = self.sessionDelegate else {
                return
            }
            
            delegate.connectDisconnect()
        })
        
        peer!.on(.PEER_EVENT_ERROR, callback: {obj in
            print("peer error")
            
            guard let delegate:SkywaySessionDelegate = self.sessionDelegate else {
                return
            }
            
            delegate.connectError()
        })
    }
    
    public func setWaitLocal(localView:SKWVideo, delegate:SkywaySessionDelegate) {
        sessionDelegate = nil
        sessionDelegate = delegate
        
        //初期化
        SKWNavigator.initialize(peer)
        let bounds = UIScreen.main.nativeBounds
        let constraints = SKWMediaConstraints()
        constraints.maxFrameRate = 10
        constraints.cameraMode = .CAMERA_MODE_ADJUSTABLE
        constraints.cameraPosition = .CAMERA_POSITION_FRONT
        constraints.minWidth = UInt(bounds.width)
        constraints.minHeight = UInt(bounds.height / 2)
        
        self.localStream = SKWNavigator.getUserMedia(constraints)
        
        
        //localViewに設定する
        localView.addSrc(self.localStream, track: 0)
        localView.setNeedsDisplay()
    }
    
    
    //通話開始要求
    public func connectStart(connectPeerId:String, delegate:SkywaySessionDelegate) {
        
        connectStart = true
        sessionDelegate = delegate
        mediaConnection = peer!.call(withId: connectPeerId, stream: localStream)
        
        self.setMediaCallbacks(media: self.mediaConnection)
    }
    
    public func closeMedia(localView:SKWVideo, remoteView:SKWVideo) {
        conected = false
        connectStart = false
        
        if mediaConnection != nil{
            mediaConnection!.close()
            mediaConnection!.on(.MEDIACONNECTION_EVENT_STREAM, callback: nil)
            mediaConnection!.on(.MEDIACONNECTION_EVENT_CLOSE, callback: nil)
            mediaConnection!.on(.MEDIACONNECTION_EVENT_ERROR, callback: nil)
            mediaConnection = nil
        }
        
        if remoteStream != nil {
            remoteView.removeSrc(remoteStream, track: 0)
            remoteStream!.close()
            remoteStream = nil
        }
        
        if localStream != nil {
            localView.removeSrc(localStream, track: 0)
            localStream!.close()
            localStream = nil
        }
        
        
        
        guard let delegate:SkywaySessionDelegate = self.sessionDelegate else {
            return
        }
        
        
        delegate.connectEnd()
    }
    
    
    public func sessionClose() {
        
        peer!.on(.PEER_EVENT_OPEN, callback: nil)
        peer!.on(.PEER_EVENT_CLOSE, callback: nil)
        peer!.on(.PEER_EVENT_CALL, callback: nil)
        peer!.on(.PEER_EVENT_DISCONNECTED, callback: nil)
        peer!.on(.PEER_EVENT_ERROR, callback: nil)
        
        SKWNavigator.terminate()
        
        peer!.destroy()
        peer = nil
    }
    
    func setRemoteView(remoteView:SKWVideo) {
        conected = true
        remoteView.addSrc(self.remoteStream, track: 0)
    }
    
    private func setMediaCallbacks(media: SKWMediaConnection?){
        
        guard let connection = media else {
            return
        }
        
        connection.on(.MEDIACONNECTION_EVENT_STREAM, callback: {obj in
            print("media stream")
            if let stream = obj as? SKWMediaStream{
                self.dispatch_async_global {
                    self.remoteStream = stream
                    
                    guard let delegate:SkywaySessionDelegate = self.sessionDelegate else {
                        return
                    }
                    
                    delegate.remoteConnectSucces()
                }
            }
        })
        
        connection.on(.MEDIACONNECTION_EVENT_CLOSE, callback: {obj in
            print("media close")
            
            guard let delegate:SkywaySessionDelegate = self.sessionDelegate else {
                return
            }
            
            delegate.connectDisconnect()
        })
        
        connection.on(.MEDIACONNECTION_EVENT_ERROR, callback: {obj in
            print("media error")
        })
    }
}
