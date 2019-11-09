import Cocoa

class InCategoryViewController: NSViewController {

    @IBOutlet weak var imageCollectionView: NSCollectionView!
    
    var imagePaths: [CategoryRepositories.Image] = [] {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(notification:)), name: .showIncategoryImages, object: nil)
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
        if let target = notification.userInfo?["id"] as? Int {
            imagePaths = CategoryRepositories.getSceneCategoryImages(sceneId: target)
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
        item.imageLabel.stringValue = "\(ceil(imagePaths[indexPath.item].sceneProbability * 1000) / 1000)"
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let image = imagePaths[indexPaths.first?[1] ?? 0]
        print(image.sceneId)
        print(image.sceneName)
        print(image.sceneProbability)
    }
}

