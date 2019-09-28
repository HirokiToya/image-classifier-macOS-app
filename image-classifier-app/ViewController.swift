import Cocoa
import Alamofire
import SwiftyJSON

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        Alamofire.request(EndPoints.SceneClassifier.Labels.path(), method: .get).validate().responseJSON {
            res in
            if res.result.isSuccess {
                if let returnValue = res.result.value {
                    print(JSON(returnValue))
                }
            } else {
                print(res.error.debugDescription)
            }
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

