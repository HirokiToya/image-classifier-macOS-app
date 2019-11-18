import Foundation

class SimilalityRepositories {
    
    struct SimilarCategories {
        var categoryId1: Int
        var categoryId2: Int
        var similality: Double
    }
    
    private static var similality: [[Double]]?
    private static var similalityCategories: [SimilarCategories] = []
    
    private static var shouldRewriteSimilalites: [Int: [Int]] = [:]
    
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
                    if let similality = getSimilality(id1: labelId1, id2: labelId2) {
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
    
    class func getShouldRewriteSimilalityIds() -> [Int: [Int]] {
        
        shouldRewriteSimilalites = [:]
        
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
                        for key in shouldRewriteSimilalites.keys {
                            if(key == categoryId) {
                                shouldAppend = false
                                let wantAppendVals = ids.filter({ $0 > categoryId })
                                guard let existVals = shouldRewriteSimilalites[categoryId] else { return [:]}
                                
                                for wantAppendVal in wantAppendVals {
                                    var willAppend = true
                                    for existVal in existVals {
                                        if(wantAppendVal == existVal) {
                                            willAppend = false
                                        }
                                    }

                                    if(willAppend) {
                                        shouldRewriteSimilalites[categoryId]!.append(wantAppendVal)
                                        shouldRewriteSimilalites[categoryId]?.sort(by: { $0 < $1 })
                                    }
                                }
                            }
                        }
                        
                        if(shouldAppend) {
                            shouldRewriteSimilalites.updateValue(ids.filter({ $0 > categoryId }), forKey: categoryId)
                        }
                    }
                }
            }
        }
        
        print("shouldRewriteSimilalites: \(shouldRewriteSimilalites.count)")
        for sim in shouldRewriteSimilalites {
            print("shouldRewriteSimilalites: \(sim)")
        }
        
        return shouldRewriteSimilalites
    }
}
