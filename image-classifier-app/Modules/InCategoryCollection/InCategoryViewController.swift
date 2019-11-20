import Cocoa

class InCategoryViewController: NSViewController {

    @IBOutlet weak var imageCollectionView: NSCollectionView!
    
    var sortTag: SortActionTag = .byProbability {
        didSet {
            imagePaths = imagesCache
        }
    }
    
    var imagesCache: [CategoryRepositories.Image] = []
    var scenePriorityCache = false
    
    var imagePaths: [CategoryRepositories.Image] = [] {
        didSet {
            switch sortTag {
            case .byId:
                if(scenePriorityCache) {
                    imagePaths.sort(by: { $0.sceneId < $1.sceneId })
                }
            case .bByCount:
                break
            case .byProbability:
                if(scenePriorityCache) {
                    imagePaths.sort(by: { $0.sceneProbability > $1.sceneProbability })
                } else {
                    imagePaths.sort(by: { $0.objectProbability > $1.objectProbability })
                }
            }
            
            imagesCache = imagePaths
            
            print("カテゴリ内画像枚数：\(imagePaths.count)")
            imageCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadData(notification:)),
                                               name: .reloadIncategoryImages, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setInCategorySortTag(notification:)),
                                               name: .setInCategorySortTag,
                                               object: nil)
    }
    
    private func setupCollectionView() {
        let nib = NSNib(nibNamed: "ImageCollectionViewItem", bundle: nil)
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem")
        self.imageCollectionView.register(nib, forItemWithIdentifier: identifier)
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 175.0, height: 175.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        imageCollectionView.collectionViewLayout = flowLayout
    }
    
    @objc func reloadData(notification: Notification) {
        if let target = notification.userInfo?["imageAttributes"] as? CategoryRepositories.Image {
            scenePriorityCache = target.scenePriority
            imagePaths = CategoryRepositories.getCategoryAttributeImages(sceneId: target.sceneId,
                                                                         objectName: target.objectName,
                                                                         scenePriority: target.scenePriority)
        }
    }
    
    @objc func setInCategorySortTag(notification: Notification) {
        if let tag = notification.userInfo?["sortActionTag"] as? SortActionTag {
            switch tag {
            case .byId:
                sortTag = .byId
            case .bByCount:
                sortTag = .bByCount
            case .byProbability:
                sortTag = .byProbability
            }
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
            
            item.idLabel.stringValue = "\(imagePaths[indexPath.item].sceneId)"
            item.numberLabel.stringValue = "\(ceil(imagePaths[indexPath.item].sceneProbability * 1000) / 1000)"
            item.nameLabel.stringValue = imagePaths[indexPath.item].sceneName
            item.setMarkImage(isSceneImage: true)
        } else {
            
            item.idLabel.stringValue = "\(imagePaths[indexPath.item].objectId)"
            item.numberLabel.stringValue = "\(ceil(imagePaths[indexPath.item].objectProbability * 1000) / 1000)"
            item.nameLabel.stringValue = imagePaths[indexPath.item].objectName
            item.setMarkImage(isSceneImage: false)
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
