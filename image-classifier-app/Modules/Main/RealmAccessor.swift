import Foundation
import RealmSwift

class IBMArtificialIntelligence: Object {
    let imagePredictions = List<ImagePrediction>()
}

class ImagePrediction: Object {
    @objc dynamic var imageName = ""
    @objc dynamic var imagePath = ""
    
    let sceneClassifierPredictions = List<SceneClassifierPrediction>()
    let inceptionResnetPredictions = List<InceptionResnetPrediction>()
    
    override static func primaryKey() -> String? {
        return "imageName"
    }
}

class SceneClassifierPrediction: Object {
    @objc dynamic var labelId = ""
    @objc dynamic var label = ""
    @objc dynamic var probability = ""
}

class InceptionResnetPrediction: Object {
   @objc dynamic var labelId = ""
   @objc dynamic var label = ""
   @objc dynamic var probability = ""
}

class RealmAccessor {
    
}
