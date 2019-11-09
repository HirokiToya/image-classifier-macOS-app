import Cocoa

class OperationViewController: NSViewController, ViewInterface {
    
    var presenter: PresenterInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = Presenter(view: self)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func pushButton(_ sender: Any) {
//        presenter.predictButtonPushed()
        print("pushButton1")
        
    }
    
    @IBAction func deleteButtonPushed(_ sender: Any) {
//        presenter.deleteButtonPushed()
        print("pushButton2")
    }
}
