import Cocoa
import WebKit

class HelpViewController: NSViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var url: URL? = URL(string: "file:///Users/toyahiroki/Library/Containers/jp.com.example.image-classifier-app/Data/Documents/input/help.html")

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
          self.webView.load(URLRequest(url: url))
        }
    }
    
}
