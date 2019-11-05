import Foundation
import RealmSwift

class RealmAccessor: RealmAccessorInput {
    
    weak var output: RealmAccessorOutput!
    
    init(output: RealmAccessorOutput!) {
        self.output = output
        print("Realmファイル：\(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    // シーン識別結果を保存します。
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
    
    // 物体識別結果を保存します。
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
    
    // 識別結果を全て削除します。
    func deleteAll() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}
