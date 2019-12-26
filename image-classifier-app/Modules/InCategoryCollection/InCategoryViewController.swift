import Cocoa

class InCategoryViewController: NSViewController {
    
    @IBOutlet weak var imageCollectionView: NSCollectionView!
    
    var sortTag: SortActionTag = .byProbability {
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
            
            //            print("カテゴリ内画像枚数：\(imagePaths.count)")
            imageCollectionView.reloadData()
        }
    }
    
    var selectedImages:[CategoryRepositories.Image] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadData(notification:)),
                                               name: .reloadIncategoryImages,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(performClustering(notification:)),
                                               name: .performClustering,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setInCategorySortTag(notification:)),
                                               name: .setInCategorySortTag,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeTranslationState(notification:)),
                                               name: .translationState,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(outputLog(notification:)),
                                               name: .outputLog,
                                               object: nil)
    }
    
    private func setupCollectionView() {
        let nib = NSNib(nibNamed: "ImageCollectionViewItem", bundle: nil)
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem")
        self.imageCollectionView.register(nib, forItemWithIdentifier: identifier)
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 130.0, height: 190.0)
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
    
    @objc func performClustering(notification: Notification) {
        selectedImages = []
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
    
    @objc func changeTranslationState(notification: Notification) {
        if let state = notification.userInfo?["state"] as? Bool {
            translationState = state
        }
    }
    
    @objc func outputLog(notification: Notification) {
        print("ログ出力")
        print("Time:\(DebugComponent.getTimeNow())")
        
        for image in selectedImages {
            if let representativeImage = CategoryRepositories.getRepresentativeImage(sceneId: image.sceneId){
                print("カテゴリ[\(representativeImage.sceneId)]:\(representativeImage.sceneName) -> [\(image.sceneId)]:\(image.sceneName)")
            } else {
                print("カテゴリ[\(image.sceneId)]:\(image.sceneName) -> [\(image.sceneId)]:\(image.sceneName)")
            }
        }
        print("不適切な画像：\(selectedImages.count)枚")
        
    }
}

extension InCategoryViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePaths.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = imageCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem"),
                                                for: indexPath) as! ImageCollectionViewItem
        
        item.bindProbability(image: imagePaths[indexPath.item], translationState: translationState)
        item.doubleClickedCallback = {
            //            let storyboard: NSStoryboard = NSStoryboard(name: "ImageViewController", bundle: nil)
            //            if let nextView = storyboard.instantiateInitialController() as? ImageViewController {
            //                nextView.imageUrl = self.imagePaths[indexPath.item].url
            //                self.presentAsModalWindow(nextView)
            //            }
            
            let image = self.imagePaths[indexPath.item]
            if(self.selectedImages.filter({ $0.url == image.url }).count > 0) {
                self.selectedImages.removeAll(where: { $0.url == image.url })
                item.isImageSelected = false
            } else {
                self.selectedImages.append(CategoryRepositories.Image(url: image.url,
                                                                      sceneId: image.sceneId,
                                                                      sceneName: image.sceneName,
                                                                      sceneProbability: image.sceneProbability,
                                                                      objectId: image.objectId,
                                                                      objectName: image.objectName,
                                                                      objectProbability: image.objectProbability,
                                                                      scenePriority: image.scenePriority))
                item.isImageSelected = true
            }
            let imageUrl = ["imageUrl": image.url]
            NotificationCenter.default.post(name: .setSelectedImage, object: nil, userInfo: imageUrl)
        }
        
        let image = self.imagePaths[indexPath.item]
        if(self.selectedImages.filter({ $0.url == image.url }).count > 0) {
            item.isImageSelected = true
        } else {
            item.isImageSelected = false
        }
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let image = imagePaths[indexPaths.first?[1] ?? 0]
        //        print(image.sceneId)
        //        print(image.sceneName)
        //        print(image.sceneProbability)
        //        print(image.url)
    }
}
