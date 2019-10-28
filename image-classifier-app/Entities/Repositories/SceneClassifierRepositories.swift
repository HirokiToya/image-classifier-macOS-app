import Foundation

class SceneClassifierRepositories {
    
    private static var labels: [SceneClassifier.Label] = []
    private static var sceneClassifierImages: [SceneClassifier.ImageData] = []
    
    class func getLabels() -> [SceneClassifier.Label] {
        
        if !labels.isEmpty {
            return labels
        }
        
        let list = ApiAccessor().getSceneLabelList()
        labels = list.labels.map {
            SceneClassifier.Label(id: $0.id, name: $0.name)
        }
        
        return labels
    }
    
    class func getSceneClassifierImages() -> [SceneClassifier.ImageData] {

        if !sceneClassifierImages.isEmpty {
            return sceneClassifierImages
        }
        
        sceneClassifierImages = []
        let imageNames = FileAccessor().loadAllImagesPaths()
        print(imageNames)
        
        for imageName in imageNames {
            print(imageName)
            let imagePath = "Documents/input/images/\(imageName)"
            print(imagePath)
            
            if let result = ApiAccessor().predictScene(path: imagePath, withName: imageName, fileName: imageName){
                let predictions = result.predictions.map {
                    SceneClassifier.Prediction(labelId: $0.labelId, label: $0.label, probability: $0.probability)
                }
                
                let imageData = SceneClassifier.ImageData(imageName: imageName, imagePath: imagePath, predictions: predictions)
                sceneClassifierImages.append(imageData)
            }
        }
        
        return sceneClassifierImages
    }
}
