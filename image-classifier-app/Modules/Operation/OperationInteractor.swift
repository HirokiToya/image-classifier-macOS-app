import Foundation

class OperationInteractor: OperationInteractorInput {
    weak var output: OperationInteractorOutput!
    var realmAccessor: RealmAccessorInput!
    
    init(output: OperationInteractorOutput!) {
        self.output = output
        self.realmAccessor = RealmAccessor(output: self)
    }
    
    func predictScenes(path: URL) {
        ApiAccessor.predictScene(path: path) { result in
            switch result {
            case let .success(result):
                print(result.predictions.count)
                // ApiPayload.SceneClassifierPredict型をSceneClassifier.ImageData型に変換
                var predictions: [SceneClassifier.Prediction] = []
                
                for result in result.predictions {
                    let scenePrediction = SceneClassifier.Prediction(labelId: result.labelId,
                                                                     label: result.label,
                                                                     probability: result.probability)
                    predictions.append(scenePrediction)
                }
                
                let imageData = SceneClassifier.ImageData(path: "\(path)", predictions: predictions)
                self.realmAccessor.saveSceneClassifierPrediction(data: imageData)
                self.output.predictedScenes()
                
            case let .failture(error):
                print(error)
            }
        }
    }
    
    func predictObjects(path: URL) {
        ApiAccessor.predictObject(path: path) { result in
            switch result {
            case let .success(result):
                print(result.predictions.count)
                // ApiPayload.InceptionResnetPredict型をInceptionResnet.ImageData型に変換
                var predictions: [InceptionResnet.Prediction] = []
                
                for result in result.predictions {
                    let inceptionPrediction = InceptionResnet.Prediction(labelId: result.labelId,
                                                                     label: result.label,
                                                                     probability: result.probability)
                    predictions.append(inceptionPrediction)
                }
                
                let imageData = InceptionResnet.ImageData(path: "\(path)", predictions: predictions)
                self.realmAccessor.saveInceptionResnetPrediction(data: imageData)
                self.output.predictedObjects()
                
            case let .failture(error):
                print(error)
            }
        }
    }
    
    func deleteAll(){
        realmAccessor.deleteAll()
    }
}

extension OperationInteractor: RealmAccessorOutput {
    
}
