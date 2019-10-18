import Cocoa
import Alamofire
import SwiftyJSON

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // カテゴリ名一覧を取得する処理
        Alamofire.request(EndPoints.SceneClassifier.Labels.path(), method: .get).validate().responseJSON {
            res in
            if res.result.isSuccess {
                if let returnValue = res.result.value {
                    print(JSON(returnValue))
                }
            } else {
                print(res.error.debugDescription)
            }
        }
        
        
        // 画像をアップロードして識別結果を受け取る処理
        let requestUrl = EndPoints.SceneClassifier.Predict.path()
        let filePath = "image.jpg"
        
        if let data = getFileData(filePath) {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                multipartFormData.append(data, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                
            }, to: requestUrl) { (encodingResult) in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { res in
                        if res.result.isSuccess {
                            if let returnValue = res.result.value {
                                print(JSON(returnValue))
                            }
                        } else {
                            print(res.error.debugDescription)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        }
    }
    
    func getFileData(_ filePath: String) -> Data? {
        let fileData: Data?
        do {
            let fileUrl = URL(fileURLWithPath: filePath)
            print("URL:\(fileUrl)")
            fileData = try Data(contentsOf: fileUrl)
        } catch {
            fileData = nil
        }
        return fileData
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

