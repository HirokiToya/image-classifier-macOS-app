import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {

    @IBOutlet var collectionViewItem: ImageCollectionViewItem!
    
    @IBOutlet weak var imageItem: NSImageView!
    @IBOutlet weak var idLabel: NSTextField!
    @IBOutlet weak var numberLabel: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var markImage: NSImageView!
    
    var doubleClickedCallback:(()->Void)?
    
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
            let num = CategoryRepositories.getInCategoryImagesCount(sceneId: image.sceneId,
                                                                    objectName: image.objectName,
                                                                    scenePriority: image.scenePriority)
            numberLabel.stringValue = "\(num)枚"
            setMarkImage(isSceneImage: true)
            
        } else {

            idLabel.stringValue = "(\(image.sceneId))"
            nameLabel.stringValue = setTransltedName(name: image.objectName, state: translationState)
            let num = CategoryRepositories.getInCategoryImagesCount(sceneId: image.sceneId,
                                                                    objectName: image.objectName,
                                                                    scenePriority: image.scenePriority)
            numberLabel.stringValue = "\(num)枚"
            setMarkImage(isSceneImage: false)
        }
    }
    
    func bindProbability(image: CategoryRepositories.Image, translationState: Bool) {
        
        imageItem.load(url: image.url)
        if(image.scenePriority) {
            
            idLabel.stringValue = "\(image.sceneId)"
            numberLabel.stringValue = "\(ceil(image.sceneProbability * 1000) / 1000)"
            nameLabel.stringValue = setTransltedName(name: image.sceneName, state: translationState)
            setMarkImage(isSceneImage: true)
            
        } else {
            
            idLabel.stringValue = "\(image.objectId)"
            numberLabel.stringValue = "\(ceil(image.objectProbability * 1000) / 1000)"
            nameLabel.stringValue = setTransltedName(name: image.objectName, state: translationState)
            setMarkImage(isSceneImage: false)
        }
        
        doubleClickedCallback = {
            let storyboard: NSStoryboard = NSStoryboard(name: "ImageViewController", bundle: nil)
            if let nextView = storyboard.instantiateInitialController() as? ImageViewController {
                nextView.imageUrl = image.url
                self.presentAsModalWindow(nextView)
            }
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
}
