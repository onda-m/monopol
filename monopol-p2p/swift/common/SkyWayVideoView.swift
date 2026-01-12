import UIKit
import SkyWayRoom

final class SkyWayVideoView: UIView {
    private let rendererView = VideoView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        rendererView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rendererView)
        NSLayoutConstraint.activate([
            rendererView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rendererView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rendererView.topAnchor.constraint(equalTo: topAnchor),
            rendererView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func attach(localStream: LocalVideoStream) {
        localStream.addRenderer(rendererView)
    }

    func attach(remoteStream: RemoteVideoStream) {
        remoteStream.addRenderer(rendererView)
    }

    func detach(from localStream: LocalVideoStream) {
        localStream.removeRenderer(rendererView)
    }

    func detach(from remoteStream: RemoteVideoStream) {
        remoteStream.removeRenderer(rendererView)
    }
}
