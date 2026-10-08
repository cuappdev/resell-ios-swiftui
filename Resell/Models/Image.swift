//
//  Image.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

struct ImageBody: Encodable {
    let imageBase64: String
}

struct ImageResponse: Decodable {
    let image: String
}
