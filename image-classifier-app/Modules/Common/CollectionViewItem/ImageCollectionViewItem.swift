import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {

    @IBOutlet var collectionViewItem: ImageCollectionViewItem!
    
    @IBOutlet weak var imageItem: NSImageView!
    @IBOutlet weak var imageLabel: NSTextField!
    var doubleClickedCallback:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(gestureRecognizer))
        doubleClickGesture.numberOfClicksRequired = 2
        doubleClickGesture.delegate = self
        self.view.addGestureRecognizer(doubleClickGesture)
        
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
