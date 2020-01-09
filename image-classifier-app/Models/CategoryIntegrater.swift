import Foundation

class CategoryIntegrater {
    
    private var categoryCache: CategoryCacheRepository = CategoryCacheRepository()
        
    struct CategoryImagesCount {
        var labelId: Int
        var count: Int
    }
    
    /****カテゴリの枚数が一番少ないカテゴリをターゲットにカテゴリ統合評価が最大になるカテゴリと統合する．****/
    func integrate(categoryAttr: [CategoryAttribute], baseCategoryCount: Int, targetCategoryCount: Int) -> [CategoryAttribute] {
        
        let caches = categoryCache.get(clusterNum: targetCategoryCount)
        if caches.count > 0 { return caches }
        else {
            var sceneCategoryCounts:[CategoryImagesCount] = []
            var categoryAttributes = categoryAttr
            let evaluator = CategoryEvaluationModel()
            var clusteredCount = 0
            
            while(clusteredCount < (baseCategoryCount - targetCategoryCount)) {
                
                sceneCategoryCounts = []
                for labelId in (0...364) {
                    let categoryImages = categoryAttributes.filter({ $0.representativeSceneId == labelId})
                    sceneCategoryCounts.append(CategoryImagesCount(labelId: labelId, count: categoryImages.count))
                }
                
                sceneCategoryCounts.sort(by: { $0.count < $1.count })
                let filteredCategories = sceneCategoryCounts.filter({ $0.count != 0 })
                
                // 枚数が一番少ない統合すべきカテゴリId
                if let targetId = filteredCategories.first?.labelId {
                    let similarList = SimilalityRepositories.getSimilarSceneIds(sceneId: targetId)
                    let filteredSimilarList = similarList.filter({
                        getSameSceneIdCount(categoryAttr: categoryAttributes, sceneId: $0.categoryId1).count > 0 &&
                            getSameSceneIdCount(categoryAttr: categoryAttributes, sceneId: $0.categoryId2).count > 0
                    })
                    
                    var bestEvalution: Double = 0.0
                    var shouldIntegratedCategoryId1: Int = filteredSimilarList[0].categoryId1
                    var shouldIntegratedCategoryId2: Int = filteredSimilarList[0].categoryId2
                    
                    for similarAttr in filteredSimilarList {
                        let evalution = evaluator.evaluateCategories(categotyAttributes: categoryAttributes,
                                                                     fromRepresentativeSceneId: similarAttr.categoryId1,
                                                                     toRepresentativeSceneId: similarAttr.categoryId2)
                        if(evalution > bestEvalution) {
                            bestEvalution = evalution
                            shouldIntegratedCategoryId1 = similarAttr.categoryId1
                            shouldIntegratedCategoryId2 = similarAttr.categoryId2
                        }
                    }
                    
                    let categoryId1Images = categoryAttributes.filter({ $0.representativeSceneId == shouldIntegratedCategoryId1 })
                    let categoryId2Images = categoryAttributes.filter({ $0.representativeSceneId == shouldIntegratedCategoryId2 })
                    let categoryId1Count = PredictionRepositories.getSameSceneIdCount(sceneId: shouldIntegratedCategoryId1)
                    let categoryId2Count = PredictionRepositories.getSameSceneIdCount(sceneId: shouldIntegratedCategoryId2)
                    if( categoryId1Count > categoryId2Count) {
                        for (index,categoryAttribute) in categoryAttributes.enumerated() {
                            if(categoryAttribute.representativeSceneId == shouldIntegratedCategoryId2) {
                                categoryAttributes[index].representativeSceneId = shouldIntegratedCategoryId1 }
                        }
                        print("カテゴリ[\(shouldIntegratedCategoryId2)] \(categoryId2Images.count)枚 >> カテゴリ[\(shouldIntegratedCategoryId1)] \(categoryId1Images.count)枚 \(bestEvalution)")
                        
                    } else {
                        for (index,categoryAttribute) in categoryAttributes.enumerated() {
                            if(categoryAttribute.representativeSceneId == shouldIntegratedCategoryId1) {
                                categoryAttributes[index].representativeSceneId = shouldIntegratedCategoryId2 }
                        }
                        
                        print("カテゴリ[\(shouldIntegratedCategoryId1)] \(categoryId1Images.count)枚 >> カテゴリ[\(shouldIntegratedCategoryId2)] \(categoryId2Images.count)枚 \(bestEvalution)")
                    }
                }
                
                clusteredCount += 1
                let clusterCount = baseCategoryCount - clusteredCount
                categoryCache.save(clusterNum: clusterCount, categoryAttrs: categoryAttributes)
            }
            
            return categoryAttributes
        }
    }
    
    /****カテゴリの枚数を無視してカテゴリ統合評価のみを考慮してカテゴリ統合する****/
//    func integrateOnlyConsideringEvalution(categoryAttr: [CategoryAttribute]) -> [CategoryAttribute] {
//
//        var categoryAttributes = categoryAttr
//        let evaluator = CategoryEvaluationModel()
//        // 代表画像のSceneIdのリストを返します．
//        let representativeSceneIds: [Int] = categoryAttributes.map({ $0.representativeSceneId })
//        let representativeCategories = representativeSceneIds.unique().sorted(by: { $0 < $1 })
//        print("代表画像カテゴリ数：\(representativeCategories.count)")
//
//        var bestEvalution: Double = 0.0
//        var shouldIntegratedCategoryId1: Int = 0
//        var shouldIntegratedCategoryId2: Int = 0
//
//        for id1 in representativeCategories {
//            for id2 in representativeCategories {
//                if(id1 > id2) {
//                    let evalution = evaluator.evaluateCategories(categotyAttributes: categoryAttributes,
//                                                                 fromRepresentativeSceneId: id1,
//                                                                 toRepresentativeSceneId: id2)
//                    if(evalution > bestEvalution) {
//                        bestEvalution = evalution
//                        shouldIntegratedCategoryId1 = id1
//                        shouldIntegratedCategoryId2 = id2
//                    }
//                }
//            }
//        }
//
//        let categoryId1Images = categoryAttributes.filter({ $0.representativeSceneId == shouldIntegratedCategoryId1 })
//        let categoryId2Images = categoryAttributes.filter({ $0.representativeSceneId == shouldIntegratedCategoryId2 })
//        let categoryId1Count = PredictionRepositories.getSameSceneIdCount(sceneId: shouldIntegratedCategoryId1)
//        let categoryId2Count = PredictionRepositories.getSameSceneIdCount(sceneId: shouldIntegratedCategoryId2)
//        if( categoryId1Count > categoryId2Count) {
//            for (index,categoryAttribute) in categoryAttributes.enumerated() {
//                if(categoryAttribute.representativeSceneId == shouldIntegratedCategoryId2) {
//                    categoryAttributes[index].representativeSceneId = shouldIntegratedCategoryId1
//                }
//            }
//            print("カテゴリ[\(shouldIntegratedCategoryId2)] \(categoryId2Images.count)枚 >> カテゴリ[\(shouldIntegratedCategoryId1)] \(categoryId1Images.count)枚 \(bestEvalution)")
//        } else {
//            for (index,categoryAttribute) in categoryAttributes.enumerated() {
//                if(categoryAttribute.representativeSceneId == shouldIntegratedCategoryId1) {
//                    categoryAttributes[index].representativeSceneId = shouldIntegratedCategoryId2
//                }
//            }
//            print("カテゴリ[\(shouldIntegratedCategoryId1)] \(categoryId1Images.count)枚 >> カテゴリ[\(shouldIntegratedCategoryId2)] \(categoryId2Images.count)枚 \(bestEvalution)")
//        }
//
//        return categoryAttributes
//    }
    
    /****カテゴリの枚数が一番少ないカテゴリをターゲットに代表画像同士の類似度が最大のカテゴリと統合する．****/
//    func integrateConsideringSimilality(categoryAttr: [CategoryAttribute]) -> [CategoryAttribute] {
//
//        var sceneCategoryCounts:[CategoryImagesCount] = []
//        var categoryAttributes = categoryAttr
//
//        for labelId in (0...364) {
//            let categoryImages = categoryAttributes.filter({ $0.representativeSceneId == labelId})
//            sceneCategoryCounts.append(CategoryImagesCount(labelId: labelId, count: categoryImages.count))
//        }
//
//        sceneCategoryCounts.sort(by: { $0.count < $1.count })
//        let filteredCategories = sceneCategoryCounts.filter({ $0.count != 0 })
//
//        // 枚数が一番少ない統合すべきカテゴリId
//        if let targetId = filteredCategories.first?.labelId {
//            let similarList = SimilalityRepositories.getSimilarSceneIds(sceneId: targetId)
//            let filteredSimilarList = similarList.filter({
//                CategoryRepositories.getSameSceneIdCount(sceneId: $0.categoryId1).count > 0 &&
//                    CategoryRepositories.getSameSceneIdCount(sceneId: $0.categoryId2).count > 0
//            })
//            if let similarAttr = filteredSimilarList.first {
//                let categoryId1Images = categoryAttributes.filter({ $0.representativeSceneId == similarAttr.categoryId1 })
//                let categoryId2Images = categoryAttributes.filter({ $0.representativeSceneId == similarAttr.categoryId2 })
//                let categoryId1Count = PredictionRepositories.getSameSceneIdCount(sceneId: similarAttr.categoryId1)
//                let categoryId2Count = PredictionRepositories.getSameSceneIdCount(sceneId: similarAttr.categoryId2)
//                if( categoryId1Count > categoryId2Count) {
//                    for (index,categoryAttribute) in categoryAttributes.enumerated() {
//                        if(categoryAttribute.representativeSceneId == similarAttr.categoryId2) {
//                            categoryAttributes[index].representativeSceneId = similarAttr.categoryId1
//                        }
//                    }
//                    print("カテゴリ[\(similarAttr.categoryId2)] \(categoryId2Images.count)枚 >> カテゴリ[\(similarAttr.categoryId1)] \(categoryId1Images.count)枚 \(similarAttr.similality)")
//
//                } else {
//                    for (index,categoryAttribute) in categoryAttributes.enumerated() {
//                        if(categoryAttribute.representativeSceneId == similarAttr.categoryId1) {
//                            categoryAttributes[index].representativeSceneId = similarAttr.categoryId2
//                        }
//                    }
//
//                    print("カテゴリ[\(similarAttr.categoryId1)] \(categoryId1Images.count)枚 >> カテゴリ[\(similarAttr.categoryId2)] \(categoryId2Images.count)枚 \(similarAttr.similality)")
//                }
//            }
//        }
//        return categoryAttributes
//    }
    
    /**** CategoryAttribute内でsceneIdが一致する画像を全て返します．****/
    private func getSameSceneIdCount(categoryAttr: [CategoryAttribute] ,sceneId: Int) -> [CategoryAttribute] {
        return categoryAttr.filter({ $0.representativeSceneId == sceneId})
    }
}
