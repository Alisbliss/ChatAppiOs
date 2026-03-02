//
//  ExtensionCustomInputView.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 26.02.2026.
//

import UIKit

extension CustomeInputView {
    
    @objc func handleCancelButton() {
        recordStackView.isHidden = true
        stackView.isHidden = false
        recorder.stopRecording()
    }
    
    @objc func handleSendRecordButton() {
        recorder.stopRecording()
        recordStackView.isHidden = true
        
        let name = recorder.getRecordings.last ?? ""
        guard let audioURL = recorder.getAudioURL(name: name) else { return }
        self.delegate?.inputViewForAudion(self, audioURL: audioURL)
        stackView.isHidden = false
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if recorder.isRecording && !recorder.isPlaying {
            duration += 1
            self.timerLabel.text = duration.timeStringFormatter
        } else {
            timer.invalidate()
            duration = 0
            self.timerLabel.text = "00:00"
        }
    }
}
