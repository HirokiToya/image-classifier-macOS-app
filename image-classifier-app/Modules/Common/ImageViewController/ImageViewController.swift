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

extension ImageViewController : NSGestureRecognizerDelegate {
    
    @objc override func mouseDown(with event: NSEvent) {
        dismiss(nil)
    }
    
    @objc override func rightMouseUp(with event: NSEvent) {
        dismiss(nil)
    }
}
