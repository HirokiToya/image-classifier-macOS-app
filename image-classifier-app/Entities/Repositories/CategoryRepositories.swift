import Foundation

class CategoryRepositories {
    
    struct Image {
        var url: URL
        var sceneId: Int
        var sceneName: String
        var sceneProbability: Double
    }
    
    // 同一のシーンカテゴリ名の中から識別確率が最も高い画像をそれぞれ取得します．
    class func getSceneRepresentativeImages() -> [Image] {
        
        var sceneCategories: [Image] = []
        let predictionResults = PredictionRepositories.getPredictionResults()
        
        for label in 0...364 {
            
            let sameCategoryImages = predictionResults.filter({ Int($0.scenePredictions[0].labelId) == label})
            
            if(sameCategoryImages.count > 0) {
                print("\(sameCategoryImages[0].scenePredictions[0].label)[\(label)]：\(sameCategoryImages.count)枚")
                
                var shoudRepresentativeImage = sameCategoryImages[0]
                for image in sameCategoryImages {
                    if(image.scenePredictions[0].probability > shoudRepresentativeImage.scenePredictions[0].probability){
                        shoudRepresentativeImage = image
                    }
                }
                
                sceneCategories.append(Image(url: shoudRepresentativeImage.imagePath.url!,
                                             sceneId: Int(shoudRepresentativeImage.scenePredictions[0].labelId)!,
                                             sceneName: shoudRepresentativeImage.scenePredictions[0].label,
                                             sceneProbability: shoudRepresentativeImage.scenePredictions[0].probability))
            }
            
        }
        
        return sceneCategories
    }
    
    // 同一のシーンカテゴリ名の画像を全て取得します．
    class func getSceneCategoryImages(sceneId: Int) -> [Image] {
        
        var images: [Image] = []
        let predictionResults = PredictionRepositories.getPredictionResults()
        
        let sameCategoryImages = predictionResults.filter({ Int($0.scenePredictions[0].labelId) == sceneId})
        
        if(sameCategoryImages.count > 0) {
            
            for sameCategoryImage in sameCategoryImages {
                images.append(Image(url: sameCategoryImage.imagePath.url!,
                                    sceneId: Int(sameCategoryImage.scenePredictions[0].labelId)!,
                                    sceneName: sameCategoryImage.scenePredictions[0].label,
                                    sceneProbability: sameCategoryImage.scenePredictions[0].probability))
            }
        }
        
        return images
    }
    
}
