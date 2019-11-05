import Foundation
import RealmSwift

class ImagePrediction: Object {
    @objc dynamic var imagePath = ""
    let sceneClassifierPredictions = List<SceneClassifierPrediction>()
    let inceptionResnetPredictions = List<InceptionResnetPrediction>()
    override static func primaryKey() -> String? {
        return "imagePath"
    }
}

class SceneClassifierPrediction: Object {
    @objc dynamic var labelId = ""
    @objc dynamic var label = ""
    @objc dynamic var probability: Double = 0.0
}

class InceptionResnetPrediction: Object {
    @objc dynamic var labelId = ""
    @objc dynamic var label = ""
    @objc dynamic var probability: Double = 0.0
}
