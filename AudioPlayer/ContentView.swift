//
//  ContentView.swift
//  AudioPlayer
//
//  Created by Jason Hawkins on 8/5/21.
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    @StateObject
    /// An audio provider class owned by this SwiftUI view.
    private var audioProvider = AudioProvider()
    
    @State
    /// The current visual state of the play / pause button.
    private var isPlaying = false
    
    var body: some View {
        Button(action: isPlaying ? pause : play) {
            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .padding()
        }
        .onAppear {
            // Sets an action to perform once audio playback has completed
            audioProvider.completionHandler = playbackDidFinish
        }
    }
    
    /// Update the UI and tell the provider to pause playback.
    private func pause() {
        isPlaying.toggle()
        audioProvider.pauseAlert()
    }
    
    /// Update the UI and tell the provider to begin playback.
    private func play() {
        isPlaying.toggle()
        audioProvider.playAlert()
    }
    
    /// Update the UI for the playback finished event.
    private func playbackDidFinish() {
        isPlaying.toggle()
    }
}

/// An observable object used to configure and handle audio playback.
class AudioProvider: NSObject, ObservableObject {
    private var player: AVAudioPlayer?
    
    /// An optional closure to execute when playback has finished.
    var completionHandler: (() -> Void)?
    
    /// Creates a new audio player, sets the provider as its delegate, and begins playback immediately.
    func playAlert() {
        let path = Bundle.main.path(forResource: "alert.m4a", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
        } catch {
            assertionFailure("Unable to initialize the audio player")
        }
    }
    
    /// Pauses playback.
    func pauseAlert() {
        guard player?.isPlaying == true else { return }
        player?.pause()
    }
}

/// Extends the `AudioProvider` to provide conformance to `AVAudioPlayerDelegate`
extension AudioProvider: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(
        _ player:
        AVAudioPlayer, successfully
        flag: Bool
    ) {
        // This method, `audioPlayerDidFinishPlaying` is called automatically once the player
        // has reached the end of the audio file. From here we can set a custom action to execute.
        completionHandler?()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
