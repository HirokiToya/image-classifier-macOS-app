import Foundation

class OperationPresenter: OperationPresenterInterface {
    weak var view: OperationViewInterface!
    var interactor: OperationInteractorInput!
    
    private var imagePathes:[URL] = [] {
        didSet {
            scenePredictionPathIndex = 0
            objectPredictionPathIndex = 0
            
            print("画像識別開始:\(DebugComponent.getTimeNow())")
            if(imagePathes.count > 0) {
                predictScenes(index: scenePredictionPathIndex)
                predictObjects(index: objectPredictionPathIndex)
            }
        }
    }
    
    private var scenePredictionPathIndex: Int = 0
    private var objectPredictionPathIndex: Int = 0
    
    private var experimentTrialCount = 0 {
        didSet {
            if(experimentTrialCount > UserExperimentComponent.experimentTrialCountMax) {
                experimentTrialCount = 0
            }
        }
    }
        
    init(view: OperationViewInterface!){
        self.view = view
        self.interactor = OperationInteractor(output: self)
    }
    
    func reloadButtonTapped() {
        
    }
    
    func predictButtonTapped() {
        imagePathes = FileAccessor.loadAllImagePathes()
        print("全ての画像の枚数：\(imagePathes.count)")
        
        let predictionResult = PredictionRepositories.loadPredictionResults()
        var shouldPredictImages:[URL] = []
        for path in imagePathes {
            var shouldPredict: Bool = true
            for result in predictionResult {
                if (path == result.imagePath.url!) {
                    shouldPredict = false
                    break
                }
            }
            
            if(shouldPredict) {
                shouldPredictImages.append(path)
            }
        }
        
        if(shouldPredictImages.count > 0) {
            imagePathes = shouldPredictImages
        } else {
            imagePathes = []
        }
        
        print("まだ識別していない画像の枚数：\(imagePathes.count)")
        
    }
    
    func changeExperimentImage() {
        interactor.getExperimentImage(trialCount: experimentTrialCount)
        experimentTrialCount += 1
        DebugComponent.startSelecting(num:experimentTrialCount)
    }
    
    func selectedCorrectImage() {
        DebugComponent.endSelecting(num: experimentTrialCount)
    }
    
    func outputLogButtonTapped() {
        DebugComponent.endExperiment()
    }
    
    func deleteAllData() {
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
            print("シーン識別終了:\(DebugComponent.getTimeNow())")
        }
    }
    
    func predictedObjects() {
        objectPredictionPathIndex += 1
        
        if(objectPredictionPathIndex < imagePathes.count) {
            predictObjects(index: objectPredictionPathIndex)
        } else {
            // 識別の終了をViewに伝える
            print("\(objectPredictionPathIndex)/\(imagePathes.count)")
            print("物体識別終了:\(DebugComponent.getTimeNow())")
        }
    }
    
    func gotExperimentImage(image: URL?) {
        self.view.showExperimentImage(image: image)
    }
}
