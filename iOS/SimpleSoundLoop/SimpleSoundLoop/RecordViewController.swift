//
//  FirstViewController.swift
//  SimpleSoundLoop
//
//  Created by Arek on 24.08.2016.
//  Copyright © 2016 Arek. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var recordTime: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playProgress: UISlider!

    let recordOnImage : UIImage? = UIImage(named: "rec_button_on")
    let recordImage : UIImage? = UIImage(named: "rec_button")
    
//    var isRecording = false
    
    
    var soundRecorder: AVAudioRecorder!
    var soundPlayer: AVAudioPlayer!
    var updater : CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews();
        
        setupRecorder()
        initUpdater();
    }

    func initViews() {
//        recordButton.setImage(UIImage(named: "rec_button_on_selected"), forState: UIControlState.Selected | UIControlState.Highlighted)
        playButton.hidden = false
//        playButton.setImage(UIImage(named: "rec_button_on_selected"), forState: .Selected)
        
    }
    
    func setupRecorder() {
        
        let recordSettings = [
            AVFormatIDKey: NSNumber(int: Int32(kAudioFormatAppleLossless)),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        
        do {
            soundRecorder = try AVAudioRecorder(URL: SampleFile.getFileURL(), settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()

        } catch {
//            print("AVAudioRecorder error: \(err.localizedDescription)")
            print("exception")
        }
    }
    
    func setupPlayer() {
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOfURL: SampleFile.getFileURL())
        
            soundPlayer.delegate = self
            let ok = soundPlayer.prepareToPlay()
            print("prepare to play: \(ok)")
            soundPlayer.volume = 1.0
            soundPlayer.numberOfLoops = -1
        } catch  {
//            println(“AVAudioPlayer error: \(err.localizedDescription)“)
            print("exception")
        }
    }
    
    func initUpdater() {
        updater = CADisplayLink(target: self, selector: #selector(trackAudio))
        updater.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        updater.paused = true;
        
    }
    
    
    func trackAudio() {
        let currentTime = isRecording() ? Int(soundRecorder.currentTime) : Int(soundPlayer.currentTime)

        print(currentTime);
        
        let minutes = currentTime / 60;
        let seconds = currentTime % 60;
        
        if isRecording() {
            recordTime.text = String.init(format: "%d:%02d", minutes, seconds);
        } else {
            let normalizedTime = Float(soundPlayer.currentTime * 100.0 / soundPlayer.duration)
            playProgress.value = normalizedTime
        }
        
    }


    @IBAction func onRecordStart(sender: AnyObject) {
        
//        if !isRecording {
//            recordTime.text = "0:00"
//            recordButton.setImage(recordOnImage, forState: .Normal)
//        } else {
//            recordButton.setImage(recordImage, forState: .Normal)
//        }
        
        startRecord()
        
    }
    
    func startRecord() {
        recordButton.selected = !recordButton.selected
        
        if isRecording() {
            soundRecorder.record()
            updater.frameInterval = 20
            updater.paused = false
        } else {
            soundRecorder.stop()
        }
    }
    
    func isRecording() -> Bool {
        return recordButton.selected
    }
    
    @IBAction func onPlay(sender: AnyObject) {
        if !isRecording() {
            playProgress.hidden = false
            setupPlayer()
            playSample()
        }
    }

    func playSample() {
        playButton.selected = !playButton.selected
        
        if isPlaying() {
            soundPlayer.play()
            updater.frameInterval = 1
            updater.paused = false
        }
        else {
            soundPlayer.stop()
        }
    }
    
    func isPlaying() -> Bool {
        return playButton.selected
    }
    
    //Mark audio delegates
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        recordTime.text = "0:00"
        recordTime.hidden = true
        playProgress.value = 0
        playProgress.hidden = false
        playButton.hidden = false;
        updater.paused = true
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        //handle error
        print(error)
        updater.paused = true
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        recordTime.text = "0:00";
        updater.paused = true
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        //handle error
        print(error)
        updater.paused = true
    }
    
    
    
}


