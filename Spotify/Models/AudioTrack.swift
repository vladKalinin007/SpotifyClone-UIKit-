//
//  AudioTrack.swift
//  Spotify
//
//  Created by Владислав Калинин on 13.12.2022.
//

import Foundation

class anyclass {
    
    func upload(result: Double, completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            completion("OK")
        }
    }
    
    func upload(result: Double) async -> String {
        "OK"
    }
    
}
