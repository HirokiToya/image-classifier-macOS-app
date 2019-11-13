import Cocoa

class OperationViewController: NSViewController, OperationViewInterface {
    
    @IBOutlet weak var currentClustersLabel: NSTextField!
    @IBOutlet weak var clustersLabel: NSTextField!
    
    var presenter: OperationPresenterInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = OperationPresenter(view: self)
        NotificationCenter.default.addObserver(self, selector: #selector(setCurrentClustersLabel(notification:)), name: .setCategoryCountLabel, object: nil)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func selectImageFolder(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select an image folder."
        
        let response = panel.runModal()
        if response == NSApplication.ModalResponse.OK {
            guard let selectedURL = panel.url else { return }
            print("フォルダパス：\(selectedURL)")
            presenter.deleteAllData()
            FilePathes.setImageFolderPath(relativePath: selectedURL)
        }
    }
    
    @IBAction func predictStart(_ sender: Any) {
        presenter.predictButtonPushed()
    }
        
    @IBAction func reloadData(_ sender: Any) {
        NotificationCenter.default.post(name: .reloadCategoryImages, object: nil)
    }
    
    @IBAction func performClustering(_ sender: Any) {
        let clusters = ["clusters": Int(clustersLabel.intValue)]
        NotificationCenter.default.post(name: .performClustering, object: nil, userInfo: clusters)
    }
    
    @objc func setCurrentClustersLabel(notification: Notification) {
        if let target = notification.userInfo?["clustersCount"] as? Int {
            currentClustersLabel.stringValue = "(\(target))"
        }
    }
}
