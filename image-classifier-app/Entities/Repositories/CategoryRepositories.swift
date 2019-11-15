import Foundation

class CategoryRepositories {
    
    struct Image {
        var url: URL
        var sceneId: Int
        var sceneName: String
        var sceneProbability: Double
        var objectId: String
        var objectName: String
        var objectProbability: Double
        var scenePriority: Bool
    }
    
    private static var categoryAttributes: [CategoryAttribute] = []
    private static var predictionResults: [PredictionResult] = PredictionRepositories.loadPredictionResults()
    private static var defaultCategorizedImages:[Image] = getSceneRepresentativeImages()
    
    class func reloadCaches() {
        categoryAttributes = []
        predictionResults = PredictionRepositories.loadPredictionResults()
        defaultCategorizedImages = getSceneRepresentativeImages()
    }
    
    // 同一のシーンカテゴリ名の中から識別確率が最も高い画像をそれぞれ取得します．
    class func getSceneRepresentativeImages() -> [Image] {
        
        var sceneCategories: [Image] = []
                
        for label in 0...364 {
            let sameCategoryImages = predictionResults.filter({ Int($0.scenePredictions[0].labelId) == label})
            
            if(sameCategoryImages.count > 0) {
                
                var shoudRepresentativeImage = sameCategoryImages[0]
                for image in sameCategoryImages {
                    if(image.scenePredictions[0].probability > shoudRepresentativeImage.scenePredictions[0].probability){
                        shoudRepresentativeImage = image
                    }
                }
                
                sceneCategories.append(Image(url: shoudRepresentativeImage.imagePath.url!,
                                             sceneId: Int(shoudRepresentativeImage.scenePredictions[0].labelId)!,
                                             sceneName: shoudRepresentativeImage.scenePredictions[0].label,
                                             sceneProbability: shoudRepresentativeImage.scenePredictions[0].probability,
                                             objectId: shoudRepresentativeImage.resnetPredictions[0].labelId,
                                             objectName: shoudRepresentativeImage.resnetPredictions[0].label,
                                             objectProbability: shoudRepresentativeImage.resnetPredictions[0].probability,
                                             scenePriority: true))
            }
            
        }
        
        return sceneCategories
    }
    
    // 同一のシーンカテゴリ名の画像を全て取得します．
    class func getSceneCategoryImages(sceneId: Int) -> [Image] {
        
        var images: [Image] = []
        let sameCategoryImages = predictionResults.filter({ Int($0.scenePredictions[0].labelId) == sceneId})
        
        if(sameCategoryImages.count > 0) {
            
            for sameCategoryImage in sameCategoryImages {
                images.append(Image(url: sameCategoryImage.imagePath.url!,
                                    sceneId: Int(sameCategoryImage.scenePredictions[0].labelId)!,
                                    sceneName: sameCategoryImage.scenePredictions[0].label,
                                    sceneProbability: sameCategoryImage.scenePredictions[0].probability,
                                    objectId: sameCategoryImage.resnetPredictions[0].labelId,
                                    objectName: sameCategoryImage.resnetPredictions[0].label,
                                    objectProbability: sameCategoryImage.resnetPredictions[0].probability,
                                    scenePriority: true))
            }
        }
        
        return images
    }
    
    class func clusterCategories(clusters: Int) -> [Image]{
        
        if(clusters < defaultCategorizedImages.count){
            return integrateCategories(clusters: clusters)
        } else {
            return divideCategories(clusters: clusters)
        }
    }
    
    // 類似度の結果を用いてカテゴリを指定された数に統合します．
    class func integrateCategories(clusters: Int) -> [Image] {
        
        var images: [Image] = []
        
        CategoryRepositories.categoryAttributes = []
        for result in predictionResults {
            CategoryRepositories.categoryAttributes.append(CategoryAttribute(predictionResult: result,
                                                                             sceneClusteredId: Int(result.scenePredictions[0].labelId)!,
                                                                             objectClusteredName: result.resnetPredictions[0].labelId,
                                                                             scenePriority: true))
        }
        
        let mostSimilarCategories = SimilalityRepositories.getSortedSimilality()
        let defaultCategoriesCount = defaultCategorizedImages.count
        var similalityIndex = 0
        var clusteredCount = 0
        print("類似度の個数：\(mostSimilarCategories.count)")
        
        while(clusteredCount != (defaultCategoriesCount - clusters)) {
            // 類似度が最も高い２つのカテゴリIDを取得します．
            let categoryId1Images = categoryAttributes.filter({ $0.sceneClusteredId == mostSimilarCategories[similalityIndex].categoryId1 })
            let categoryId2Images = categoryAttributes.filter({ $0.sceneClusteredId == mostSimilarCategories[similalityIndex].categoryId2 })
            
            if(categoryId1Images.count != 0 && categoryId2Images.count != 0){
                
                // カテゴリを統合します．
                if(categoryId1Images.count > categoryId2Images.count) {
                    for (index,categoryAttribute) in CategoryRepositories.categoryAttributes.enumerated() {
                        if(categoryAttribute.sceneClusteredId == mostSimilarCategories[similalityIndex].categoryId2) {
                            CategoryRepositories.categoryAttributes[index].sceneClusteredId = mostSimilarCategories[similalityIndex].categoryId1
                            print("カテゴリ[\(mostSimilarCategories[similalityIndex].categoryId2)] \(categoryId2Images.count)枚 → カテゴリ[\(mostSimilarCategories[similalityIndex].categoryId1)] \(categoryId1Images.count)枚")
                        }
                    }
                } else {
                    for (index,categoryAttribute) in CategoryRepositories.categoryAttributes.enumerated() {
                        if(categoryAttribute.sceneClusteredId == mostSimilarCategories[similalityIndex].categoryId1) {
                            CategoryRepositories.categoryAttributes[index].sceneClusteredId = mostSimilarCategories[similalityIndex].categoryId2
                            print("カテゴリ[\(mostSimilarCategories[similalityIndex].categoryId1)] \(categoryId1Images.count)枚 → カテゴリ[\(mostSimilarCategories[similalityIndex].categoryId2)] \(categoryId2Images.count)枚")
                        }
                    }
                }
                
                clusteredCount += 1
            }
            
            similalityIndex += 1
        }
        
        // 統合後表示する画像のリストの生成
        let clusteredCategoryAttributes = CategoryRepositories.categoryAttributes
        for label in 0...364 {
            let categoryImages = clusteredCategoryAttributes
                .filter({ $0.sceneClusteredId == label })
                .filter({ Int($0.predictionResult.scenePredictions[0].labelId)! == label})
            
            if(categoryImages.count > 0) {
                var shoudRepresentativeImage = categoryImages[0].predictionResult
                for image in categoryImages {
                    if(image.predictionResult.scenePredictions[0].probability > shoudRepresentativeImage.scenePredictions[0].probability){
                        shoudRepresentativeImage = image.predictionResult
                    }
                }
                
                images.append(Image(url: shoudRepresentativeImage.imagePath.url!,
                                    sceneId: Int(shoudRepresentativeImage.scenePredictions[0].labelId)!,
                                    sceneName: shoudRepresentativeImage.scenePredictions[0].label,
                                    sceneProbability: shoudRepresentativeImage.scenePredictions[0].probability,
                                    objectId: shoudRepresentativeImage.resnetPredictions[0].labelId,
                                    objectName: shoudRepresentativeImage.resnetPredictions[0].label,
                                    objectProbability: shoudRepresentativeImage.resnetPredictions[0].probability,
                                    scenePriority: true))
            }
        }
        
        return images
    }
    
    class func divideCategories(clusters: Int) -> [Image] {
        print("未実装項目です．")
        return []
    }
    
    class func getCategoryAttributeImages(sceneId: Int, objectName: String, scenePriority: Bool) -> [Image] {
        
        var images: [Image] = []
        let categoryAttributes = CategoryRepositories.categoryAttributes
        
        if(categoryAttributes.count == 0) {
            
            images = getSceneCategoryImages(sceneId: sceneId)
            images.sort(by: {$0.sceneProbability > $1.sceneProbability})
            
        } else {
            
            if(scenePriority) {
                let categoryImages = categoryAttributes.filter({ $0.sceneClusteredId == sceneId})
                if(categoryImages.count > 0) {
                    for categoryImage in categoryImages {
                        images.append(Image(url: categoryImage.predictionResult.imagePath.url!,
                                            sceneId: Int(categoryImage.predictionResult.scenePredictions[0].labelId)!,
                                            sceneName: categoryImage.predictionResult.scenePredictions[0].label,
                                            sceneProbability: categoryImage.predictionResult.scenePredictions[0].probability,
                                            objectId: categoryImage.predictionResult.resnetPredictions[0].labelId,
                                            objectName: categoryImage.predictionResult.resnetPredictions[0].label,
                                            objectProbability: categoryImage.predictionResult.resnetPredictions[0].probability,
                                            scenePriority: true))
                    }
                }
                images.sort(by: {$0.sceneProbability > $1.sceneProbability})
                
            } else {
                let categoryImages = categoryAttributes.filter({ $0.objectClusteredName == objectName })
                if(categoryImages.count > 0) {
                    for categoryImage in categoryImages {
                        images.append(Image(url: categoryImage.predictionResult.imagePath.url!,
                                            sceneId: Int(categoryImage.predictionResult.scenePredictions[0].labelId)!,
                                            sceneName: categoryImage.predictionResult.scenePredictions[0].label,
                                            sceneProbability: categoryImage.predictionResult.scenePredictions[0].probability,
                                            objectId: categoryImage.predictionResult.resnetPredictions[0].labelId,
                                            objectName: categoryImage.predictionResult.resnetPredictions[0].label,
                                            objectProbability: categoryImage.predictionResult.resnetPredictions[0].probability,
                                            scenePriority: false))
                    }
                }
                images.sort(by: {$0.objectProbability > $1.objectProbability})
            }
        }
        
        return images
    }
}
