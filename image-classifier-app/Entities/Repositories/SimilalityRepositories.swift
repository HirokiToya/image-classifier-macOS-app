import Foundation

class SimilalityRepositories {
    
    private static var similality: [[Double]]?
    
    class func getSimilalities(id1: Int, id2: Int) -> Double? {
        
        if similality != nil {
            return similality![id1][id2]
        }
        
        if let similality = FileAccessor().loadSimilalityJson(){
            self.similality = similality.labels
            return similality.labels[id1][id2]
        } else {
            return nil
        }
    }
}
