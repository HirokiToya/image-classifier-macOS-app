import Foundation

class SimilalityRepositories {
    
    private static var similality: [[Double]]?
    private static var similalityCategories: [SimilarCategories] = []
    
    struct SimilarCategories {
        var categoryId1: Int
        var categoryId2: Int
        var similality: Double
    }
    
    class func getSimilalities() -> [[Double]] {
        
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
    
    class func getSimilality(id1: Int, id2: Int) -> Double? {
        
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
}
