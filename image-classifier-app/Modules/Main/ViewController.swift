import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //        ApiAccessor().predictScene(path: "Documents/image.jpg", withName: "image", fileName: "image.jpg")
        //        ApiAccessor().getSceneLabelList()
        
        //        ApiAccessor().predictObject()
    }
    
}
