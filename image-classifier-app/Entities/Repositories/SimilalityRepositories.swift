import Foundation

class SimilalityRepositories {
    
    struct SimilarCategories {
        var categoryId1: Int
        var categoryId2: Int
        var similality: Double
    }
    
    private static var similality: [[Double]]?
    private static var similalityCategories: [SimilarCategories] = []
    
    private static var shouldRewriteSimilalityIds: [Int: [Int]] = [:]
    
    class func getDefaultSimilalities() -> [[Double]] {
        
        if similality != nil {
            return similality!
        }
        
        if let similality = FileAccessor.loadSimilalityJson(){
            self.similality = similality.labels
            return similality.labels
        } else {
            return []
        }
    }
    
    fileprivate class func getSimilality(id1: Int, id2: Int) -> Double? {
        
        if similality != nil {
            return similality![id1][id2]
        }
        
        if let similality = FileAccessor.loadSimilalityJson(){
            self.similality = similality.labels
            return similality.labels[id1][id2]
        } else {
            return nil
        }
    }
    
    // [index 小]：類似度が高い　→ [index 大]：類似度が低い
    class func getSortedSimilality() -> [SimilarCategories] {
        
        if similalityCategories.count != 0 {
            return similalityCategories
        }
        
        for labelId1 in (0...364) {
            for labelId2 in (0...364) {
                if(labelId1 < labelId2) {
                    if let similality = getRewitedSimilality(labelId1: labelId1, labelId2: labelId2, coefficient: 1.5) {
                        similalityCategories.append(SimilarCategories(categoryId1: labelId1,
                                                                      categoryId2: labelId2,
                                                                      similality: similality))
                    }
                }
            }
        }
        
        similalityCategories.sort(by: {$0.similality > $1.similality})
                
        return similalityCategories
    }
    
    fileprivate class func getShouldRewriteSimilalityIds() -> [Int: [Int]] {
        
        if(shouldRewriteSimilalityIds.count != 0) {
            return shouldRewriteSimilalityIds
        }
        
        let predicttionResults = PredictionRepositories.loadPredictionResults()
        for result in predicttionResults {
            var ids:[Int] = []
            for id in 0...4 {
                ids.append(Int(result.scenePredictions[id].labelId)!)
            }
            
            ids.sort(by: { $0 < $1 })
            
            for categoryId in 0...364 {
                for id in ids {
                    if(categoryId == id) {
                        var shouldAppend: Bool = true
                        for key in shouldRewriteSimilalityIds.keys {
                            if(key == categoryId) {
                                shouldAppend = false
                                let wantAppendVals = ids.filter({ $0 > categoryId })
                                guard let existVals = shouldRewriteSimilalityIds[categoryId] else { return [:]}
                                
                                for wantAppendVal in wantAppendVals {
                                    var willAppend = true
                                    for existVal in existVals {
                                        if(wantAppendVal == existVal) {
                                            willAppend = false
                                        }
                                    }

                                    if(willAppend) {
                                        shouldRewriteSimilalityIds[categoryId]!.append(wantAppendVal)
                                        shouldRewriteSimilalityIds[categoryId]?.sort(by: { $0 < $1 })
                                    }
                                }
                            }
                        }
                        
                        if(shouldAppend) {
                            shouldRewriteSimilalityIds.updateValue(ids.filter({ $0 > categoryId }), forKey: categoryId)
                        }
                    }
                }
            }
        }
        
        return shouldRewriteSimilalityIds
    }
    
    fileprivate class func getRewitedSimilality(labelId1: Int, labelId2: Int, coefficient: Double) -> Double? {
        if let shouldRewriteSimilalityIds = getShouldRewriteSimilalityIds()[labelId1]{
            for id in shouldRewriteSimilalityIds {
                if(id == labelId2) {
                    if let similality = getSimilality(id1: labelId1, id2: labelId2) {
                        return fabs(similality) * coefficient
                    }
                }
            }
        }
        
        if let similality = getSimilality(id1: labelId1, id2: labelId2) {
            return similality
        }
        
        return nil
    }
}
