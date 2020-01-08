import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {

    @IBOutlet var collectionViewItem: ImageCollectionViewItem!
    
    @IBOutlet weak var imageItem: NSImageView!
    @IBOutlet weak var imageBackgrountView: NSView!
    @IBOutlet weak var idLabel: NSTextField!
    @IBOutlet weak var markImage: NSImageView!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var numberLabel: NSTextField!
    @IBOutlet weak var evaluationLabel: NSTextField!
    
    var doubleClickedCallback:(()->Void)?
    var rightMouseDownCallback:(()->Void)?
    
    var isImageSelected: Bool = false {
        didSet {
            setImageBackgroundColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(gestureRecognizer))
        doubleClickGesture.numberOfClicksRequired = 2
        doubleClickGesture.delegate = self
        self.view.addGestureRecognizer(doubleClickGesture)
    }
    
    func bind(image: CategoryRepositories.Image, translationState: Bool) {
        
        imageItem.load(url: image.url)
        
        if(image.scenePriority) {

            idLabel.stringValue = "\(image.sceneId)"
            nameLabel.stringValue = setTransltedName(name: image.sceneName, state: translationState)
            let num = CategoryRepositories.getSceneCategoryImages(sceneId: image.sceneId,
                                                                  objectName: image.objectName,
                                                                  scenePriority: image.scenePriority).count
            numberLabel.stringValue = "\(num)枚"
            setMarkImage(isSceneImage: true)
            if let evalution = image.evaluation {
                evaluationLabel.stringValue = "評価 \((ceil(evalution * 1000) / 1000))"
            } else {
                evaluationLabel.stringValue = ""
            }
            
        } else {

            idLabel.stringValue = "(\(image.sceneId))"
            nameLabel.stringValue = setTransltedName(name: image.objectName, state: translationState)
            let num = CategoryRepositories.getSceneCategoryImages(sceneId: image.sceneId,
                                                                  objectName: image.objectName,
                                                                  scenePriority: image.scenePriority).count
            numberLabel.stringValue = "\(num)枚"
            setMarkImage(isSceneImage: false)
            evaluationLabel.stringValue = ""
        }
    }
    
    func bindProbability(image: CategoryRepositories.Image, translationState: Bool) {
        
        imageItem.load(url: image.url)
        setImageBackgroundColor()
        if(image.scenePriority) {
            
            idLabel.stringValue = "\(image.sceneId)"
            numberLabel.stringValue = "識別確率 \(ceil(image.sceneProbability * 1000) / 1000)"
            nameLabel.stringValue = setTransltedName(name: image.sceneName, state: translationState)
            setMarkImage(isSceneImage: true)
            evaluationLabel.stringValue = ""
        } else {
            
            idLabel.stringValue = "\(image.objectId)"
            numberLabel.stringValue = "識別確率 \(ceil(image.objectProbability * 1000) / 1000)"
            nameLabel.stringValue = setTransltedName(name: image.objectName, state: translationState)
            setMarkImage(isSceneImage: false)
            evaluationLabel.stringValue = ""
        }
    }
    
    func setMarkImage(isSceneImage: Bool) {
        if(isSceneImage) {
            markImage.image = NSImage(named: "NSStatusAvailable")
        } else {
            markImage.image = NSImage(named: "NSStatusNone")
        }
    }
    
    func setTransltedName(name: String, state: Bool) -> String {
        if(state) {
            if let translationData = FileAccessor.loadTranslationData(){
                return translationData[name] ?? name
            }
        }
        return name
    }
    
    func setImageBackgroundColor() {
        if(isImageSelected) {
            imageBackgrountView.layer?.backgroundColor = NSColor.selectedTextBackgroundColor.cgColor
        } else {
            imageBackgrountView.layer?.backgroundColor = .clear
        }
    }
}

extension ImageCollectionViewItem: NSGestureRecognizerDelegate {
    
    @objc func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        
        if let gestureRecognizer = gestureRecognizer as? NSClickGestureRecognizer {
            if(gestureRecognizer.numberOfClicksRequired == 2) {
                
                if let callback = doubleClickedCallback {
                    callback()
                }
                return true
            }
        }
        return false
    }
    
    @objc override func rightMouseDown(with event: NSEvent) {
        if let callback = rightMouseDownCallback {
            callback()
        }
    }
}
