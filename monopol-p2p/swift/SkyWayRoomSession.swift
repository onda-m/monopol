//
//  SkyWayRoomSession.swift
//  swift_skyway
//
//  Created by OpenAI on 2025/09/11.
//

import Foundation
import SkyWayRoom
import UIKit

protocol SkyWayRoomSessionDelegate: AnyObject {
    @MainActor
    func roomSession(_ session: SkyWayRoomSession, didReceiveRemoteData data: Data)

    @MainActor
    func roomSession(_ session: SkyWayRoomSession, didReceiveRemoteVideo stream: RemoteVideoStream)

    @MainActor
    func roomSession(_ session: SkyWayRoomSession, didReceiveRemoteAudio stream: RemoteAudioStream)

    @MainActor
    func roomSessionDidOpenDataChannel(_ session: SkyWayRoomSession)
}

extension SkyWayRoomSessionDelegate {
    @MainActor
    func roomSession(_ session: SkyWayRoomSession, didReceiveRemoteVideo stream: RemoteVideoStream) {}

    @MainActor
    func roomSession(_ session: SkyWayRoomSession, didReceiveRemoteAudio stream: RemoteAudioStream) {}

    @MainActor
    func roomSessionDidOpenDataChannel(_ session: SkyWayRoomSession) {}
}

final class SkyWayRoomSession {
    enum Role {
        case caster
        case listener
    }

    enum State {
        case idle
        case connecting
        case connected
        case reconnecting
    }

}

final class SkyWayRoomSession {
    private static var contextTask: Task<Void, Error>?

    private(set) var room: Room?
    private(set) var localMember: LocalRoomMember?
    private(set) var publications: [RoomPublication] = []
    private(set) var subscriptions: [RoomSubscription] = []
    private(set) var localVideoStream: LocalVideoStream?
    private(set) var localAudioStream: LocalAudioStream?
    private(set) var localDataStream: LocalDataStream?
    private(set) var remoteVideoStream: RemoteVideoStream?
    private(set) var remoteAudioStream: RemoteAudioStream?
    private(set) var remoteDataStream: RemoteDataStream?
    private var roomClosed = false
    private(set) var role: Role?

    @MainActor
    private(set) var state: State = .idle

    weak var delegate: SkyWayRoomSessionDelegate?

    init(delegate: SkyWayRoomSessionDelegate? = nil) {
        self.delegate = delegate
    }

    func setupContextIfNeeded(token: String) async throws {
        if let task = Self.contextTask {
            try await task.value
            return
        }

        let task = Task {
            try await SkyWayRoom.Context.setup(withToken: token)
        }
        Self.contextTask = task
        try await task.value
    }

    @MainActor
    func start(roomName: String, token: String, role: Role, memberName: String? = nil, roomType: RoomType = .p2p) async throws {
        state = .connecting
        self.role = role
        roomClosed = false
        try await setupContextIfNeeded(token: token)
        let room = try await Room.findOrCreate(withName: roomName, type: roomType)
        self.room = room
        let resolvedMemberName = memberName ?? roomName
        let localMember = try await room.join(withName: resolvedMemberName)
        self.localMember = localMember
        attachRoomCallbacks(room: room, localMember: localMember)
        try await publishLocalStreams(localMember: localMember)
        state = .connected
    }

    @MainActor
    func stop() async {
        roomClosed = true
        state = .idle
    func joinRoom(name: String, memberName: String, token: String, roomType: RoomType = .p2p) async throws {
        roomClosed = false
        try await setupContextIfNeeded(token: token)
        let room = try await Room.findOrCreate(withName: name, type: roomType)
        self.room = room
        let localMember = try await room.join(withName: memberName)
        self.localMember = localMember
        attachRoomCallbacks(room: room, localMember: localMember)
        try await publishLocalStreams(localMember: localMember)
    }

    @MainActor
    func leaveRoom() async {
        roomClosed = true
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        publications.forEach { $0.cancel() }
        publications.removeAll()
        if let localMember = localMember {
            await localMember.leave()
        }
        room = nil
        localMember = nil
        localVideoStream = nil
        localAudioStream = nil
        localDataStream = nil
        remoteVideoStream = nil
        remoteAudioStream = nil
        remoteDataStream = nil
    }

    @MainActor
    func dispose() async {
        await stop()
        await leaveRoom()
        delegate = nil
    }

    @MainActor
    func attachLocalVideo(to videoView: VideoView) {
        localVideoStream?.attach(videoView)
    }

    @MainActor
    func attachRemoteVideo(to videoView: VideoView) {
        remoteVideoStream?.attach(videoView)
    }

    @MainActor
    func detachLocalVideo(from videoView: VideoView) {
        localVideoStream?.detach(videoView)
    }

    @MainActor
    func detachRemoteVideo(from videoView: VideoView) {
        remoteVideoStream?.detach(videoView)
    }

    @MainActor
    func markReconnecting() {
        state = .reconnecting
    }

    @MainActor
    func markConnected() {
        state = .connected
    }

    @MainActor
    var isConnected: Bool {
        state == .connected || state == .reconnecting
    }

    @MainActor
    private func attachRoomCallbacks(room: Room, localMember: LocalRoomMember) {
        room.onStreamPublished { [weak self] publication in
            guard let self = self else { return }
            if publication.publisher.id == localMember.id {
                return
            }
            Task { @MainActor in
                await self.subscribeToPublication(publication, localMember: localMember)
            }
        }
    }

    @MainActor
    private func publishLocalStreams(localMember: LocalRoomMember) async throws {
        await prepareLocalStreamsIfNeeded()
        if let localAudioStream = localAudioStream {
            publications.append(try await localMember.publish(localAudioStream))
        }
        if let localVideoStream = localVideoStream {
            publications.append(try await localMember.publish(localVideoStream))
        }
        if let localDataStream = localDataStream {
            publications.append(try await localMember.publish(localDataStream))
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
        guard roomClosed == false else { return }
        do {
            let subscription = try await localMember.subscribe(publication)
            subscriptions.append(subscription)
            if let stream = subscription.stream as? RemoteVideoStream {
                remoteVideoStream = stream
                delegate?.roomSession(self, didReceiveRemoteVideo: stream)
            } else if let stream = subscription.stream as? RemoteAudioStream {
                remoteAudioStream = stream
                delegate?.roomSession(self, didReceiveRemoteAudio: stream)
            } else if let stream = subscription.stream as? RemoteDataStream {
                remoteDataStream = stream
                delegate?.roomSessionDidOpenDataChannel(self)
            } else if let stream = subscription.stream as? RemoteAudioStream {
                remoteAudioStream = stream
            } else if let stream = subscription.stream as? RemoteDataStream {
                remoteDataStream = stream
                stream.onData { [weak self] data in
                    guard let self = self else { return }
                    Task { @MainActor in
                        self.delegate?.roomSession(self, didReceiveRemoteData: data)
                    }
                }
            }
        } catch {
            return
        }
    }
}

protocol SkyWayAttachableVideoView: AnyObject {}

extension VideoView: SkyWayAttachableVideoView {}

extension LocalVideoStream {
    func attach(_ videoView: VideoView) {
        addRenderer(videoView)
    }

    func detach(_ videoView: VideoView) {
        removeRenderer(videoView)
    }
}

extension RemoteVideoStream {
    func attach(_ videoView: VideoView) {
        addRenderer(videoView)
    }

    func detach(_ videoView: VideoView) {
        removeRenderer(videoView)
    }
}

final class SKWVideoView: VideoView {}
}
