//
//  SkywayManager.swift
//  swift_skyway
//
//  Created by onda on 2018/04/10.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import UIKit
import SkyWayRoom

private var instance: SkywayManager? = nil

protocol SkywaySessionDelegate: AnyObject {
    func sessionStart()
    func connectSucces()
    func remoteConnectSucces()
    func connectDisconnect()
    func connectEnd()
    func connectError()
}

class SkywayManager: NSObject {

    //API Key
    static let apiKey: String = "<あなたのID>"

    //Domain
    static let domain: String = "<あなたの指定したdomain>"

    private var room: Room?
    private var localMember: LocalRoomMember?
    private var roomPublications: [RoomPublication] = []
    private var roomSubscriptions: [RoomSubscription] = []
    private var localVideoStream: LocalVideoStream?
    private var localAudioStream: LocalAudioStream?
    private var localDataStream: LocalDataStream?
    private var remoteVideoStream: RemoteVideoStream?
    private var remoteAudioStream: RemoteAudioStream?
    private var remoteDataStream: RemoteDataStream?
    private var localVideoView: VideoView?
    private var remoteVideoView: VideoView?
    private weak var localContainerView: UIView?
    private weak var remoteContainerView: UIView?
    private var roomTask: Task<Void, Never>?
    private var roomClosed = false
    private var peerId: String = ""
    private var connectStart: Bool = false
    private var sessionDelegate: SkywaySessionDelegate?
    //private var roomType: RoomType = .P2P

    class func sharedManager() -> SkywayManager {
        if (instance == nil) {
            instance = SkywayManager()
        }
        return instance!
    }

    // MARK: Session
    func sessionStart(delegate: SkywaySessionDelegate) {
        sessionDelegate = delegate
        Task { @MainActor in
            do {
                try await Util.setupSkyWayRoomContextIfNeeded()
                if peerId.isEmpty {
                    peerId = UUID().uuidString
                }
                delegate.sessionStart()
            } catch {
                delegate.connectError()
            }
        }
    }

    func getPeerId() -> String {
        return peerId
    }

    public func setWaitLocal(localView: UIView, delegate: SkywaySessionDelegate) {
        sessionDelegate = delegate
        localContainerView = localView
        Task { @MainActor in
            await prepareLocalStreamsIfNeeded()
            attachLocalVideo()
        }
    }

    //通話開始要求
    public func connectStart(connectPeerId: String, delegate: SkywaySessionDelegate) {
        connectStart = true
        sessionDelegate = delegate
        roomClosed = false
        roomTask?.cancel()
        roomTask = Task { @MainActor in
            await leaveRoomIfNeeded()
            await joinRoomIfNeeded(roomName: connectPeerId, memberName: peerId)
        }
    }

    public func closeMedia(localView: UIView, remoteView: UIView) {
        localContainerView = localView
        remoteContainerView = remoteView
        connectStart = false
        roomClosed = true
        roomTask?.cancel()
        roomTask = nil
        Task { @MainActor in
            await cleanupRoomResources()
        }
        localDataStream = nil
        localAudioStream = nil
        localVideoStream = nil
        remoteVideoStream = nil
        remoteAudioStream = nil
        remoteDataStream = nil
        detachLocalVideo()
        detachRemoteVideo()
        sessionDelegate?.connectEnd()
    }

    public func sessionClose() {
        Task { @MainActor in
            await leaveRoomIfNeeded()
        }
    }

    func setRemoteView(remoteView: UIView) {
        remoteContainerView = remoteView
        attachRemoteVideo()
    }

    @MainActor
    private func joinRoomIfNeeded(roomName: String, memberName: String) async {
        guard roomClosed == false else { return }
        do {
            try await Util.setupSkyWayRoomContextIfNeeded()
            let roomOptions = Room.InitOptions()
            roomOptions.name = roomName
            let room = try await Room.findOrCreate(with: roomOptions)
            self.room = room
            let memberOptions = Room.MemberInitOptions()
            memberOptions.name = memberName
            let localMember = try await room.join(with: memberOptions)
            self.localMember = localMember
            attachRoomCallbacks(room: room, localMember: localMember)
            try await publishLocalStreams(localMember: localMember)
            sessionDelegate?.connectSucces()
        } catch {
            sessionDelegate?.connectError()
        }
    }

    @MainActor
    private func attachRoomCallbacks(room: Room, localMember: LocalRoomMember) {
        room.onPublicationPublished { [weak self] (publication: RoomPublication) in
            guard let self = self else { return }
            if publication.publisher.id == localMember.id {
                return
            }
            Task { @MainActor in
                await self.subscribeToPublication(publication, localMember: localMember)
            }
        }

        room.onMemberLeft { [weak self] (member: RoomMember) in
            guard let self = self else { return }
            if member.id != localMember.id {
                self.sessionDelegate?.connectDisconnect()
            }
        }
    }

    @MainActor
    private func publishLocalStreams(localMember: LocalRoomMember) async throws {
        await prepareLocalStreamsIfNeeded()
        if let localAudioStream = localAudioStream {
            roomPublications.append(try await localMember.publish(localAudioStream, options: RoomPublicationOptions()))
        }
        if let localVideoStream = localVideoStream {
            roomPublications.append(try await localMember.publish(localVideoStream, options: RoomPublicationOptions()))
        }
        if let localDataStream = localDataStream {
            roomPublications.append(try await localMember.publish(localDataStream, options: RoomPublicationOptions()))
        }
    }

    @MainActor
    private func prepareLocalStreamsIfNeeded() async {
        if localAudioStream == nil {
            localAudioStream = try? await LocalAudioStream.create()
        }
        if localVideoStream == nil {
            localVideoStream = try? await LocalVideoStream.create()
        }
        if localDataStream == nil {
            localDataStream = LocalDataStream()
        }
    }

    @MainActor
    private func subscribeToPublication(_ publication: RoomPublication, localMember: LocalRoomMember) async {
        do {
            let subscription = try await localMember.subscribe(publicationId: publication.id, options: SubscriptionOptions())
            roomSubscriptions.append(subscription)
            if let stream = subscription.stream as? RemoteVideoStream {
                remoteVideoStream = stream
                attachRemoteVideo()
                sessionDelegate?.remoteConnectSucces()
            } else if let stream = subscription.stream as? RemoteAudioStream {
                remoteAudioStream = stream
            } else if let stream = subscription.stream as? RemoteDataStream {
                remoteDataStream = stream
            }
        } catch {
            sessionDelegate?.connectError()
        }
    }

    @MainActor
    private func leaveRoomIfNeeded() async {
        if let localMember = localMember {
            await localMember.leave()
        }
        room = nil
        localMember = nil
        roomClosed = true
    }

    @MainActor
    private func cleanupRoomResources() async {
        guard let localMember = localMember else {
            roomSubscriptions.removeAll()
            roomPublications.removeAll()
            return
        }
        for subscription in roomSubscriptions {
            try? await localMember.unsubscribe(subscriptionId: subscription.id)
        }
        roomSubscriptions.removeAll()
        for publication in roomPublications {
            try? await localMember.unpublish(publication.id)
        }
        roomPublications.removeAll()
    }

    private func attachLocalVideo() {
        guard let localContainerView = localContainerView else { return }
        if localVideoView == nil {
            localVideoView = VideoView(frame: localContainerView.bounds)
            if let localVideoView = localVideoView {
                localVideoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                localContainerView.addSubview(localVideoView)
            }
        }
        if let localVideoStream = localVideoStream, let localVideoView = localVideoView {
            localVideoStream.attach(localVideoView)
        }
    }

    private func attachRemoteVideo() {
        guard let remoteContainerView = remoteContainerView else { return }
        if remoteVideoView == nil {
            remoteVideoView = VideoView(frame: remoteContainerView.bounds)
            if let remoteVideoView = remoteVideoView {
                remoteVideoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                remoteContainerView.addSubview(remoteVideoView)
            }
        }
        if let remoteVideoStream = remoteVideoStream, let remoteVideoView = remoteVideoView {
            remoteVideoStream.attach(remoteVideoView)
        }
    }

    private func detachLocalVideo() {
        if let localVideoView = localVideoView {
            localVideoStream?.detach(localVideoView)
        }
        localVideoView?.removeFromSuperview()
        localVideoView = nil
    }

    private func detachRemoteVideo() {
        if let remoteVideoView = remoteVideoView {
            remoteVideoStream?.detach(remoteVideoView)
        }
        remoteVideoView?.removeFromSuperview()
        remoteVideoView = nil
    }
}
