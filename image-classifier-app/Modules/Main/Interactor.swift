import Foundation

class Interactor: InteractorInput {
    weak var output: InteractorOutput!
    
    init(output: InteractorOutput!) {
        self.output = output
    }
}
