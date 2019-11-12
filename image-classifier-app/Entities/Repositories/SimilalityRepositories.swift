import Foundation

class SimilalityRepositories {
    
    private static var similality: [[Double]]?
    
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
        let predictionResult = PredictionRepositories.getPredictionResults()
        
        
        for labelId1 in 0...364 {
            for labelId2 in 0...364 {
                
            }
        }
        return []
    }
}
