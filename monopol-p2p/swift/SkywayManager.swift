//
//  SkywayManager.swift
//  swift_skyway
//
//  Created by onda on 2018/04/10.
//  Updated to stabilize SkyWay Room SDK handling.
//

import Foundation
import UIKit
import SkyWaySupport
import AVFoundation

protocol SkywaySessionDelegate: AnyObject {
    func skywayManagerDidOpenPeer(_ manager: SkywayManager, peerId: String)
    func skywayManagerDidJoinRoom(_ manager: SkywayManager, roomName: String)
    func skywayManagerDidLeaveRoom(_ manager: SkywayManager)
    func skywayManager(_ manager: SkywayManager, didUpdateRemoteStream stream: SKWMediaStream, peerId: String)
    func skywayManager(_ manager: SkywayManager, didRemoveRemoteStreamFor peerId: String)
    func skywayManager(_ manager: SkywayManager, didReceiveError error: Error?)
}

enum SkywayConfigurationError: LocalizedError {
    case missingCredentials

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "SkyWay API Key または Domain が設定されていません。新SkyWayのコンソールで発行した値を設定してください。"
        }
    }
}

extension SkywaySessionDelegate {
    func skywayManagerDidOpenPeer(_ manager: SkywayManager, peerId: String) {}
    func skywayManagerDidJoinRoom(_ manager: SkywayManager, roomName: String) {}
    func skywayManagerDidLeaveRoom(_ manager: SkywayManager) {}
    func skywayManager(_ manager: SkywayManager, didUpdateRemoteStream stream: SKWMediaStream, peerId: String) {}
    func skywayManager(_ manager: SkywayManager, didRemoveRemoteStreamFor peerId: String) {}
    func skywayManager(_ manager: SkywayManager, didReceiveError error: Error?) {}
}

final class SkywayManager: NSObject {

    // API Key
    static let apiKey: String = "<あなたのID>"

    // Domain
    static let domain: String = "<あなたの指定したdomain>"

    static let shared = SkywayManager()

    private let callbackQueue = DispatchQueue(label: "skyway.manager.queue", qos: .userInitiated)
    private weak var delegate: SkywaySessionDelegate?

    private var peer: SKWPeer?
    private var room: SKWRoom?
    private(set) var localStream: SKWMediaStream?
    private(set) var peerId: String?
    private var remoteStreams: [String: SKWMediaStream] = [:]
    private var remoteStreamIds: [ObjectIdentifier: String] = [:]

    private override init() {
        super.init()
    }

    // MARK: Session
    func startSession(delegate: SkywaySessionDelegate, apiKey: String? = nil, domain: String? = nil) {
        self.delegate = delegate

        guard peer == nil else {
            return
        }

        let resolvedApiKey = (apiKey ?? SkywayManager.apiKey).trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedDomain = (domain ?? SkywayManager.domain).trimmingCharacters(in: .whitespacesAndNewlines)

        guard !resolvedApiKey.isEmpty, !resolvedDomain.isEmpty else {
            notifyDelegate { $0.skywayManager(self, didReceiveError: SkywayConfigurationError.missingCredentials) }
            return
        }

        let option = SKWPeerOption()
        option.key = resolvedApiKey
        option.domain = resolvedDomain

        let peer = SKWPeer(options: option)
        self.peer = peer
        setPeerCallbacks(for: peer)
    }

    func endSession() {
        leaveRoom()
        callbackQueue.async { [weak self] in
            guard let self = self else { return }

            self.localStream?.close()
            self.localStream = nil

            self.peer?.destroy()
            self.peer = nil

            SKWNavigator.terminate()
        }
    }

    // MARK: Local stream
    @discardableResult
    func prepareLocalStream(in localView: SKWVideo?, constraints: SKWMediaConstraints? = nil) -> SKWMediaStream? {
        callbackQueue.sync {
            guard peer != nil else {
                notifyDelegate { $0.skywayManager(self, didReceiveError: nil) }
                return nil
            }

            SKWNavigator.initialize(peer)

            let mediaConstraints = constraints ?? defaultConstraints()
            localStream?.close()
            localStream = SKWNavigator.getUserMedia(mediaConstraints)

            if let stream = localStream, let videoView = localView {
                DispatchQueue.main.async {
                    videoView.addSrc(stream, track: 0)
                    videoView.setNeedsDisplay()
                }
            }

            return localStream
        }
    }

    // MARK: Room handling
    func joinRoom(named roomName: String, optionBuilder: ((SKWRoomOption) -> Void)? = nil) {
        callbackQueue.async { [weak self] in
            guard let self = self, let peer = self.peer else { return }

            let roomOption = SKWRoomOption()
            roomOption.stream = self.localStream
            optionBuilder?(roomOption)

            self.room?.close()
            self.room = peer.joinRoom(withName: roomName, options: roomOption)

            guard let room = self.room else {
                self.notifyDelegate { $0.skywayManager(self, didReceiveError: nil) }
                return
            }

            self.setRoomCallbacks(room: room, roomName: roomName)
        }
    }

    func leaveRoom() {
        callbackQueue.async { [weak self] in
            guard let self = self else { return }
            self.room?.close()
            self.room = nil
            self.clearRemoteStreams()
            self.notifyDelegate { $0.skywayManagerDidLeaveRoom(self) }
        }
    }

    // MARK: Helpers
    private func defaultConstraints() -> SKWMediaConstraints {
        let constraints = SKWMediaConstraints()
        let bounds = UIScreen.main.nativeBounds
        constraints.maxFrameRate = 15
        constraints.cameraMode = .CAMERA_MODE_ADJUSTABLE
        constraints.cameraPosition = .CAMERA_POSITION_FRONT
        constraints.minWidth = UInt(bounds.width)
        constraints.minHeight = UInt(bounds.height / 2)
        return constraints
    }

    private func setPeerCallbacks(for peer: SKWPeer) {
        peer.on(.PEER_EVENT_OPEN, callback: { [weak self] obj in
            guard let self = self, let id = obj as? String else { return }
            self.peerId = id
            self.notifyDelegate { $0.skywayManagerDidOpenPeer(self, peerId: id) }
        })

        peer.on(.PEER_EVENT_DISCONNECTED, callback: { [weak self, weak peer] _ in
            peer?.reconnect()
            guard let self = self else { return }
            self.notifyDelegate { $0.skywayManager(self, didReceiveError: nil) }
        })

        peer.on(.PEER_EVENT_CLOSE, callback: { [weak self] _ in
            self?.handlePeerClosed()
        })

        peer.on(.PEER_EVENT_ERROR, callback: { [weak self] obj in
            guard let self = self else { return }
            self.notifyDelegate { $0.skywayManager(self, didReceiveError: obj as? Error) }
        })
    }

    private func setRoomCallbacks(room: SKWRoom, roomName: String) {
        room.on(.ROOM_EVENT_OPEN, callback: { [weak self] _ in
            guard let self = self else { return }
            self.notifyDelegate { $0.skywayManagerDidJoinRoom(self, roomName: roomName) }
        })

        room.on(.ROOM_EVENT_STREAM, callback: { [weak self] obj in
            guard let self = self, let stream = obj as? SKWMediaStream else { return }
            let remotePeerId = stream.peerId ?? UUID().uuidString
            let streamKey = ObjectIdentifier(stream)
            self.remoteStreams[remotePeerId] = stream
            self.remoteStreamIds[streamKey] = remotePeerId
            self.notifyDelegate { $0.skywayManager(self, didUpdateRemoteStream: stream, peerId: remotePeerId) }
        })

        room.on(.ROOM_EVENT_REMOVE_STREAM, callback: { [weak self] obj in
            guard let self = self, let stream = obj as? SKWMediaStream else { return }
            let streamKey = ObjectIdentifier(stream)
            if let remotePeerId = stream.peerId ?? self.remoteStreamIds[streamKey] {
                self.remoteStreams.removeValue(forKey: remotePeerId)
                self.remoteStreamIds.removeValue(forKey: streamKey)
                self.notifyDelegate { $0.skywayManager(self, didRemoveRemoteStreamFor: remotePeerId) }
            }
        })

        room.on(.ROOM_EVENT_CLOSE, callback: { [weak self] _ in
            self?.leaveRoom()
        })

        room.on(.ROOM_EVENT_ERROR, callback: { [weak self] obj in
            guard let self = self else { return }
            self.notifyDelegate { $0.skywayManager(self, didReceiveError: obj as? Error) }
        })
    }

    private func handlePeerClosed() {
        clearRemoteStreams()
        notifyDelegate { $0.skywayManagerDidLeaveRoom(self) }
    }

    private func clearRemoteStreams() {
        remoteStreams.values.forEach { $0.close() }
        remoteStreams.removeAll()
        remoteStreamIds.removeAll()
    }

    private func notifyDelegate(_ action: @escaping (SkywaySessionDelegate) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let delegate = self?.delegate else { return }
            action(delegate)
        }
    }
}
