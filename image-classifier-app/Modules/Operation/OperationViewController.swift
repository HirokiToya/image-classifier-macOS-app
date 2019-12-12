import Cocoa

class OperationViewController: NSViewController, OperationViewInterface {
    
    @IBOutlet weak var selectFolderButton: NSButton!
    @IBOutlet weak var startPredictionButton: NSButton!
    
    @IBOutlet weak var currentClustersLabel: NSTextField!
    @IBOutlet weak var clustersLabel: NSTextField!
    
    var presenter: OperationPresenterInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        startPredictionButton.isEnabled = false
        
        presenter = OperationPresenter(view: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setCurrentClustersLabel(notification:)),
                                               name: .setCategoryCountLabel,
                                               object: nil)
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
            FilePathes.setImageFolderPath(relativePath: selectedURL)
            startPredictionButton.isEnabled = true
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
    
    @IBAction func cleanDatabase(_ sender: Any) {
//        if(showDialog("注意", description: "画像識別データが全て削除されます．本当に削除しますか？")) {
//            presenter.deleteAllData()
//        }
        
        let predictionResults = PredictionRepositories.loadPredictionResults()
        let list = SimilalityRepositories.getSimilarSceneIds(sceneId: 3)
        for l in list {
            
            let filteredResults = predictionResults.filter({ Int($0.scenePredictions[0].labelId) == l.categoryId2 })
            print("\(l.categoryId1), \(l.categoryId2): \(l.similality), \(filteredResults.count)枚")
        }
        
    }
    
    @objc func setCurrentClustersLabel(notification: Notification) {
        if let target = notification.userInfo?["clustersCount"] as? Int {
            currentClustersLabel.stringValue = "(\(target))"
        }
    }
    
    @IBAction func leftViewRadioButtonTapped(_ sender: NSButton) {
        if let tag = SortActionTag(rawValue: sender.tag) {
            print("tag:\(tag)")
            NotificationCenter.default.post(name: .setCategorySortTag, object: nil, userInfo: ["sortActionTag": tag])
        }
    }
    
    @IBAction func rightViewRadioButtonTapped(_ sender: NSButton) {
        if let tag = SortActionTag(rawValue: sender.tag) {
            NotificationCenter.default.post(name: .setInCategorySortTag, object: nil, userInfo: ["sortActionTag": tag])
        }
    }
    
    @IBAction func translationButtonTapped(_ sender: NSButton) {
        switch sender.state {
        case .on:
            NotificationCenter.default.post(name: .translationState, object: nil, userInfo: ["state": true])
        case .off:
            NotificationCenter.default.post(name: .translationState, object: nil, userInfo: ["state": false])
        default: break
        }
    }
    
    private func showDialog(_ mainText: String, description: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = mainText
        alert.informativeText = description
        alert.alertStyle = .warning
        alert.addButton(withTitle: "はい")
        alert.addButton(withTitle: "いいえ")
        return alert.runModal() == .alertFirstButtonReturn
    }
}
