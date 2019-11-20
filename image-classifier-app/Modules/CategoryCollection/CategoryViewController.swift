import Cocoa

class CategoryViewController: NSViewController {

    @IBOutlet weak var categoryCollectionView: NSCollectionView!
    
    var sorTag: SortActionTag = .byId {
        didSet {
            imagePaths = imagesCache
        }
    }
    
    var imagesCache: [CategoryRepositories.Image] = []
    
    var imagePaths: [CategoryRepositories.Image] = [] {
        didSet {
            
            switch sorTag {
            case .byId:
                imagePaths.sort(by: { $0.sceneId < $1.sceneId })
            case .bByCount:
                imagePaths.sort(by: {
                    CategoryRepositories.getInCategoryImagesCount(sceneId: $0.sceneId, objectName: $0.objectName, scenePriority: $0.scenePriority) > CategoryRepositories.getInCategoryImagesCount(sceneId: $1.sceneId, objectName: $1.objectName, scenePriority: $1.scenePriority)
                })
            case .byProbability:
                imagePaths.sort(by: {
                    if($0.scenePriority && $1.scenePriority) {
                       return ($0.sceneProbability > $1.sceneProbability)
                    } else if (!$0.scenePriority && $1.scenePriority){
                       return ($0.objectProbability > $1.sceneProbability)
                    } else if($0.scenePriority && !$1.scenePriority) {
                        return ($0.sceneProbability > $1.objectProbability)
                    } else {
                        return ($0.objectProbability > $1.objectProbability)
                    }
                })
            }
            
            imagesCache = imagePaths
            
            print("カテゴリ数：\(imagePaths.count)")
            let clustersCount = ["clustersCount": imagePaths.count]
            NotificationCenter.default.post(name: .setCategoryCountLabel, object: nil, userInfo: clustersCount)
            categoryCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadData(notification:)),
                                               name: .reloadCategoryImages,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(performClustering(notification:)),
                                               name: .performClustering,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setCategorySortTag(notification:)),
                                               name: .setCategorySortTag,
                                               object: nil)
        
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
        flowLayout.itemSize = NSSize(width: 175.0, height: 175.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        categoryCollectionView.collectionViewLayout = flowLayout
    }
    
    @objc func reloadData(notification: Notification) {
        
        PredictionRepositories.reloadCache()
        CategoryRepositories.reloadCaches()
        imagePaths = CategoryRepositories.getSceneRepresentativeImages()
        if(imagePaths.count == 0) {
            let alert = NSAlert()
            alert.messageText = "画像読み込みエラー"
            alert.informativeText = "画像フォルダを指定して再度画像識別を実行してください．"
            alert.runModal()
        }
    }
    
    @objc func performClustering(notification: Notification) {
        if let target = notification.userInfo?["clusters"] as? Int {
            
            if(target < 1){
                let alert = NSAlert()
                alert.messageText = "入力エラー"
                alert.informativeText = "0より大きいカテゴリ数を指定してください．"
                alert.runModal()
            } else {
                imagePaths = CategoryRepositories.clusterCategories(clusters: target)
            }
        }
    }
    
    @objc func setCategorySortTag(notification: Notification) {
        if let tag = notification.userInfo?["sortActionTag"] as? SortActionTag {
            switch tag {
            case .byId:
                sorTag = .byId
            case .bByCount:
                sorTag = .bByCount
            case .byProbability:
                sorTag = .byProbability
            }
        }
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
        if(imagePaths[indexPath.item].scenePriority) {
            
            item.idLabel.stringValue = "\(imagePaths[indexPath.item].sceneId)"
            item.numberLabel.stringValue = "\(CategoryRepositories.getInCategoryImagesCount(sceneId: imagePaths[indexPath.item].sceneId, objectName: imagePaths[indexPath.item].objectName, scenePriority: imagePaths[indexPath.item].scenePriority))枚"
            item.nameLabel.stringValue = imagePaths[indexPath.item].sceneName
            item.setMarkImage(isSceneImage: true)
        } else {
            
            item.idLabel.stringValue = "(\(imagePaths[indexPath.item].sceneId))"
            item.nameLabel.stringValue = imagePaths[indexPath.item].objectName
            item.numberLabel.stringValue = "\(CategoryRepositories.getInCategoryImagesCount(sceneId: imagePaths[indexPath.item].sceneId, objectName: imagePaths[indexPath.item].objectName, scenePriority: imagePaths[indexPath.item].scenePriority))枚"
            item.setMarkImage(isSceneImage: false)
        }
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let image = imagePaths[indexPaths.first?[1] ?? 0]
        print(image.url)
        print(image.sceneId)
        print(image.sceneName)
        print(image.sceneProbability)
        
        let imageAttributes = ["imageAttributes": image]
        NotificationCenter.default.post(name: .reloadIncategoryImages, object: nil, userInfo: imageAttributes)
    }
}
