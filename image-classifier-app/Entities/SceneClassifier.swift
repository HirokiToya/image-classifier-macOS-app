import Foundation

class SceneClassifier {
    
    struct Label {
        let id: String
        let name: String
    }
    
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
