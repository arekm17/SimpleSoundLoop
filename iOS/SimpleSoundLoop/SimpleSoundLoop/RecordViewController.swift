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
    @IBOutlet weak var filesTable: UITableView!
    
    let recordOnImage : UIImage? = UIImage(named: "rec_button_on")
    let recordImage : UIImage? = UIImage(named: "rec_button")
    
//    var isRecording = false
    
    
    var soundRecorder: AVAudioRecorder!
    var soundPlayer: AVAudioPlayer!
    var updater : CADisplayLink!
    var isRecording : Bool = false
    var filesRepository : FilesRepository = FilesRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews();
        
        setupRecorder()
        initUpdater();
    }

    func initViews() {
//        recordButton.setImage(UIImage(named: "rec_button_on_selected"), forState: UIControlState.Selected | UIControlState.Highlighted)
        playButton.isHidden = false
//        playButton.setImage(UIImage(named: "rec_button_on_selected"), forState: .Selected)
        
        
        filesTable.dataSource = filesRepository
        filesTable.delegate = filesRepository
        
    }
    
    func setupRecorder() {
        
        let recordSettings = [
            AVFormatIDKey: NSNumber(value: Int32(kAudioFormatAppleLossless) as Int32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ] as [String : Any]
        
        do {
            let session = AVAudioSession.sharedInstance()
            try!  session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            soundRecorder = try AVAudioRecorder(url: SampleFile.getFileURL() as URL, settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()

        } catch {
//            print("AVAudioRecorder error: \(err.localizedDescription)")
            print("exception")
        }
    }
    
    func setupPlayer() {
        
        do {
            
            soundPlayer = try AVAudioPlayer(contentsOf: SampleFile.getFileURL() as URL)
        
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
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        updater.isPaused = true;
        
    }
    
    
    func trackAudio() {
        let currentTime = isRecording ? Int(soundRecorder.currentTime) : Int(soundPlayer.currentTime)

        print(currentTime);
        
        let minutes = currentTime / 60;
        let seconds = currentTime % 60;
        
        recordTime.text = String.init(format: "%d:%02d", minutes, seconds);
        if !isRecording {
            let normalizedTime = Float(soundPlayer.currentTime * 100.0 / soundPlayer.duration)
            playProgress.value = normalizedTime
        }
        
    }


    @IBAction func onRecordStart(_ sender: AnyObject) {
        
//        if !isRecording {
//            recordTime.text = "0:00"
//            recordButton.setImage(recordOnImage, forState: .Normal)
//        } else {
//            recordButton.setImage(recordImage, forState: .Normal)
//        }
        
        startRecord()
        
    }
    
    func startRecord() {
        
        if !isRecording {
            recordTime.textColor = UIColor.red
            isRecording = true
            soundRecorder.record()
            updater.frameInterval = 20
            updater.isPaused = false
        } else {
            soundRecorder.stop()
            isRecording = false
        }
        recordButton.isSelected = isRecording
    }
    
    @IBAction func onPlay(_ sender: AnyObject) {
        if !isRecording {
            playProgress.isHidden = false
            setupPlayer()
            playSample()
        }
    }

    func playSample() {
        playButton.isSelected = !playButton.isSelected
        
        if isPlaying() {
            soundPlayer.play()
            updater.frameInterval = 1
            updater.isPaused = false
        }
        else {
            soundPlayer.stop()
        }
    }
    
    func isPlaying() -> Bool {
        return playButton.isSelected
    }
    
    //Mark audio delegates
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordTime.textColor = UIColor.black
        recordTime.text = "0:00"
        playProgress.value = 0
        playProgress.isHidden = false
        playButton.isHidden = false;
        updater.isPaused = true
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        //handle error
        print(error)
        updater.isPaused = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordTime.text = "0:00";
        updater.isPaused = true
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        //handle error
        print(error)
        updater.isPaused = true
    }
    
    
    
}


