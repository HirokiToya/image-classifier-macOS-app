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
        var evaluation: Double?
        var scenePriority: Bool
    }
        
    private static var categoryAttributes: [CategoryAttribute] = []
    private static var predictionResults: [PredictionResult] = PredictionRepositories.loadPredictionResults()
    private static var defaultCategorizedImages:[Image] = []
    private static var integrater = CategoryIntegrater()
    private static var divider = CategoryDivider()
        
    class func reloadCaches() {
        categoryAttributes = []
        predictionResults = PredictionRepositories.loadPredictionResults()
        defaultCategorizedImages = []
    }
    
    /**** デフォルトシーン分類での代表画像を取得します****/
    class func getSceneRepresentativeImages() -> [Image] {
        
        if(defaultCategorizedImages.count > 0) {
            return defaultCategorizedImages
        } else {
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
            
            defaultCategorizedImages = sceneCategories
            
            return defaultCategorizedImages
        }
    }
    
    /**** デフォルトシーン分類でsceneIdが一致する全ての画像を取得します****/
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
    
    /**** 選択した代表画像のカテゴリ内に含まれる画像を返します．****/
    class func getSceneCategoryImages(sceneId: Int, objectName: String, scenePriority: Bool) -> [Image] {
        
        var images: [Image] = []
        let categoryAttributes = CategoryRepositories.categoryAttributes
        
        if(categoryAttributes.count == 0) {
            
            images = getSceneCategoryImages(sceneId: sceneId)
            
        } else {
            
            if(scenePriority) {
                let categoryImages = categoryAttributes
                    .filter({ $0.scenePriority == scenePriority})
                    .filter({ $0.representativeSceneId == sceneId})
                
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
                
            } else {
                let categoryImages = categoryAttributes
                    .filter({ $0.scenePriority == scenePriority})
                    .filter({ $0.representativeObjectName == objectName })
                
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
            }
        }
        
        return images
    }
    
    class func generateRepresentativeImages(categoryAttributes: [CategoryAttribute]) -> [Image] {
        
        // 統合後表示する代表画像のリストの生成
        var images: [Image] = []
        for label in 0...364 {
            let sceneCategoryImages = categoryAttributes
                .filter({ $0.scenePriority})
                .filter({ $0.representativeSceneId == label })
                .filter({ Int($0.predictionResult.scenePredictions[0].labelId)! == label})
            
            if(sceneCategoryImages.count > 0) {
                let categoryEvaluationModel = CategoryEvaluationModel()
                var shoudRepresentativeImage = sceneCategoryImages[0].predictionResult
                for image in sceneCategoryImages {
                    if(image.predictionResult.scenePredictions[0].probability > shoudRepresentativeImage.scenePredictions[0].probability){
                        shoudRepresentativeImage = image.predictionResult
                    }
                }
                
                let evolutionResult = categoryEvaluationModel.evaluateCategory(
                    categotyAttributes: categoryAttributes,
                    representativeSceneId: Int(shoudRepresentativeImage.scenePredictions[0].labelId)!
                )
//                print("代表画像:\(shoudRepresentativeImage.scenePredictions[0].labelId)のカテゴリ評価値：\(evolutionResult)")
//                print("---------------------------")
                
                images.append(Image(url: shoudRepresentativeImage.imagePath.url!,
                                    sceneId: Int(shoudRepresentativeImage.scenePredictions[0].labelId)!,
                                    sceneName: shoudRepresentativeImage.scenePredictions[0].label,
                                    sceneProbability: shoudRepresentativeImage.scenePredictions[0].probability,
                                    objectId: shoudRepresentativeImage.resnetPredictions[0].labelId,
                                    objectName: shoudRepresentativeImage.resnetPredictions[0].label,
                                    objectProbability: shoudRepresentativeImage.resnetPredictions[0].probability,
                                    evaluation: evolutionResult,
                                    scenePriority: true))
            }
        }
        
        let objectCategoryImages = categoryAttributes.filter({!$0.scenePriority})
        if( objectCategoryImages.count > 0 ){
            var dividedCategories:[String] = []
            for objectCategoryImage in objectCategoryImages {
                var targetObjects = objectCategoryImages.filter({ $0.representativeObjectName ==  objectCategoryImage.representativeObjectName})
                targetObjects.sort(by: {
                    $0.predictionResult.resnetPredictions[0].probability > $1.predictionResult.resnetPredictions[0].probability})
                
                if(dividedCategories.filter({ $0 == targetObjects[0].representativeObjectName}).count == 0){
                    dividedCategories.append(targetObjects[0].representativeObjectName)
                    let representativeImage = targetObjects[0].predictionResult
                    images.append(Image(url: representativeImage.imagePath.url!,
                                        sceneId: targetObjects[0].representativeSceneId,
                                        sceneName: representativeImage.scenePredictions[0].label,
                                        sceneProbability: representativeImage.scenePredictions[0].probability,
                                        objectId: targetObjects[0].representativeObjectName,
                                        objectName: representativeImage.resnetPredictions[0].label,
                                        objectProbability: representativeImage.resnetPredictions[0].probability,
                                        scenePriority: false))
                }
            }
        }
        
        return images
    }
        
    /**** sceneIdが属する親カテゴリの代表画像を返します．****/
    class func getRepresentativeImage(sceneId: Int) -> Image? {
        
        if let representativeCategoryId = CategoryRepositories
            .categoryAttributes
            .filter({ Int($0.predictionResult.scenePredictions[0].labelId)! == sceneId})
            .first?
            .representativeSceneId
        {
            
            let representaticeImages = predictionResults.filter({ Int($0.scenePredictions[0].labelId) == representativeCategoryId})
            
            var shoudRepresentativeImage = representaticeImages[0]
            for image in representaticeImages {
                if(image.resnetPredictions[0].probability > shoudRepresentativeImage.scenePredictions[0].probability){
                    shoudRepresentativeImage = image
                }
            }
            
            let image  = Image(url: shoudRepresentativeImage.imagePath.url!,
                               sceneId: Int(shoudRepresentativeImage.scenePredictions[0].labelId)!,
                               sceneName: shoudRepresentativeImage.scenePredictions[0].label,
                               sceneProbability: shoudRepresentativeImage.scenePredictions[0].probability,
                               objectId: shoudRepresentativeImage.resnetPredictions[0].labelId,
                               objectName: shoudRepresentativeImage.resnetPredictions[0].label,
                               objectProbability: shoudRepresentativeImage.resnetPredictions[0].probability,
                               scenePriority: true)
            return image
        }
        
        return nil
    }
}

/****カテゴリ統合処理****/
extension CategoryRepositories {
    
    class func integrateCategories(clusters: Int) -> [Image] {
        
        categoryAttributes = []
        for result in predictionResults {
            categoryAttributes.append(CategoryAttribute(predictionResult: result,
                                                        representativeSceneId: Int(result.scenePredictions[0].labelId)!,
                                                        representativeObjectName: result.resnetPredictions[0].labelId,
                                                        scenePriority: true))
        }
        
        categoryAttributes = integrater.integrate(categoryAttr: categoryAttributes,
                                                  baseCategoryCount: defaultCategorizedImages.count,
                                                  targetCategoryCount: clusters)
        
        return generateRepresentativeImages(categoryAttributes: categoryAttributes)
    }
}


/****カテゴリ分割処理****/
extension CategoryRepositories {
    
    class func divideCategories(clusters: Int) -> [Image] {
        
        categoryAttributes = []
        for result in predictionResults {
            categoryAttributes.append(CategoryAttribute(predictionResult: result,
                                                        representativeSceneId: Int(result.scenePredictions[0].labelId)!,
                                                        representativeObjectName: result.resnetPredictions[0].labelId,
                                                        scenePriority: true))
        }
        
        categoryAttributes = divider.divide(categoryAttr: categoryAttributes,
                                            baseCategoryCount: defaultCategorizedImages.count,
                                            targetCategoryCount: clusters)
        return generateRepresentativeImages(categoryAttributes: categoryAttributes)
    }
}
