import Foundation

class Interactor: InteractorInput {
    weak var output: InteractorOutput!
    
    init(output: InteractorOutput!) {
        self.output = output
    }
    
    func predictScenes(path: String) {
        ApiAccessor.predictScene(path: path) { result in
            switch result {
            case let .success(result):
                print(result.predictions.count)
            case let .failture(error):
                print(error)
            }
        }
    }
    
    func predictObjects(path: String) {
        ApiAccessor.predictObject(path: path) { result in
            switch result {
            case let .success(result):
                print(result.predictions.count)
            case let .failture(error):
                print(error)
            }
        }
    }
}
