import Foundation

class Presenter: PresenterInterface {
    weak var view: ViewInterface!
    var interactor: InteractorInput!
    
    init(view: ViewInterface!){
        self.view = view
        self.interactor = Interactor(output: self)
    }
    
    func predictButtonPushed(){
        
        let imageNames = FileAccessor.loadAllImageNames()
        for image in imageNames {
            print(image)
        }
        
        interactor.predictScenes(path: "Documents/input/images/5979752.jpg")
        interactor.predictObjects(path: "Documents/input/images/5979752.jpg")
    }
}


extension Presenter: InteractorOutput {
    
}
