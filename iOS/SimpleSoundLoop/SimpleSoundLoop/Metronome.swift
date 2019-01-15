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

protocol Metronome {
    func startWithMetrum(_ metrum: Metrum, tempo: Int, offsetBars: Int)
    func stop()
}

class MetronomeImpl: Metronome {

    private var soundPlayer: AVAudioPlayer!
    private var disposeBag = DisposeBag()
    private var interval: Observable<Int>?

    init() {
        setupPlayer()
    }
    
    private func setupPlayer() {
        do {
            
            guard let url = Bundle.main.url(forResource: "sample", withExtension: "wav")
            else {
                return
            }
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)

            let ok = soundPlayer.prepareToPlay()
            print("prepare to play: \(ok)")
            soundPlayer.volume = 1.0
        } catch {
            print("exception")
        }
    }
    
    func startWithMetrum(_ metrum: Metrum, tempo: Int, offsetBars: Int) {
        interval = Observable<Int>
            .interval(60.0/Double(tempo), scheduler: MainScheduler.instance)
            
        interval?
            .do(onSubscribe: { [weak self] in
                self?.soundPlayer.play()
            })
            .subscribe(onNext: { [weak self] tick in
                self?.soundPlayer.play()
            }).disposed(by: disposeBag)
        
    }
 
    func stop() {
        disposeBag = DisposeBag()
    }
    
}
