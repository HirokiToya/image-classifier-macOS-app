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
