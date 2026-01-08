import Foundation
import UIKit
import AVFoundation

#if canImport(SkyWay)
@_exported import SkyWay
#else
// Compatibility layer for environments where the legacy SkyWay SDK is not
// available. The lightweight stub classes below mirror the interfaces used in
// the project so that the sources continue to compile when adopting the new
// SkyWay release packages.

public typealias SKWEventCallback = (Any?) -> Void

public enum SKWPeerEventEnum: Int {
    case PEER_EVENT_OPEN
    case PEER_EVENT_CONNECTION
    case PEER_EVENT_CALL
    case PEER_EVENT_CLOSE
    case PEER_EVENT_DISCONNECTED
    case PEER_EVENT_ERROR
    case PEER_EVENT_LOG
}

public enum SKWMediaConnectionEventEnum: Int {
    case MEDIACONNECTION_EVENT_STREAM
    case MEDIACONNECTION_EVENT_CLOSE
    case MEDIACONNECTION_EVENT_ERROR
    case MEDIACONNECTION_EVENT_UNKNOWN
}

public enum SKWDataConnectionEventEnum: Int {
    case DATACONNECTION_EVENT_OPEN
    case DATACONNECTION_EVENT_CLOSE
    case DATACONNECTION_EVENT_ERROR
    case DATACONNECTION_EVENT_DATA
}

public enum SKWRoomEventEnum: Int {
    case ROOM_EVENT_OPEN
    case ROOM_EVENT_STREAM
    case ROOM_EVENT_REMOVE_STREAM
    case ROOM_EVENT_CLOSE
    case ROOM_EVENT_ERROR
}

public enum SKWCameraPositionEnum: Int {
    case CAMERA_POSITION_FRONT
    case CAMERA_POSITION_BACK
}

public enum SKWCameraModeEnum: Int {
    case CAMERA_MODE_CONTINUOUS
    case CAMERA_MODE_ADJUSTABLE
}

public enum SKWSerializationEnum: Int {
    case SERIALIZATION_BINARY
    case SERIALIZATION_NONE
}

public class SKWPeerOption {
    public init() {}
    public var key: String?
    public var domain: String?
}

public class SKWCallOption {
    public init() {}
}

public class SKWConnectOption {
    public init() {}
    public var serialization: SKWSerializationEnum = .SERIALIZATION_NONE
}

public class SKWRoomOption {
    public init() {}
    public var stream: SKWMediaStream?
}

public class SKWMediaConstraints {
    public init() {}
    public var maxFrameRate: UInt = 0
    public var cameraMode: SKWCameraModeEnum = .CAMERA_MODE_CONTINUOUS
    public var cameraPosition: SKWCameraPositionEnum = .CAMERA_POSITION_FRONT
    public var minWidth: UInt = 0
    public var minHeight: UInt = 0
}

public class SKWMediaStream {
    public init() {}
    public var peerId: String?
    public func addVideoRenderer(_ renderer: SKWVideo?, track: NSNumber?) {}
    public func removeVideoRenderer(_ renderer: SKWVideo?, track: NSNumber?) {}
    public func close() {}
    public func setEnableAudioTrack(_ index: Int, enable: Bool) {}
}

public class SKWVideo: UIView {
    public func addSrc(_ stream: SKWMediaStream?, track: NSNumber?) {}
}

public class SKWNavigator {
    public static func initialize(_ peer: SKWPeer?) {}
    public static func terminate() {}
    public static func getUserMedia(_ constraints: SKWMediaConstraints?) -> SKWMediaStream? {
        return SKWMediaStream()
    }
}

public class SKWPeer {
    public init(id: String? = nil, options: SKWPeerOption? = nil) {}

    public private(set) var isDestroyed: Bool = false
    public private(set) var isDisconnected: Bool = false

    private var callbacks: [SKWPeerEventEnum: SKWEventCallback] = [:]

    public func on(_ event: SKWPeerEventEnum, callback: @escaping SKWEventCallback) {
        callbacks[event] = callback
    }

    public func reconnect() { isDisconnected = false }
    public func destroy() { isDestroyed = true }
    public func disconnect() { isDisconnected = true }

    public func listAllPeers(_ completion: @escaping (Any?) -> Void) {
        completion([])
    }

    public func joinRoom(withName name: String, options: SKWRoomOption?) -> SKWRoom? {
        return SKWRoom()
    }

    public func call(withId peerId: String, stream: SKWMediaStream?, options: SKWCallOption?) -> SKWMediaConnection? {
        return SKWMediaConnection()
    }

    public func connect(withId peerId: String, options: SKWConnectOption?) -> SKWDataConnection? {
        return SKWDataConnection()
    }
}

public class SKWRoom {
    private var callbacks: [SKWRoomEventEnum: SKWEventCallback] = [:]

    public func on(_ event: SKWRoomEventEnum, callback: @escaping SKWEventCallback) {
        callbacks[event] = callback
    }

    public func close() {}
}

public class SKWPeerError: Error {}

public class SKWMediaConnection {
    private var callbacks: [SKWMediaConnectionEventEnum: SKWEventCallback] = [:]

    public func on(_ event: SKWMediaConnectionEventEnum, callback: @escaping SKWEventCallback) {
        callbacks[event] = callback
    }

    public func answer(_ stream: SKWMediaStream?) {}
    public func close() {}
}

public class SKWDataConnection {
    private var callbacks: [SKWDataConnectionEventEnum: SKWEventCallback] = [:]

    public func on(_ event: SKWDataConnectionEventEnum, callback: @escaping SKWEventCallback) {
        callbacks[event] = callback
    }

    public func send(_ data: Any) {}

    public func close() {}
}
#endif
