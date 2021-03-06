import Foundation

class SceneClassifierRepositories {
    
    private static var labels: [SceneClassifier.Label] = []
    
    class func getLabels() -> [SceneClassifier.Label] {
        
        if !labels.isEmpty {
            return labels
        }
        
        ApiAccessor.getSceneLabelList() { result in
            switch result {
            case let .success(result):
                labels = result.labels.map {
                    SceneClassifier.Label(id: $0.id, name: $0.name)
                }
            case let .failture(error):
                print(error)
            }
        }
        
        return labels
    }
    
    class func getLabelName(id: Int) -> String {
        
        if !labels.isEmpty {
            let name = labels.filter({ Int($0.id)! == id })
            return "\(name.first!.id)"
        }
        
        ApiAccessor.getSceneLabelList() { result in
            switch result {
            case let .success(result):
                labels = result.labels.map {
                    SceneClassifier.Label(id: $0.id, name: $0.name)
                }
            case let .failture(error):
                print(error)
            }
        }
        
        let name = labels.filter({ Int($0.id)! == id })
        return "\(name.first!.id)"
    }
}
