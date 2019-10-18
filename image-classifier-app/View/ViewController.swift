import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let interactor = Interactor()
        interactor.getSceneLabelList()
//        interactor.loadSimilalityJson()
//        interactor.predictScene()
        
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

