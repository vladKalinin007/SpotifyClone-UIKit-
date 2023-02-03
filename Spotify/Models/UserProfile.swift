//
//  UserProfile.swift
//  Spotify
//
//  Created by Владислав Калинин on 13.12.2022.
//

import Foundation

struct UserProfile: Codable {
    
    let country: String
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
}


