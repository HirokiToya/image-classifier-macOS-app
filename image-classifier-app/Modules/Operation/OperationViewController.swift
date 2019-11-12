import Cocoa

class OperationViewController: NSViewController, OperationViewInterface {
    
    @IBOutlet weak var currentClustersLabel: NSTextField!
    @IBOutlet weak var clustersLabel: NSTextField!
    
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
        
    @IBAction func predictRestart(_ sender: Any) {
        presenter.predictButtonPushed()
    }
        
    @IBAction func reloadData(_ sender: Any) {
        NotificationCenter.default.post(name: .reloadCategoryImages, object: nil)
    }
    
    @IBAction func performClustering(_ sender: Any) {
        let clusters = ["clusters": Int(clustersLabel.intValue)]
        NotificationCenter.default.post(name: .performClustering, object: nil, userInfo: clusters)
    }
}
