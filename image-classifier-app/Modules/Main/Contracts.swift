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
    
}

/*
 * Protcol that defines the commands sent from Presenter.
 */
protocol InteractorInput: class {
   
}

/*
 * Protcol that defines the commands sent from the Interacter to the Presenter.
 */
protocol InteractorOutput: class {
    
}


