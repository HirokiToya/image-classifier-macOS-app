import Cocoa

class InCategoryViewController: NSViewController {

    @IBOutlet weak var imageCollectionView: NSCollectionView!
    
    var imagePaths: [CategoryRepositories.Image] = [] {
        didSet {
            print("カテゴリ内画像枚数：\(imagePaths.count)")
            imageCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadData(notification:)),
                                               name: .showIncategoryImages, object: nil)
    }
    
    private func setupCollectionView() {
        let nib = NSNib(nibNamed: "ImageCollectionViewItem", bundle: nil)
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem")
        self.imageCollectionView.register(nib, forItemWithIdentifier: identifier)
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 165.0, height: 165.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        imageCollectionView.collectionViewLayout = flowLayout
    }
    
    @objc func reloadData(notification: Notification) {
        if let target = notification.userInfo?["imageAttributes"] as? CategoryRepositories.Image {
            imagePaths = CategoryRepositories.getCategoryAttributeImages(sceneId: target.sceneId,
                                                                         objectName: target.objectName,
                                                                         scenePriority: target.scenePriority)
        }
    }
}

extension InCategoryViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePaths.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = imageCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem"),
                                                      for: indexPath) as! ImageCollectionViewItem
        
        item.imageItem.load(url: imagePaths[indexPath.item].url)
        if(imagePaths[indexPath.item].scenePriority) {
            item.imageLabel.stringValue = """
            【Scene】
            \(imagePaths[indexPath.item].sceneName)
            """
        } else {
            item.imageLabel.stringValue = """
            【Object】
            \(imagePaths[indexPath.item].objectName)
            """
        }
        item.doubleClickedCallback = {
            let storyboard: NSStoryboard = NSStoryboard(name: "ImageViewController", bundle: nil)
            if let nextView = storyboard.instantiateInitialController() as? ImageViewController {
                nextView.imageUrl = self.imagePaths[indexPath.item].url
                self.presentAsModalWindow(nextView)
            }
        }
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let image = imagePaths[indexPaths.first?[1] ?? 0]
        print(image.sceneId)
        print(image.sceneName)
        print(image.sceneProbability)
        print(image.url)
    }
}
