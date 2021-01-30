//
//  SoundManager.swift
//  MatchApp
//
//  Created by KYUNGTAE KIM on 2021/01/29.
//

import Foundation
import AVFoundation

class SoundManager {
    var audioPlayer: AVAudioPlayer?
    
    enum SoundEffect {
        case flip
        case match
        case nomatch
        case shuffle
    }
    
    func playSound(effect: SoundEffect) {
        var soundFilename = ""
        
        switch effect {
        case .flip:
            soundFilename = "cardflip"
        case .match:
            soundFilename = "dingcorrect"
        case .nomatch:
            soundFilename = "dingwrong"
        case .shuffle:
            soundFilename = "shuffle"
        }
        
        // Get the path to the resource
        guard let bundlePath = Bundle.main.path(forResource: soundFilename, ofType: ".wav") else { return }

        let url = URL(fileURLWithPath: bundlePath)
        do {
            // Create the audio Player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // play
            audioPlayer?.play()
            
        } catch let error {
            print("\(error.localizedDescription)")
            return
        }
    }
}
