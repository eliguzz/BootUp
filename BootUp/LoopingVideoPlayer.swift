//
//  LoopingVideoPlayer.swift
//  BootUp
//
//  Created by Eli on 5/18/26.
//

import SwiftUI
import AVKit
import AVFoundation

struct LoopingVideoPlayer: UIViewRepresentable {

    let videoName: String       // filename without extension, e.g. "onboarding_picker"
    let videoExtension: String  // e.g. "mp4"

    func makeUIView(context: Context) -> LoopingPlayerUIView {
        LoopingPlayerUIView(videoName: videoName, videoExtension: videoExtension)
    }

    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {}
}

final class LoopingPlayerUIView: UIView {

    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?

    override static var layerClass: AnyClass { AVPlayerLayer.self }
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    init(videoName: String, videoExtension: String) {
        super.init(frame: .zero)
        setupPlayer(videoName: videoName, videoExtension: videoExtension)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupPlayer(videoName: String, videoExtension: String) {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            print("[LoopingVideoPlayer] Missing video: \(videoName).\(videoExtension)")
            return
        }

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        player.isMuted = true
        player.actionAtItemEnd = .advance

        let looper = AVPlayerLooper(player: player, templateItem: item)

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1.0).cgColor

        self.queuePlayer = player
        self.playerLooper = looper

        player.play()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            queuePlayer?.play()
        } else {
            queuePlayer?.pause()
        }
    }
}
