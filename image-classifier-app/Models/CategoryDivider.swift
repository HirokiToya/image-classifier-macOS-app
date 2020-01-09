import Foundation

class CategoryDivider {
    
    private var categoryCache: CategoryCacheRepository = CategoryCacheRepository()
    
    struct CategoryImagesCount {
        var labelId: Int
        var count: Int
    }
    
    func divide(categoryAttr: [CategoryAttribute], baseCategoryCount: Int, targetCategoryCount: Int) -> [CategoryAttribute] {
        
        let caches = categoryCache.get(clusterNum: targetCategoryCount)
        if caches.count > 0 { return caches }
        else {
            var sceneCategoryCounts:[CategoryImagesCount] = []
            var categoryAttributes = categoryAttr
            var clusteredCount = 0
            
            while(clusteredCount < (targetCategoryCount - baseCategoryCount)) {
                
                sceneCategoryCounts = []
                for labelId in (0...364) {
                    let categoryImages = categoryAttributes
                        .filter({ $0.scenePriority })
                        .filter({ $0.representativeSceneId == labelId})
                    sceneCategoryCounts.append(CategoryImagesCount(labelId: labelId, count: categoryImages.count))
                }
                
                sceneCategoryCounts.sort(by: {$0.count > $1.count})
                
                // カテゴリを分割します．
                if let targetSceneId = sceneCategoryCounts.first?.labelId {
                    
                    var targetCategoryImages = categoryAttributes
                        .filter({ $0.scenePriority })
                        .filter({ $0.representativeSceneId == targetSceneId })
                    
                    if(targetCategoryImages.count != 1) {
                        targetCategoryImages.sort(by: {
                            $0.predictionResult.resnetPredictions[0].probability > $1.predictionResult.resnetPredictions[0].probability })
                        if let resnetPrediction = targetCategoryImages.first?.predictionResult.resnetPredictions[0] {
                            for (index,categoryAttribute) in categoryAttributes.enumerated() {
                                if(targetCategoryImages[0].predictionResult.imagePath == categoryAttribute.predictionResult.imagePath) {
                                    categoryAttributes[index].representativeObjectName = resnetPrediction.label
                                    categoryAttributes[index].scenePriority = false
                                    
                                    print("SceneId[\(targetSceneId)]\(targetCategoryImages.count)枚 → ObjectId[\(resnetPrediction.labelId)]")
                                    let dividedObjectNames = categoryAttributes
                                        .filter({ !$0.scenePriority })
                                        .filter({ $0.representativeObjectName == resnetPrediction.label })
                                    
                                    if(dividedObjectNames.count == 1) {
                                        clusteredCount += 1
                                        let clusterCount = baseCategoryCount + clusteredCount
                                        categoryCache.save(clusterNum: clusterCount, categoryAttrs: categoryAttributes)
                                    }
                                }
                            }
                        }
                    }
                    else { break }
                }
            }
            return categoryAttributes
        }
    }
}
