import Foundation

/*
 * Protcol that defines the view input methods.
 */
protocol OperationViewInterface: class {
    
}

/*
 * Protocol that defines the commands sent from View to the Presenter.
 */
protocol OperationPresenterInterface: class {
    func predictButtonPushed()
    func deleteAllData()
}

/*
 * Protcol that defines the commands sent from Presenter.
 */
protocol OperationInteractorInput: class {
    func predictScenes(path: URL)
    func predictObjects(path: URL)
    func deleteAll()
}

/*
 * Protcol that defines the commands sent from the Interacter to the Presenter.
 */
protocol OperationInteractorOutput: class {
    func predictedScenes()
    func predictedObjects()
}

/*
 * Protcol thay defines the commands sent from the Interacter to the RealmAccessor.
 */
protocol RealmAccessorInput: class {
    func saveSceneClassifierPrediction(data: SceneClassifier.ImageData)
    func saveInceptionResnetPrediction(data: InceptionResnet.ImageData)
    func deleteAll()
}

/*
 * Protcol thay defines the commands sent from the RealmAccessor to the Interacter.
 */
protocol RealmAccessorOutput: class {
    
}

