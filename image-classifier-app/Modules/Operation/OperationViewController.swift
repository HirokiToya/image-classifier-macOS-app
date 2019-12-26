import Cocoa

class OperationViewController: NSViewController, OperationViewInterface {
    
    @IBOutlet weak var selectFolderButton: NSButton!
    @IBOutlet weak var startPredictionButton: NSButton!
    @IBOutlet weak var currentClustersLabel: NSTextField!
    @IBOutlet weak var clustersLabel: NSTextField!
    @IBOutlet weak var experimentImageView: NSImageView!
    @IBOutlet weak var experimentImageBackgroundView: NSView!
    
    var presenter: OperationPresenterInterface!
    var experimentImageUrl:URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        startPredictionButton.isEnabled = false
        
        presenter = OperationPresenter(view: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setCurrentClustersLabel(notification:)),
                                               name: .setCategoryCountLabel,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setSelectedImage(notification:)),
                                               name: .setSelectedImage,
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
        presenter.predictButtonTapped()
    }
        
    @IBAction func reloadData(_ sender: Any) {
        NotificationCenter.default.post(name: .reloadCategoryImages, object: nil)
    }
    
    @IBAction func performClustering(_ sender: Any) {
        let clusters = ["clusters": Int(clustersLabel.intValue)]
        NotificationCenter.default.post(name: .performClustering, object: nil, userInfo: clusters)
    }
    
    @IBAction func cleanDatabase(_ sender: Any) {
        if(showDialog("注意", description: "画像識別データが全て削除されます．本当に削除しますか？")) {
            presenter.deleteAllData()
        }
    }
    
    @objc func setCurrentClustersLabel(notification: Notification) {
        if let target = notification.userInfo?["clustersCount"] as? Int {
            currentClustersLabel.stringValue = "(\(target))"
        }
    }
    
    @IBAction func leftViewRadioButtonTapped(_ sender: NSButton) {
        if let tag = SortActionTag(rawValue: sender.tag) {
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
    
    @IBAction func changeExperimentImage(_ sender: Any) {
        self.presenter.changeExperimentImage()
    }
    
    @objc func setSelectedImage(notification: Notification) {
        if let target = notification.userInfo?["imageUrl"] as? URL {
            print(target)
            
            if(experimentImageUrl == target) {
                experimentImageBackgroundView.layer?.backgroundColor = NSColor.systemBlue.cgColor
            } else {
                experimentImageBackgroundView.layer?.backgroundColor = NSColor.systemRed.cgColor
            }
        }
    }
    
    @IBAction func outputLogButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .outputLog, object: nil)
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

extension OperationViewController {
    // ランダムに取得した画像を表示します．
    func showExperimantImage(image: URL){
        experimentImageView.load(url: image)
        experimentImageUrl = image
    }
}
