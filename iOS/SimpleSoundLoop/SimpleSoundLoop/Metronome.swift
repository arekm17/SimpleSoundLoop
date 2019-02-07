//
//  Metronome.swift
//  SimpleSoundLoop
//
//  Created by Arek on 15.01.2019.
//  Copyright © 2019 Arek. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift

protocol Metronome: class {
    var metrum: Metrum {get set}
    var tempo: Int {get set}
    func start(_ offsetBars: Int)
    func stop()
}

class MetronomeImpl: Metronome {

    private var soundPlayer: AVAudioPlayer!
    private var disposeBag = DisposeBag()
    private var interval: Observable<Int>?
    private var metrumCounter: MetrumCounter?

    var metrum = Metrum.none
    var tempo = 0
    
    init() {
//        setupPlayer()
    }
    
    private func setupPlayer() {
        do {
            
            guard let url = Bundle.main.url(forResource: "sample", withExtension: "wav")
            else {
                return
            }
            
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)

            let ok = soundPlayer.prepareToPlay()
            print("prepare to play: \(ok)")
            
            soundPlayer.volume = 1.0
        } catch {
            print("exception")
        }
    }
    
    func start(_ offsetBars: Int = 0) {
        if metrum == .none {
            return
        }
        
        setupPlayer()
        metrumCounter = MetrumCounter(metrum: metrum)

        interval = Observable<Int>
            .interval(60.0 / Double(tempo), scheduler: MainScheduler.instance)
        
        interval?
            .do(onSubscribe: { [weak self] in
//                guard let `self` = self else { return }
//
//                self.soundPlayer.volume = self.metrumCounter?.getVolumeForTick(0) ?? 1.0
//                self.soundPlayer.play()
            })
            .do(onDispose: { [weak self] in
                self?.metrumCounter = nil
                self?.soundPlayer.stop()
                self?.soundPlayer = nil
            })
            .subscribe(onNext: { [weak self] tick in
                guard let `self` = self else { return }
                
                self.soundPlayer.volume = self.metrumCounter?.getVolumeForTick(tick) ?? 1.0
                self.soundPlayer.play()
                
            })
            .disposed(by: disposeBag)
        
    }
 
    func stop() {
        disposeBag = DisposeBag()
        metrumCounter = nil
    }
    
}

private class MetrumCounter {
    
    enum SoundValue: Float {
        case loud = 1.0
        case quiet = 0.3
        case silence = 0.0
    }
    
    private let metrum: Metrum
    
    init(metrum: Metrum) {
        self.metrum = metrum
    }

    func getVolumeForTick(_ tick: Int) -> Float {
        switch metrum {
        case ._4_4:
            return standardVolume(tick, denominator: 4)
        case ._3_4:
            return standardVolume(tick, denominator: 3)
        case .shuffle:
            return shuffleVolume(tick)
        default:
            return SoundValue.loud.rawValue
        }
    }

    private func standardVolume(_ tick: Int, denominator: Int) -> Float {
        return tick % denominator == 0 ? SoundValue.loud.rawValue : SoundValue.quiet.rawValue
    }
    
    private func shuffleVolume(_ tick: Int) -> Float {
        switch tick % 3 {
        case 2:
            return SoundValue.quiet.rawValue
        case 1:
            return SoundValue.silence.rawValue
        default:
            return SoundValue.loud.rawValue
        }
    }
}
