import Foundation

class ApiPayload {
    
    struct SceneClassifierLabel : Codable  {
        let count: Int
        let labels: [Label]
    }
    
    struct Label : Codable   {
        let id: String
        let name: String
    }
    
    struct SceneClassifierPredict : Codable {
        let status: String
        let predictions: [Prediction]
    }
    
    struct InceptionResnetPredict : Codable {
        let status: String
        let predictions: [Prediction]
    }
    
    struct Prediction : Codable {
        let labelId: Int
        let label: String
        let probability: Double
        
        enum CodingKeys: String, CodingKey {
            case labelId = "label_id"
            case label
            case probability
        }
    }
}

