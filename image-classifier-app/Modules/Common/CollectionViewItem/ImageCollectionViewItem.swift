import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {

    @IBOutlet var collectionViewItem: ImageCollectionViewItem!
    
    @IBOutlet weak var imageItem: NSImageView!
    @IBOutlet weak var imageLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
