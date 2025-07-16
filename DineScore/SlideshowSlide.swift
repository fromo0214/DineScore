//
//  SlideshowSlide.swift
//  DineScore
//
//  Created by Fernando Romo on 6/24/25.
//

import SwiftUI

struct SlideshowSlide: Identifiable{
    let id = UUID()
    let title:String
    let imageName: String
    let description: String
    var imageNameTwo: String = ""
    var showButton = false
}
