import Foundation

class SceneClassifierRepositories {
    
    private static var labels: [SceneClassifier.Label] = []
//    private static var sceneClassifierImages: [SceneClassifier.ImageData] = []
    
    class func getLabels() -> [SceneClassifier.Label] {
        
        if !labels.isEmpty {
            return labels
        }
        
        ApiAccessor.getSceneLabelList() { result in
            switch result {
            case let .success(result):
                labels = result.labels.map {
                    SceneClassifier.Label(id: $0.id, name: $0.name)
                }
            case let .failture(error):
                print(error)
            }
        }
        
        return labels
    }
    
//    class func getSceneClassifierImages() -> [SceneClassifier.ImageData] {
//
//        if !sceneClassifierImages.isEmpty {
//            return sceneClassifierImages
//        }
//
//        sceneClassifierImages = []
//        let imageNames = FileAccessor().loadAllImagesPaths()
//        print(imageNames)
//
//        for imageName in imageNames {
//            print(imageName)
//            let imagePath = "Documents/input/images/\(imageName)"
//            print(imagePath)
//
//            if let result = ApiAccessor().predictScene(path: imagePath){
//                let predictions = result.predictions.map {
//                    SceneClassifier.Prediction(labelId: $0.labelId, label: $0.label, probability: $0.probability)
//                }
//
//                let imageData = SceneClassifier.ImageData(imageName: imageName, imagePath: imagePath, predictions: predictions)
//                sceneClassifierImages.append(imageData)
//            }
//        }
//
//        return sceneClassifierImages
//    }
}
