import Foundation
import Alamofire
import SwiftyJSON

class ApiAccessor {
    
    // Scene365のラベルリストを取得します。
    func getSceneLabelList() -> ApiPayload.SceneClassifierLabel {
        var result: ApiPayload.SceneClassifierLabel!
        let semaphore = DispatchSemaphore(value: 0)
        let queue     = DispatchQueue.global(qos: .utility)
        
        Alamofire.request(EndPoints.SceneClassifier.Labels.path(), method: .get).validate().responseJSON(queue: queue) { res in
            if res.result.isSuccess {
                if let returnValue = res.result.value {
                    print(JSON(returnValue))
                    let jsonData = JSON(returnValue).rawString()?.data(using: .utf8)
                    result = (try! JSONDecoder().decode(ApiPayload.SceneClassifierLabel.self, from: jsonData!))
                }
            } else {
                print(res.error.debugDescription)
            }
            
            semaphore.signal()
        }

        semaphore.wait()

        return result
    }
    
    // Scene365を用いてシーン識別します。    
    func predictScene(path: String,
                      withName: String = "image",
                      fileName: String = "image.jpg",
                      mimeType: String = "image/jpeg") {

        guard let data = FileAccessor().loadFileData(path) else { return }
        let requestUrl = EndPoints.SceneClassifier.Predict.path()

        Alamofire.upload(multipartFormData: { (multipartFormData) in

            multipartFormData.append(data, withName: withName, fileName: fileName, mimeType: mimeType)

        }, to: requestUrl) { (encodingResult) in

            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { res in
                    if res.result.isSuccess {
                        if let returnValue = res.result.value {
                            print(JSON(returnValue))
                            let jsonData = JSON(returnValue).rawString()?.data(using: .utf8)
                            let result = (try! JSONDecoder().decode(ApiPayload.SceneClassifierPredict.self, from: jsonData!))
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
    
    // InceptionResnetを用いて物体識別します。
    func predictObject() {
        let requestUrl = EndPoints.InceptionResnet.Predict.path()
        let filePath = "Documents/image.jpg"
        
        if let data = FileAccessor().loadFileData(filePath) {
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
}
