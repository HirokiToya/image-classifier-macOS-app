import Foundation
import RealmSwift

class PredictionRepositories {
    
    private static var predictions: [PredictionResult] = []
    
    class func getPredictionResults() -> [PredictionResult] {
        
        if !predictions.isEmpty {
            return predictions
        }
        
        // 識別結果を全て取得します。
        let realm = try! Realm()
        let results = realm.objects(ImagePrediction.self)
        predictions = []
        
        // データベースのデータをオブジェクトPredictionResult型にマッピング
        for result in results {
            var predictionResult = PredictionResult()
            var scenePredictions: [ScenePrediction] = []
            var resnetPredictions: [ResnetPrediction] = []
            
            for sceneResult in result.sceneClassifierPredictions {
                var scenePrediction = ScenePrediction()
                scenePrediction.labelId = sceneResult.labelId
                scenePrediction.label = sceneResult.label
                scenePrediction.probability = sceneResult.probability
                scenePredictions.append(scenePrediction)
            }
            
            for resnetResult in result.inceptionResnetPredictions {
                var resnetPrediction = ResnetPrediction()
                resnetPrediction.labelId = resnetResult.labelId
                resnetPrediction.label = resnetResult.label
                resnetPrediction.probability = resnetResult.probability
                resnetPredictions.append(resnetPrediction)
            }
            
            predictionResult.imagePath = result.imagePath
            predictionResult.scenePredictions = scenePredictions
            predictionResult.resnetPredictions = resnetPredictions
            
            predictions.append(predictionResult)
        }
        
        return predictions
    }
}
