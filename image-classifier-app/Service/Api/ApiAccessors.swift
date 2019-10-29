import Foundation
import Alamofire
import SwiftyJSON

class ApiAccessor {
    
    // Scene365のラベルリストを取得します。
    class func getSceneLabelList(completion: @escaping (Result<ApiPayload.SceneClassifierLabel, ClientError>) -> Void ) {
        
        Alamofire.request(EndPoints.SceneClassifier.Labels.path(), method: .get).validate().responseJSON { res in
            if res.result.isSuccess {
                if let returnValue = res.result.value {
                    print(JSON(returnValue))
                    let jsonData = JSON(returnValue).rawString()?.data(using: .utf8)
                    let result = (try! JSONDecoder().decode(ApiPayload.SceneClassifierLabel.self, from: jsonData!))
                    completion(Result(value: result))
                }
            } else {
                print(res.error.debugDescription)
                completion(Result(error: .apiError(res.error!)))
            }
        }
    }
    
    // Scene365を用いてシーン識別します。    
    class func predictScene(path: String,
                      withName: String = "image",
                      fileName: String = "image.jpg",
                      mimeType: String = "image/jpeg",
                      completion: @escaping (Result<ApiPayload.SceneClassifierPredict, ClientError>) -> Void ) {

        guard let data = FileAccessor.loadFileData(absoluteStrPath: path) else { return }
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
                            completion(Result(value: result))
                        } else {
                            completion(Result(error: .noResponseError(nil)))
                        }
                    } else {
                        print(res.error.debugDescription)
                        completion(Result(error: .apiError(res.error!)))
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                completion(Result(error: .encodingError(encodingError)))
            }
        }
    }
    
    // InceptionResnetを用いて物体識別します。
    class func predictObject(path: String,
                             withName: String = "image",
                             fileName: String = "image.jpg",
                             mimeType: String = "image/jpeg",
                             completion: @escaping (Result<ApiPayload.InceptionResnetPredict, ClientError>) -> Void ) {
        
        let requestUrl = EndPoints.InceptionResnet.Predict.path()
        
        if let data = FileAccessor.loadFileData(absoluteStrPath: path) {
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
                                let result = (try! JSONDecoder().decode(ApiPayload.InceptionResnetPredict.self, from: jsonData!))
                                completion(Result(value: result))
                            } else {
                                completion(Result(error: .noResponseError(nil)))
                            }
                        } else {
                            print(res.error.debugDescription)
                            completion(Result(error: .apiError(res.error!)))
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    completion(Result(error: .encodingError(encodingError)))
                }
            }
        }
    }
}
