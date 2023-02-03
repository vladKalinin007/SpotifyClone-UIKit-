//
//  Artist.swift
//  Spotify
//
//  Created by Владислав Калинин on 13.12.2022.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}


