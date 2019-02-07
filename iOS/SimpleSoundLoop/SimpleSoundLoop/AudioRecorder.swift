//
//  AudioRecorder.swift
//  SimpleSoundLoop
//
//  Created by Arek on 24.08.2016.
//  Copyright © 2016 Arek. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioRecorder: class {
    weak var delegate: AudioRecorderDelegate? { get set }
    weak var metronome: Metronome? {get set}
    func setup()
    func startRecord()
    func stopRecord()
}

protocol AudioRecorderDelegate: class {
    func onRecordStarted()
    func onRecordStopped()
    func onRecordError()
    func onRecordFinished()
    func recordTimeProgress(seconds seconds: Int)
}

class AudioRecorderImpl: NSObject, AudioRecorder {

    private var soundRecorder: AVAudioRecorder!
    weak var delegate: AudioRecorderDelegate?
    weak var metronome: Metronome?
    private var updater : CADisplayLink?

    func setup() {
        
        initUpdater()
        
        let recordSettings = [
            AVFormatIDKey: NSNumber(value: Int32(kAudioFormatAppleLossless) as Int32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
            ] as [String : Any]
        
        do {
//            let session = AVAudioSession.sharedInstance()
//            try! session.setCategory(.playback, mode: .default)
            soundRecorder = try AVAudioRecorder(url: SampleFile.getFileURL() as URL, settings: recordSettings)
            soundRecorder.delegate = self
//            soundRecorder.prepareToRecord()
            
        } catch let err {
            print("AVAudioRecorder setup error: \(err.localizedDescription)")
        }
    }
    
    private func initUpdater() {
        updater = CADisplayLink(target: self, selector: #selector(trackAudio))
        updater?.add(to: RunLoop.current, forMode: .common)
        updater?.frameInterval = 20
        updater?.isPaused = true;
        
    }
    
    @objc private func trackAudio() {
        let currentTime = Int(soundRecorder.currentTime)
        delegate?.recordTimeProgress(seconds: currentTime)
    }
    

}

extension AudioRecorderImpl {
    func startRecord() {

        if !soundRecorder.isRecording {
            soundRecorder.prepareToRecord()
//            recordTime.textColor = UIColor.red
//            isRecording = true
            updater?.isPaused = false
            soundRecorder.record()
            delegate?.onRecordStarted()
            metronome?.start(0)
        } else {
//            soundRecorder.stop()
            metronome?.stop()
//            updater.isPaused = true
//            isRecording = false
//            showSaveSampleDialog()
        }
//        recordButton.isSelected = isRecording
//        playButton.isHidden = isRecording
//        playProgress.isHidden = isRecording
    }
    
    func stopRecord() {
        metronome?.stop()
        soundRecorder.stop()
        updater?.isPaused = true
        delegate?.onRecordStopped()
    }
}

extension AudioRecorderImpl: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        updater?.isPaused = true
        delegate?.onRecordFinished()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print(error)
        }
        updater?.isPaused = true
        delegate?.onRecordError()
    }
    
}
