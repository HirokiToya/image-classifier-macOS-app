import Cocoa

class ImageViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    var imageUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = imageUrl {
            imageView.load(url: url)
        }
    }
    
}
