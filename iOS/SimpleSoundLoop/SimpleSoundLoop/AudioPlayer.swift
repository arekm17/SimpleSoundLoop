//
//  AudioPlayer.swift
//  SimpleSoundLoop
//
//  Created by Arek on 07/02/2019.
//  Copyright © 2019 Arek. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayerDelegate: class {
    func onPlayingFinished()
    func onPlayingError()
    func playingTimeProgress(seconds seconds: Int, percent: Float)
}

protocol AudioPlayer: class {
    weak var delegate: AudioPlayerDelegate? { get set }
    func setup()
    func play(_ url: URL)
    func stop()
}

class AudioPlayerImpl: NSObject, AudioPlayer {
    
    weak var delegate: AudioPlayerDelegate?
    private var soundPlayer: AVAudioPlayer?
    private var updater : CADisplayLink?

    func setup() {
        initUpdater()
    }
    
    private func initUpdater() {
        updater = CADisplayLink(target: self, selector: #selector(trackAudio))
        updater?.add(to: RunLoop.current, forMode: .common)
        updater?.frameInterval = 20
        updater?.isPaused = true
    }
    
    @objc private func trackAudio() {
        guard let soundPlayer = soundPlayer else { return }

        let currentTime = Int(soundPlayer.currentTime)
        let normalizedTime = Float(soundPlayer.currentTime * 100.0 / soundPlayer.duration)

        delegate?.playingTimeProgress(seconds: currentTime, percent: normalizedTime)
        
    }
    
    func play(_ url: URL) {
        
        do {
            print (url)
//            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)

            soundPlayer?.delegate = self
            let ok = soundPlayer?.prepareToPlay()
            print("prepare to play: \(ok)")
            soundPlayer?.volume = 1.0
            soundPlayer?.numberOfLoops = -1
            updater?.isPaused = false
            
            soundPlayer?.play()
        } catch let err {
            print("AVAudioPlayer error: \(err.localizedDescription)")
//            print("exception: \(error)")
        }
    }
    
    func stop() {
        soundPlayer?.stop()
        updater?.isPaused = true
    }
    
    
}

extension AudioPlayerImpl: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updater?.isPaused = true
        delegate?.onPlayingFinished()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        //handle error
        if let error = error {
            print(error)
        }
        updater?.isPaused = true
        delegate?.onPlayingError()
    }
}
