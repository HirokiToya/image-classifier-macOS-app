import Cocoa

class ViewController: NSViewController, ViewInterface {
    
    var presenter: PresenterInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = Presenter(view: self)
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func pushButton(_ sender: Any) {
        //        let imageNames = FileAccessor().loadAllImagesPaths()
        //        for image in imageNames {
        //            print(image)
        //        }
        
        //        let results = SceneClassifierRepositories.getSceneClassifierImages()
        //        print(results.count)
        
        ApiAccessor().predictScene(path: "Documents/input/images/5979752.jpg", withName: "image", fileName: "5979752.jpg")
        
        
        //                ApiAccessor().getSceneLabelList()
        
        //        ApiAccessor().predictObject()
    }
    
}
