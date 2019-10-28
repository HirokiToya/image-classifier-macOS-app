import Foundation

class SceneClassifier {
    
    struct Label {
        let id: String
        let name: String
    }
    
    struct Prediction {
        let labelId: Int
        let label: String
        let probability: Double
    }
    
    struct ImageData {
        let imageName: String
        let imagePath: String
        let predictions: [Prediction]
    }
}
