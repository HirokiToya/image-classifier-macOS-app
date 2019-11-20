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
    
    struct CategoryImagesCount {
        var labelId: Int
        var count: Int
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
            return integrateCategories(clusters: clusters, isNumberConsidering: true)
        } else {
            return divideCategories(clusters: clusters)
        }
    }
    
    // 類似度の結果を用いてカテゴリを指定された数に統合します．
    class func integrateCategories(clusters: Int, isNumberConsidering: Bool) -> [Image] {
        
        var images: [Image] = []
        
        CategoryRepositories.categoryAttributes = []
        for result in predictionResults {
            CategoryRepositories.categoryAttributes.append(CategoryAttribute(predictionResult: result,
                                                                             sceneClusteredId: Int(result.scenePredictions[0].labelId)!,
                                                                             objectClusteredName: result.resnetPredictions[0].labelId,
                                                                             scenePriority: true))
        }
        
        // カテゴリ統合にカテゴリ内の枚数を考慮するかどうか
        if(isNumberConsidering) {
            var sceneCategoryCounts:[CategoryImagesCount] = []
            let defaultCategoriesCount = defaultCategorizedImages.count
            var clusteredCount = 0
            
            while(clusteredCount != (defaultCategoriesCount - clusters)) {
                
                sceneCategoryCounts = []
                for labelId in (0...364) {
                    let categoryImages = CategoryRepositories.categoryAttributes.filter({ $0.sceneClusteredId == labelId})
                    sceneCategoryCounts.append(CategoryImagesCount(labelId: labelId, count: categoryImages.count))
                }
                
                sceneCategoryCounts.sort(by: { $0.count < $1.count })
                let filteredCategories = sceneCategoryCounts.filter({ $0.count != 0 })
                
                // 枚数が一番少ない統合すべきカテゴリId
                if let targetId = filteredCategories.first?.labelId {
                    let similarIds = SimilalityRepositories.getSimilarSceneIds(sceneId: targetId)
                    var similalityIndex: Int? = nil
                    for (index,similarId) in similarIds.enumerated() {
                        let categoryId1Images = categoryAttributes.filter({ $0.sceneClusteredId == similarId.categoryId1 })
                        let categoryId2Images = categoryAttributes.filter({ $0.sceneClusteredId == similarId.categoryId2 })
                        
                        if(categoryId1Images.count != 0 && categoryId2Images.count != 0) {
                            similalityIndex = index
                        }
                    }
                    
                    if let similalityIndex = similalityIndex {
                        let categoryId1Images = categoryAttributes.filter({ $0.sceneClusteredId == similarIds[similalityIndex].categoryId1 })
                        let categoryId2Images = categoryAttributes.filter({ $0.sceneClusteredId == similarIds[similalityIndex].categoryId2 })
                        
                        // カテゴリを統合します．
                        if(categoryId1Images.count > categoryId2Images.count) {
                            for (index,categoryAttribute) in CategoryRepositories.categoryAttributes.enumerated() {
                                if(categoryAttribute.sceneClusteredId == similarIds[similalityIndex].categoryId2) {
                                    CategoryRepositories.categoryAttributes[index].sceneClusteredId = similarIds[similalityIndex].categoryId1
                                    print("カテゴリ[\(similarIds[similalityIndex].categoryId2)] \(categoryId2Images.count)枚 >> カテゴリ[\(similarIds[similalityIndex].categoryId1)] \(categoryId1Images.count)枚")
                                }
                            }
                        } else {
                            for (index,categoryAttribute) in CategoryRepositories.categoryAttributes.enumerated() {
                                if(categoryAttribute.sceneClusteredId == similarIds[similalityIndex].categoryId1) {
                                    CategoryRepositories.categoryAttributes[index].sceneClusteredId = similarIds[similalityIndex].categoryId2
                                    print("カテゴリ[\(similarIds[similalityIndex].categoryId1)] \(categoryId1Images.count)枚 >> カテゴリ[\(similarIds[similalityIndex].categoryId2)] \(categoryId2Images.count)枚")
                                }
                            }
                        }
                        
                        clusteredCount += 1
                    }
                }
            }
            
        } else {
            
            let mostSimilarCategories = SimilalityRepositories.getSortedSimilality()
            let defaultCategoriesCount = defaultCategorizedImages.count
            var similalityIndex = 0
            var clusteredCount = 0
            
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
                                print("カテゴリ[\(mostSimilarCategories[similalityIndex].categoryId2)] \(categoryId2Images.count)枚 >> カテゴリ[\(mostSimilarCategories[similalityIndex].categoryId1)] \(categoryId1Images.count)枚")
                            }
                        }
                    } else {
                        for (index,categoryAttribute) in CategoryRepositories.categoryAttributes.enumerated() {
                            if(categoryAttribute.sceneClusteredId == mostSimilarCategories[similalityIndex].categoryId1) {
                                CategoryRepositories.categoryAttributes[index].sceneClusteredId = mostSimilarCategories[similalityIndex].categoryId2
                                print("カテゴリ[\(mostSimilarCategories[similalityIndex].categoryId1)] \(categoryId1Images.count)枚 >> カテゴリ[\(mostSimilarCategories[similalityIndex].categoryId2)] \(categoryId2Images.count)枚")
                            }
                        }
                    }
                    
                    clusteredCount += 1
                }
                
                similalityIndex += 1
            }
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
    
    // カテゴリを指定された数に分割します．
    class func divideCategories(clusters: Int) -> [Image] {
        
        var images: [Image] = []
        CategoryRepositories.categoryAttributes = []
        for result in predictionResults {
            CategoryRepositories.categoryAttributes.append(CategoryAttribute(predictionResult: result,
                                                                             sceneClusteredId: Int(result.scenePredictions[0].labelId)!,
                                                                             objectClusteredName: result.resnetPredictions[0].labelId,
                                                                             scenePriority: true))
        }
        
        var sceneCategoryCounts:[CategoryImagesCount] = []
        let defaultCategoriesCount = defaultCategorizedImages.count
        var clusteredCount = 0
        var loopIndex = 0
        
        while(clusteredCount != (clusters - defaultCategoriesCount)) {
            
            sceneCategoryCounts = []
            for labelId in (0...364) {
                let categoryImages = CategoryRepositories.categoryAttributes
                    .filter({ $0.scenePriority })
                    .filter({ $0.sceneClusteredId == labelId})
                sceneCategoryCounts.append(CategoryImagesCount(labelId: labelId, count: categoryImages.count))
            }
            
            sceneCategoryCounts.sort(by: {$0.count > $1.count})
            
            // カテゴリを分割します．
            if let targetSceneId = sceneCategoryCounts.first?.labelId {
                
                var targetCategoryImages = categoryAttributes
                    .filter({ $0.scenePriority })
                    .filter({ $0.sceneClusteredId == targetSceneId })
                
                if(targetCategoryImages.count != 1) {
                    targetCategoryImages.sort(by: {
                        $0.predictionResult.resnetPredictions[0].probability > $1.predictionResult.resnetPredictions[0].probability })
                    if let resnetPrediction = targetCategoryImages.first?.predictionResult.resnetPredictions[0] {
                        for (index,categoryAttribute) in CategoryRepositories.categoryAttributes.enumerated() {
                            if(targetCategoryImages[0].predictionResult.imagePath == categoryAttribute.predictionResult.imagePath) {
                                CategoryRepositories.categoryAttributes[index].objectClusteredName = resnetPrediction.label
                                CategoryRepositories.categoryAttributes[index].scenePriority = false
                                
                                print("SceneId[\(targetSceneId)]\(targetCategoryImages.count)枚 → ObjectId[\(resnetPrediction.labelId)]")
                                let dividedObjectNames = categoryAttributes
                                    .filter({ !$0.scenePriority })
                                    .filter({ $0.objectClusteredName == resnetPrediction.label })
                                
                                if(dividedObjectNames.count == 1) {
                                    clusteredCount += 1
                                }
                            }
                        }
                    }
                } else {
                    break
                }
            }
            loopIndex += 1
        }
        
        // 統合後表示する画像のリストの生成
        let clusteredCategoryAttributes = CategoryRepositories.categoryAttributes
        
        for label in 0...364 {
            var sceneCategoryImages = clusteredCategoryAttributes
                .filter({ $0.scenePriority})
                .filter({ $0.sceneClusteredId == label })
            
            if(sceneCategoryImages.count > 0) {
                
                sceneCategoryImages.sort(by: { $0.predictionResult.scenePredictions[0].probability > $1.predictionResult.scenePredictions[0].probability})
                let representativeImage = sceneCategoryImages[0].predictionResult
                
                images.append(Image(url: representativeImage.imagePath.url!,
                                    sceneId: Int(representativeImage.scenePredictions[0].labelId)!,
                                    sceneName: representativeImage.scenePredictions[0].label,
                                    sceneProbability: representativeImage.scenePredictions[0].probability,
                                    objectId: representativeImage.resnetPredictions[0].labelId,
                                    objectName: representativeImage.resnetPredictions[0].label,
                                    objectProbability: representativeImage.resnetPredictions[0].probability,
                                    scenePriority: true))
            }
        }
        
        let objectCategoryImages = clusteredCategoryAttributes.filter({!$0.scenePriority})
        if( objectCategoryImages.count > 0 ){
            var dividedCategories:[String] = []
            for objectCategoryImage in objectCategoryImages {
                var targetObjects = objectCategoryImages.filter({ $0.objectClusteredName ==  objectCategoryImage.objectClusteredName})
                targetObjects.sort(by: {
                    $0.predictionResult.resnetPredictions[0].probability > $1.predictionResult.resnetPredictions[0].probability})
                
                if(dividedCategories.filter({ $0 == targetObjects[0].objectClusteredName}).count == 0){
                    dividedCategories.append(targetObjects[0].objectClusteredName)
                    let representativeImage = targetObjects[0].predictionResult
                    images.append(Image(url: representativeImage.imagePath.url!,
                                        sceneId: targetObjects[0].sceneClusteredId,
                                        sceneName: representativeImage.scenePredictions[0].label,
                                        sceneProbability: representativeImage.scenePredictions[0].probability,
                                        objectId: targetObjects[0].objectClusteredName,
                                        objectName: representativeImage.resnetPredictions[0].label,
                                        objectProbability: representativeImage.resnetPredictions[0].probability,
                                        scenePriority: false))
                }
            }
        }
        
        return images
    }
    
    class func getInCategoryImagesCount(sceneId: Int, objectName: String, scenePriority: Bool) -> Int {
        return getCategoryAttributeImages(sceneId: sceneId, objectName: objectName, scenePriority: scenePriority).count
    }
    
    class func getCategoryAttributeImages(sceneId: Int, objectName: String, scenePriority: Bool) -> [Image] {
        
        var images: [Image] = []
        let categoryAttributes = CategoryRepositories.categoryAttributes
        
        if(categoryAttributes.count == 0) {
            
            images = getSceneCategoryImages(sceneId: sceneId)
            
        } else {
            
            if(scenePriority) {
                let categoryImages = categoryAttributes
                    .filter({ $0.scenePriority == scenePriority})
                    .filter({ $0.sceneClusteredId == sceneId})
                
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
                    .filter({ $0.objectClusteredName == objectName })
                
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
}
