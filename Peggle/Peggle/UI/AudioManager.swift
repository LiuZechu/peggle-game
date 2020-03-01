//
//  AudioManager.swift
//  Peggle
//
//  Created by Liu Zechu on 1/3/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager {
    static let sharedManager = AudioManager()
    private let backgroundMusicFileName = "background-music"
    private let bounceSoundFileName = "bounce-sound"
    private let cheerSoundFileName = "cheer-sound"
    var backgroundPlayer: AVAudioPlayer?
    var bounceSoundPlayer: AVAudioPlayer?
    var cheerSoundPlayer: AVAudioPlayer?
    
    private init() {
        backgroundPlayer = initialiseAudioPlayer(fileName: backgroundMusicFileName)
        bounceSoundPlayer = initialiseAudioPlayer(fileName: bounceSoundFileName)
        cheerSoundPlayer = initialiseAudioPlayer(fileName: cheerSoundFileName)
    }
    
    private func initialiseAudioPlayer(fileName: String) -> AVAudioPlayer? {
        let audioPath = Bundle.main.path(forResource: fileName, ofType: "mp3")
        guard let path = audioPath else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: path) as URL)
            return player
        } catch {
            return nil
        }
    }
    
}
