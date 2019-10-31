//
//  Contracts.swift
//  image-classifier-app
//
//  Created by 外谷弘樹 on 2019/10/28.
//  Copyright © 2019 example. All rights reserved.
//

import Foundation

/*
 * Protcol that defines the view input methods.
 */
protocol ViewInterface: class {
    
}

/*
 * Protocol that defines the commands sent from View to the Presenter.
 */
protocol PresenterInterface: class {
    func predictButtonPushed()
}

/*
 * Protcol that defines the commands sent from Presenter.
 */
protocol InteractorInput: class {
    func predictScenes(path: URL)
    func predictObjects(path: URL)
}

/*
 * Protcol that defines the commands sent from the Interacter to the Presenter.
 */
protocol InteractorOutput: class {
    
}

/*
 * Protcol thay defines the commands sent from the Interacter to the RealmAccessor.
 */
protocol RealmAccessorInput: class {
    func saveSceneClassifierPrediction(data: SceneClassifier.ImageData)
}

/*
 * Protcol thay defines the commands sent from the RealmAccessor to the Interacter.
 */
protocol RealmAccessorOutput: class {
    
}

