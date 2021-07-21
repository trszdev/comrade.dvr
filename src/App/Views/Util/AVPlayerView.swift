import SwiftUI
import AVKit

struct AVPlayerView: UIViewControllerRepresentable {
  let url: URL

  func makeUIViewController(context: Context) -> AVPlayerViewController {
    AVPlayerViewController()
  }

  func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    let player = AVPlayer(url: url)
    player.play()
    uiViewController.player = player
  }
}
