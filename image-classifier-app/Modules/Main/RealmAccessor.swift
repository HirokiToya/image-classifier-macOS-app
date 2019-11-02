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

class RealmAccessor: RealmAccessorInput {
    weak var output: RealmAccessorOutput!
    
    init(output: RealmAccessorOutput!) {
        self.output = output
        print("Realmファイル：\(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    func saveSceneClassifierPrediction(data: SceneClassifier.ImageData){
        let realm = try! Realm()
        
        if let prediction = realm.object(ofType: ImagePrediction.self, forPrimaryKey: data.path) {
            
            if(prediction.sceneClassifierPredictions.count == 0) {
                try! realm.write {
                    for data in data.predictions {
                        let scenePrediction = SceneClassifierPrediction()
                        scenePrediction.labelId = data.labelId
                        scenePrediction.label = data.label
                        scenePrediction.probability = data.probability
                        
                        prediction.sceneClassifierPredictions.append(scenePrediction)
                    }
                    
                    realm.add(prediction)
                }
            }
            
        } else {
            
            try! realm.write {
                let prediction = ImagePrediction()
                prediction.imagePath = data.path
                
                for data in data.predictions {
                    let scenePrediction = SceneClassifierPrediction()
                    scenePrediction.labelId = data.labelId
                    scenePrediction.label = data.label
                    scenePrediction.probability = data.probability
                    
                    prediction.sceneClassifierPredictions.append(scenePrediction)
                }
                
                realm.add(prediction)
            }
        }
    }
    
    func saveInceptionResnetPrediction(data: InceptionResnet.ImageData) {
        
        let realm = try! Realm()
        if let prediction = realm.object(ofType: ImagePrediction.self, forPrimaryKey: data.path) {
            if(prediction.inceptionResnetPredictions.count == 0) {
                try! realm.write {
                    for data in data.predictions {
                        let inceptionPrediction = InceptionResnetPrediction()
                        inceptionPrediction.labelId = data.labelId
                        inceptionPrediction.label = data.label
                        inceptionPrediction.probability = data.probability
                        
                        prediction.inceptionResnetPredictions.append(inceptionPrediction)
                    }
                    realm.add(prediction)
                }
            }
            
        } else {
            
            try! realm.write {
                let prediction = ImagePrediction()
                prediction.imagePath = data.path
                
                for data in data.predictions {
                    let inceptionPrediction = InceptionResnetPrediction()
                    inceptionPrediction.labelId = data.labelId
                    inceptionPrediction.label = data.label
                    inceptionPrediction.probability = data.probability
                    
                    prediction.inceptionResnetPredictions.append(inceptionPrediction)
                }
                realm.add(prediction)
            }
        }
    }
    
    func deleteAll() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}
