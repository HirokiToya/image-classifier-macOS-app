import Foundation

class OperationPresenter: OperationPresenterInterface {
    weak var view: OperationViewInterface!
    var interactor: OperationInteractorInput!
    
    private var imagePathes:[URL] = []
    private var scenePredictionPathIndex: Int = 0
    private var objectPredictionPathIndex: Int = 0
    
    init(view: OperationViewInterface!){
        self.view = view
        self.interactor = OperationInteractor(output: self)
    }
    
    func predictButtonPushed(){
        imagePathes = FileAccessor.loadAllImagePathes()
        scenePredictionPathIndex = 0
        objectPredictionPathIndex = 0
        predictScenes(index: scenePredictionPathIndex)
        predictObjects(index: objectPredictionPathIndex)
    }
    
    func deleteButtonPushed() {
        interactor.deleteAll()
    }
    
    private func predictScenes(index: Int) {
        let path = imagePathes[index]
        print("predict Scenes:[\(String(describing: index))]")
        interactor.predictScenes(path: path)
    }
    
    private func predictObjects(index: Int) {
        let path = imagePathes[index]
        print("predict Objects:[\(String(describing: index))]")
        interactor.predictObjects(path: path)
    }
}


extension OperationPresenter: OperationInteractorOutput {
    
    func predictedScenes() {
        scenePredictionPathIndex += 1
        
        if(scenePredictionPathIndex < imagePathes.count) {
            predictScenes(index: scenePredictionPathIndex)
        } else {
            // 識別の終了をViewに伝える
            print("\(scenePredictionPathIndex)/\(imagePathes.count)")
            print("シーン識別終了")
        }
    }
    
    func predictedObjects() {
        objectPredictionPathIndex += 1
        
        if(objectPredictionPathIndex < imagePathes.count) {
            predictObjects(index: objectPredictionPathIndex)
        } else {
            // 識別の終了をViewに伝える
            print("\(objectPredictionPathIndex)/\(imagePathes.count)")
            print("物体識別終了")
        }
    }
}
