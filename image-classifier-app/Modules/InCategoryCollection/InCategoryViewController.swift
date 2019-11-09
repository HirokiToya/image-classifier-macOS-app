import Cocoa

class InCategoryViewController: NSViewController {

    @IBOutlet weak var imageCollectionView: NSCollectionView!
    
    var imagePaths: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePaths = FileAccessor.loadAllImagePathes()
        setupCollectionView()
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
    
}

extension InCategoryViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePaths.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = imageCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem"),
                                                      for: indexPath) as! ImageCollectionViewItem
        
        item.imageItem.load(url: imagePaths[indexPath.item])
        item.imageLabel.stringValue = imagePaths[indexPath.item].lastPathComponent
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        print(imagePaths[indexPaths.first?[1] ?? 0].lastPathComponent)
    }
}

