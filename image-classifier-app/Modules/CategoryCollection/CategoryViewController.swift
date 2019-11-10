import Cocoa

class CategoryViewController: NSViewController {

    @IBOutlet weak var categoryCollectionView: NSCollectionView!
    
    var imagePaths: [CategoryRepositories.Image] = [] {
        didSet {
            categoryCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(notification:)), name: .reloadCategoryImages, object: nil)
        imagePaths = CategoryRepositories.getSceneRepresentativeImages()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let nib = NSNib(nibNamed: "ImageCollectionViewItem", bundle: nil)
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem")
        self.categoryCollectionView.register(nib, forItemWithIdentifier: identifier)
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 165.0, height: 165.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        categoryCollectionView.collectionViewLayout = flowLayout
    }
    
    @objc func reloadData(notification: Notification) {
        imagePaths = CategoryRepositories.getSceneRepresentativeImages()
    }
}

extension CategoryViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePaths.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = categoryCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem"),
                                                      for: indexPath) as! ImageCollectionViewItem
        
        item.imageItem.load(url: imagePaths[indexPath.item].url)
        item.imageLabel.stringValue = imagePaths[indexPath.item].sceneName
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let image = imagePaths[indexPaths.first?[1] ?? 0]
        print(image.sceneId)
        print(image.sceneName)
        print(image.sceneProbability)
        
        let sceneId = ["id": image.sceneId]
        NotificationCenter.default.post(name: .showIncategoryImages, object: nil, userInfo: sceneId)
    }
}