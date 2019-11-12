import Foundation

class CategoryRepositories {
    
    struct Image {
        var url: URL
        var sceneId: Int
        var sceneName: String
        var sceneProbability: Double
    }
    
    private static var categoryAttributes: [CategoryAttribute] = []
    
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
    
    // 類似度の結果を用いてカテゴリを指定された数に統合します．
    class func getClusteredImages(clusters: Int) -> [Image] {
        
        struct MostSimilarCategories {
            var categoryId1: Int
            var categoryId2: Int
            var similality: Double
        }
        
        // UIで同じ判定をしているのでコメントアウトします．(物体識別のカテゴリ分けのクラスタリング処理を実装するまで)
//        let sceneRepresentativeImages = getSceneRepresentativeImages()
//        if(clusters > sceneRepresentativeImages.count){
//            return sceneRepresentativeImages
//        }
        
        let predictionResults = PredictionRepositories.getPredictionResults()
        let similalities = SimilalityRepositories.getSimilalities()
        var images: [Image] = []
        
        CategoryRepositories.categoryAttributes = []
        for result in predictionResults {
            CategoryRepositories.categoryAttributes.append(CategoryAttribute(predictionResult: result,
                                                                             sceneClusteredId: Int(result.scenePredictions[0].labelId)!,
                                                                             objectClusteredId: result.resnetPredictions[0].labelId,
                                                                             scenePriority: true))
        }
        
        while(images.count != clusters) {
            
            images = []
            
            // 類似度が最も高い２つのカテゴリIDを取得します．
            var mostSimilarCategories = MostSimilarCategories(categoryId1: 0,
                                                              categoryId2: 0,
                                                              similality: 0.0)
            
            let categoryAttributes = CategoryRepositories.categoryAttributes
            for (index1, categoryAttribute1) in categoryAttributes.enumerated() {
                for (index2, categoryAttribute2) in categoryAttributes.enumerated() {
                    if(index1 < index2) {
                        if(categoryAttribute1.sceneClusteredId != categoryAttribute2.sceneClusteredId) {
                            let categoryId1 = categoryAttribute1.sceneClusteredId
                            let categoryId2 = categoryAttribute2.sceneClusteredId
                            let similality = similalities[categoryId1][categoryId2]
                            if(similality > mostSimilarCategories.similality) {
                                mostSimilarCategories = MostSimilarCategories(categoryId1: categoryId1,
                                                                              categoryId2: categoryId2,
                                                                              similality: similality)
                            }
                        }
                    }
                }
            }
            
            // mostSimilarCategoriesのカテゴリ1とカテゴリ2の画像の枚数を調べます．
            let categoryId1Images = categoryAttributes.filter({ $0.sceneClusteredId == mostSimilarCategories.categoryId1 })
            let categoryId2Images = categoryAttributes.filter({ $0.sceneClusteredId == mostSimilarCategories.categoryId2 })
            
            print("カテゴリ：\(mostSimilarCategories.categoryId1) 枚数：\(categoryId1Images.count)")
            print("カテゴリ：\(mostSimilarCategories.categoryId2) 枚数：\(categoryId2Images.count)")
            
            // カテゴリを統合します．．
            if(categoryId1Images.count > categoryId2Images.count) {
                for (index,categoryAttribute) in CategoryRepositories.categoryAttributes.enumerated() {
                    if(categoryAttribute.sceneClusteredId == mostSimilarCategories.categoryId2) {
                        CategoryRepositories.categoryAttributes[index].sceneClusteredId = mostSimilarCategories.categoryId1
                    }
                }
            } else {
                for (index,categoryAttribute) in CategoryRepositories.categoryAttributes.enumerated() {
                    if(categoryAttribute.sceneClusteredId == mostSimilarCategories.categoryId1) {
                        CategoryRepositories.categoryAttributes[index].sceneClusteredId = mostSimilarCategories.categoryId2
                    }
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
                                        sceneProbability: shoudRepresentativeImage.scenePredictions[0].probability))
                }
            }
            
            print("クラスタリング後のカテゴリ数:\(images.count)")
        }
        
        return images
    }
    
    class func getCategoryAttributeImages(sceneId: Int) -> [Image] {
        
        var images: [Image] = []
        let categoryAttributes = CategoryRepositories.categoryAttributes
        
        if(categoryAttributes.count == 0) {
            return getSceneCategoryImages(sceneId: sceneId)
            
        } else {
            let categoryImages = categoryAttributes.filter({ $0.sceneClusteredId == sceneId})
            
            if(categoryImages.count > 0) {
                for categoryImage in categoryImages {
                    images.append(Image(url: categoryImage.predictionResult.imagePath.url!,
                                        sceneId: Int(categoryImage.predictionResult.scenePredictions[0].labelId)!,
                                        sceneName: categoryImage.predictionResult.scenePredictions[0].label,
                                        sceneProbability: categoryImage.predictionResult.scenePredictions[0].probability))
                }
            }
            
            return images
        }
    }
}
