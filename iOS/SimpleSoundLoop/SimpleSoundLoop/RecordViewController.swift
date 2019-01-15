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
    @IBOutlet weak var metrumBtn: MetrumButton!
    
    let recordOnImage : UIImage? = UIImage(named: "rec_button_on")
    let recordImage : UIImage? = UIImage(named: "rec_button")
    
//    var isRecording = false
    
    
    var soundRecorder: AVAudioRecorder!
    var soundPlayer: AVAudioPlayer!
    var updater : CADisplayLink!
    var isRecording : Bool = false
    var filesRepository : FilesRepository = FilesRepository()
    private var metronome: Metronome = MetronomeImpl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews();
        
        setupRecorder()
        initUpdater();
        
        initList()
        
    }
    
    func initList() {
        
        
    }

    func initViews() {
//        recordButton.setImage(UIImage(named: "rec_button_on_selected"), forState: UIControlState.Selected | UIControlState.Highlighted)
        playButton.isHidden = false
//        playButton.setImage(UIImage(named: "rec_button_on_selected"), forState: .Selected)
        
        filesRepository.setTableView(tableView: filesTable)

        
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
            try! session.setCategory(.playback, mode: .default)
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
            
//            soundPlayer = try AVAudioPlayer(contentsOf: SampleFile.getFileURL() as URL)
            guard let url = Bundle.main.url(forResource: "sample", withExtension: "wav")
                else {
                print("bundle sound read false")
                return
            }

            soundPlayer = try AVAudioPlayer(contentsOf: url)
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
        updater.add(to: RunLoop.current, forMode: .common)
        updater.isPaused = true;
        
    }
    
    
    @objc func trackAudio() {
        let currentTime = isRecording ? Int(soundRecorder.currentTime) : (isPlaying() ? Int(soundPlayer.currentTime) : 0)

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
            metronome.startWithMetrum(metrumBtn.metrum, tempo: 120, offsetBars: 0)
            updater.frameInterval = 20
            updater.isPaused = false
        } else {
            soundRecorder.stop()
            metronome.stop()
            updater.isPaused = true
            isRecording = false
            showSaveSampleDialog()
        }
        recordButton.isSelected = isRecording
        playButton.isHidden = isRecording
        playProgress.isHidden = isRecording
    }
    
    func showSaveSampleDialog() {
        let alert = UIAlertController(title: nil, message: "Zapisać nagranie?", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField) in textField.text = self.filesRepository.getNewFileName() })
        
        let action = UIAlertAction(title: "Zapisz", style: .default, handler: {[weak alert] (_) in
            let textField = alert?.textFields![0]

            self.saveSample(withFileName: textField!.text!);
        })
        
//        alert.textFields[0].onfo
        
        alert.addAction(action);
        
        let action2 = UIAlertAction(title: "Anuluj", style: .cancel, handler: nil)
        alert.addAction(action2)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func saveSample(withFileName: String) {
        filesRepository.saveCurrentSample(withFileName: withFileName)
        filesRepository.updateFiles();
    }
    
    @IBAction func onPlay(_ sender: AnyObject) {
        if !isRecording {
            setupPlayer()
            playSample()
        }
    }

    func playSample() {
        playButton.isSelected = !playButton.isSelected
        playProgress.isHidden = false
        
        if isPlaying() {
            soundPlayer.play()
            updater.frameInterval = 1
            updater.isPaused = false
        }
        else {
            soundPlayer.stop()
            updater.isPaused = true
        }
        recordButton.isHidden = isPlaying()
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
        print(error!)
        updater.isPaused = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordTime.text = "0:00";
        updater.isPaused = true
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        //handle error
        print(error!)
        updater.isPaused = true
    }
    
    
    
}


