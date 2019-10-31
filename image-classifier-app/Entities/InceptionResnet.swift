//
//  InceptionResnet.swift
//  image-classifier-app
//
//  Created by 外谷弘樹 on 2019/10/31.
//  Copyright © 2019 example. All rights reserved.
//

import Foundation

class InceptionResnet {
    
    struct Prediction {
        let labelId: String
        let label: String
        let probability: Double
    }
    
    struct ImageData {
        let path: String
        let predictions: [Prediction]
    }
}
