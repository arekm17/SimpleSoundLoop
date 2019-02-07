//
//  FirstViewController.swift
//  SimpleSoundLoop
//
//  Created by Arek on 24.08.2016.
//  Copyright © 2016 Arek. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var recordTime: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playProgress: UISlider!
    @IBOutlet weak var filesTable: UITableView!
    @IBOutlet weak var metrumBtn: MetrumButton!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var tempoSlider: UISlider!
    
    
//    let recordOnImage : UIImage? = UIImage(named: "rec_button_on")
//    let recordImage : UIImage? = UIImage(named: "rec_button")
//
//    var isRecording = false
    
    let recorder: AudioRecorder = AudioRecorderImpl()
    let player: AudioPlayer = AudioPlayerImpl()

    var isRecording : Bool = false
    var filesRepository : FilesRepository = FilesRepository()
    private var metronome: Metronome = MetronomeImpl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews();
        
        recorder.delegate = self
//        recorder.setup()
        recorder.metronome = metronome

        player.setup()
        player.delegate = self
        
        initList()
        
    }
    
    func initList() {
        
        
    }

    func initViews() {
//        recordButton.setImage(UIImage(named: "rec_button_on_selected"), forState: UIControlState.Selected | UIControlState.Highlighted)
        playButton.isHidden = false
//        playButton.setImage(UIImage(named: "rec_button_on_selected"), forState: .Selected)
        
        filesRepository.delegate = self
        filesRepository.setTableView(tableView: filesTable)

//
//        recordButton.setImage(recordOnImage, for: .normal)//.setImage(recordOnImage, forState: .Normal)
//        recordButton.setImage(recordImage, for: .selected)
    }
    
    
    
    
    @IBAction func onRecordStart(_ sender: AnyObject) {
        
//        if !isRecording {
//            recordTime.text = "0:00"
//            recordButton.setImage(recordOnImage, forState: .Normal)
//        } else {
//            recordButton.setImage(recordImage, forState: .Normal)
//        }
        
        metronome.metrum = metrumBtn.metrum
        metronome.tempo = getTempo()

        if !recordButton.isSelected {
            recordTime.text = "0:00"
            recorder.startRecord()
            recordButton.isSelected = true
        } else {
            recorder.stopRecord()
            recordButton.isSelected = false
        }
        
//        recordButton.isSelected = !recordButton.isSelected
    }
    
//    func startRecord() {
//        
//        if !isRecording {
//            recordTime.textColor = UIColor.red
//            isRecording = true
//            soundRecorder.record()
//            if metrumBtn.metrum != .none {
//                metronome.startWithMetrum(metrumBtn.metrum, tempo: getTempo(), offsetBars: 0)
//            }
//            updater.frameInterval = 20
//            updater.isPaused = false
//        } else {
//            soundRecorder.stop()
//            metronome.stop()
//            updater.isPaused = true
//            isRecording = false
//            showSaveSampleDialog()
//        }
//        recordButton.isSelected = isRecording
//        playButton.isHidden = isRecording
//        playProgress.isHidden = isRecording
//    }
    
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
            playSample()
        }
    }

    func playSample(_ url: URL = SampleFile.getFileURL()) {
        playButton.isSelected = !playButton.isSelected
        playProgress.isHidden = false
        
        if isPlaying() {
            player.play(url)
        }
        else {
            player.stop()
        }
        recordButton.isHidden = isPlaying()
    }
    
    func playFile(_ url: URL) {
        if !isRecording {
            playSample(url)
        }

    }
    
    func isPlaying() -> Bool {
        return playButton.isSelected
    }
    
    
}


extension RecordViewController {
    @IBAction func onTempoChanged(_ sender: Any) {
        
        self.tempoLabel.text = String(getTempo())
        
    }
    
    fileprivate func getTempo() -> Int {
        return Int(tempoSlider.value)
    }
}

extension RecordViewController: FilesRepositoryDelegate {
    func onSelectFile(_ url: URL) {
        playFile(url)
    }
}


extension RecordViewController: AudioRecorderDelegate {
    
    func onRecordStarted() {
        recordButton.isSelected = true
        playButton.isHidden = true
        playProgress.isHidden = true
    }
    
    func onRecordStopped() {        
        recordButton.isSelected = false
        playButton.isHidden = false
        playProgress.isHidden = false
        showSaveSampleDialog()
    }
    
    func onRecordFinished() {
        recordTime.textColor = UIColor.black
        recordTime.text = "0:00"
        playProgress.value = 0
        playProgress.isHidden = false
        playButton.isHidden = false
    }
    
    func onRecordError() {
        //handle error
        recordTime.text = "error"
    }
    
    func recordTimeProgress(seconds: Int) {
        let min = seconds / 60
        let sec = seconds % 60
        recordTime.text = String.init(format: "%d:%02d", min, sec);
    }
}

extension RecordViewController: AudioPlayerDelegate {
    func onPlayingFinished() {
        recordTime.text = "0:00";
    }
    
    func onPlayingError() {
        
    }
    
    func playingTimeProgress(seconds: Int, percent: Float) {
        let min = seconds / 60
        let sec = seconds % 60

        recordTime.text = String.init(format: "%d:%02d", min, sec);
        playProgress.value = percent

    }
}
