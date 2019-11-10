import Cocoa

class OperationViewController: NSViewController, OperationViewInterface {
    
    var presenter: OperationPresenterInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = OperationPresenter(view: self)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func predict(_ sender: Any) {
        presenter.predictButtonPushed()
    }
    
    @IBAction func predictRestart(_ sender: Any) {
        presenter.predictRestartButtonPushed()
    }
    
    @IBAction func cleanDataBase(_ sender: Any) {
//        presenter.deleteButtonPushed()
    }
    
    @IBAction func reloadData(_ sender: Any) {
        NotificationCenter.default.post(name: .reloadCategoryImages, object: nil)
    }
}
