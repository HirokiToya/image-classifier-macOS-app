import Foundation

class Presenter: PresenterInterface {
    weak var view: ViewInterface!
    var interactor: InteractorInput!
    
    init(view: ViewInterface!){
        self.view = view
        self.interactor = Interactor(output: self)
    }
    
    func predictButtonPushed(){
        
        let imagePathes = FileAccessor.loadAllImagePathes()
        for path in imagePathes {
            interactor.predictScenes(path: path)
//            interactor.predictObjects(path: path)
        }
    }
}


extension Presenter: InteractorOutput {
    
}
