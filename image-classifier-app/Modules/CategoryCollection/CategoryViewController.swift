import Cocoa

class CategoryViewController: NSViewController {

    @IBOutlet weak var categoryCollectionView: NSCollectionView!
    
    var sortTag: SortActionTag = .byId {
        didSet {
            imagePaths = imagesCache
        }
    }
    
    var translationState: Bool = false {
        didSet {
            imagePaths = imagesCache
        }
    }
    
    var imagesCache: [CategoryRepositories.Image] = []
    
    var imagePaths: [CategoryRepositories.Image] = [] {
        didSet {
            
            switch sortTag {
            case .byId:
                imagePaths.sort(by: { $0.sceneId < $1.sceneId })
            case .bByCount:
                imagePaths.sort(by: {
                    CategoryRepositories.getSceneCategoryImages(sceneId: $0.sceneId, objectName: $0.objectName, scenePriority: $0.scenePriority).count > CategoryRepositories.getSceneCategoryImages(sceneId: $1.sceneId, objectName: $1.objectName, scenePriority: $1.scenePriority).count
                })
            case .byEvalution:                
                imagePaths.sort(by: {
                    $0.evaluation ?? 0 > $1.evaluation ?? 0
                })
            }
            
            imagesCache = imagePaths
            
//            print("カテゴリ数：\(imagePaths.count)")
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeTranslationState(notification:)),
                                               name: .translationState,
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
        flowLayout.itemSize = NSSize(width: 130.0, height: 197.0)
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
                
                if(target < CategoryRepositories.getSceneRepresentativeImages().count){
                    // カテゴリ統合処理結果を取得します．
                    imagePaths = CategoryRepositories.integrateCategories(clusters: target)
                } else {
                    // カテゴリ分割処理結果を取得します．
                    imagePaths = CategoryRepositories.divideCategories(clusters: target)
                }
                
                print("クラスタリング処理終了時刻:\(DebugComponent().getTimeNow())")
            }
        }
    }
    
    @objc func setCategorySortTag(notification: Notification) {
        if let tag = notification.userInfo?["sortActionTag"] as? SortActionTag {
            switch tag {
            case .byId:
                sortTag = .byId
            case .bByCount:
                sortTag = .bByCount
            case .byEvalution:
                sortTag = .byEvalution
            }
        }
    }
    
    @objc func changeTranslationState(notification: Notification) {
        if let state = notification.userInfo?["state"] as? Bool {
            translationState = state
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
        
        item.bind(image: imagePaths[indexPath.item], translationState: translationState)
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let image = imagePaths[indexPaths.first?[1] ?? 0]
//        print(image.url)
//        print(image.sceneId)
//        print(image.sceneName)
//        print(image.sceneProbability)
        
        let imageAttributes = ["imageAttributes": image]
        NotificationCenter.default.post(name: .reloadIncategoryImages, object: nil, userInfo: imageAttributes)
    }
}
