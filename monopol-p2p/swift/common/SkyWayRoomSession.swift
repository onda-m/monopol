import Foundation
import SkyWayRoom

final class SkyWayRoomSession {
    enum SessionError: Error {
        case missingRoom
        case missingLocalMember
        case roomOverCapacity
    }

    private(set) var room: Room?
    private(set) var localMember: LocalRoomMember?
    private(set) var localVideoStream: LocalVideoStream?
    private(set) var localAudioStream: LocalAudioStream?
    private(set) var localDataStream: LocalDataStream?

    private(set) var remoteVideoStream: RemoteVideoStream?
    private(set) var remoteAudioStream: RemoteAudioStream?
    private(set) var remoteDataStream: RemoteDataStream?

    private var subscriptions: [Subscription] = []

    var onRoomJoined: (() -> Void)?
    var onRoomLeft: (() -> Void)?
    var onRemoteVideoStream: ((RemoteVideoStream) -> Void)?
    var onRemoteAudioStream: ((RemoteAudioStream) -> Void)?
    var onRemoteData: ((String) -> Void)?
    var onError: ((Error) -> Void)?
    var onMemberCountExceeded: (() -> Void)?
    var onDataStreamReady: (() -> Void)?
    var onRemoteMemberJoined: (() -> Void)?
    var onRemoteMemberLeft: (() -> Void)?

    func join(roomName: String, memberName: String) {
        Task {
            do {
                let room = try await findOrCreateRoom(named: roomName)
                let member = try await room.join(with: RoomMemberInit(name: memberName))
                self.room = room
                self.localMember = member

                setupRoomCallbacks(room: room)
                ensureRoomCapacity()
                try await prepareLocalStreams()
                try await publishLocalStreams()
                subscribeToExistingPublications()

                DispatchQueue.main.async {
                    self.onRoomJoined?()
                }
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error)
                }
            }
        }
    }

    func leave() {
        Task {
            do {
                try await localMember?.leave()
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error)
                }
            }
            cleanup()
            DispatchQueue.main.async {
                self.onRoomLeft?()
            }
        }
    }

    func send(text: String) {
        guard let dataStream = localDataStream else { return }
        if let data = text.data(using: .utf8) {
            dataStream.write(data: data)
        }
    }

    func setLocalAudioEnabled(_ enabled: Bool) {
        localAudioStream?.setEnabled(enabled)
    }

    func setLocalVideoEnabled(_ enabled: Bool) {
        localVideoStream?.setEnabled(enabled)
    }

    func setRemoteAudioEnabled(_ enabled: Bool) {
        remoteAudioStream?.setEnabled(enabled)
    }

    private func findOrCreateRoom(named roomName: String) async throws -> Room {
        if let existing = try await Room.find(byName: roomName, type: .p2p) {
            return existing
        }
        return try await Room.create(name: roomName, type: .p2p)
    }

    private func prepareLocalStreams() async throws {
        if localVideoStream == nil {
            localVideoStream = try await LocalVideoStream.create(camera: .front)
        }
        if localAudioStream == nil {
            localAudioStream = try await LocalAudioStream.create()
        }
        if localDataStream == nil {
            localDataStream = LocalDataStream()
        }
    }

    private func publishLocalStreams() async throws {
        guard let member = localMember else { throw SessionError.missingLocalMember }

        if let localVideoStream = localVideoStream {
            _ = try await member.publish(localVideoStream)
        }
        if let localAudioStream = localAudioStream {
            _ = try await member.publish(localAudioStream)
        }
        if let localDataStream = localDataStream {
            _ = try await member.publish(localDataStream)
        }
    }

    private func setupRoomCallbacks(room: Room) {
        room.onMemberJoinedHandler = { [weak self] _ in
            self?.ensureRoomCapacity()
            DispatchQueue.main.async {
                self?.onRemoteMemberJoined?()
            }
        }

        room.onMemberLeftHandler = { [weak self] _ in
            self?.ensureRoomCapacity()
            DispatchQueue.main.async {
                self?.onRemoteMemberLeft?()
            }
        }

        room.onPublicationAddedHandler = { [weak self] publication in
            self?.subscribeIfNeeded(to: publication)
        }
    }

    private func ensureRoomCapacity() {
        guard let room = room else { return }
        if room.members.count > 2 {
            DispatchQueue.main.async {
                self.onMemberCountExceeded?()
            }
            leave()
        }
    }

    private func subscribeToExistingPublications() {
        room?.publications.forEach { publication in
            subscribeIfNeeded(to: publication)
        }
    }

    private func subscribeIfNeeded(to publication: Publication) {
        guard let member = localMember else { return }
        guard publication.publisher?.id != member.id else { return }

        Task {
            do {
                let subscription = try await member.subscribe(publication)
                handleSubscription(subscription)
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error)
                }
            }
        }
    }

    private func handleSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
        guard let stream = subscription.stream else { return }

        switch stream.contentType {
        case .video:
            if let videoStream = stream as? RemoteVideoStream {
                remoteVideoStream = videoStream
                DispatchQueue.main.async {
                    self.onRemoteVideoStream?(videoStream)
                }
            }
        case .audio:
            if let audioStream = stream as? RemoteAudioStream {
                remoteAudioStream = audioStream
                DispatchQueue.main.async {
                    self.onRemoteAudioStream?(audioStream)
                }
            }
        case .data:
            if let dataStream = stream as? RemoteDataStream {
                remoteDataStream = dataStream
                dataStream.onDataHandler = { [weak self] data in
                    guard let text = String(data: data, encoding: .utf8) else { return }
                    DispatchQueue.main.async {
                        self?.onRemoteData?(text)
                    }
                }
                DispatchQueue.main.async {
                    self.onDataStreamReady?()
                }
            }
        @unknown default:
            break
        }
    }

    private func cleanup() {
        subscriptions.removeAll()
        localVideoStream = nil
        localAudioStream = nil
        localDataStream = nil
        remoteVideoStream = nil
        remoteAudioStream = nil
        remoteDataStream = nil
        localMember = nil
        room = nil
    }
}
