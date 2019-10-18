import Foundation
import Alamofire
import SwiftyJSON

class Interactor {
    
    func getSceneLabelList() {
        
        Alamofire.request(EndPoints.SceneClassifier.Labels.path(), method: .get).validate().responseJSON {
            res in
            if res.result.isSuccess {
                if let returnValue = res.result.value {
                    
                    let json = JSON(returnValue)
                    if let string = json.rawString() {
                        if self.writeFileData("output/label_list.json", fileData: string){
                            print("ファイル書き出し成功:\(String(describing: string))")
                        }
                    }
                }
                
            } else {
                print(res.error.debugDescription)
            }
        }
    }
    
    func predictScene() {
        
        let requestUrl = EndPoints.SceneClassifier.Predict.path()
        let filePath = "input/images/image.jpg"
        
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
    
    func predictObject() {
        
    }
    
    func loadSimilalityJson(json: JSON) {
        
        let filePath = "input/similality_list/data.json"
        guard let data = getFileData(filePath) else { return }
        guard let similality = try? JSONDecoder().decode(Similality.self, from: data) else { return }
        
        print(similality.labels.count)
        
//        for i in 0..<365 {
//            for j in 0..<365 {
//                if similality.labels[i][j] < 0.99 && similality.labels[i][j] > 0.5 && i < j {
//                    print("\(json["labels"][i]["name"]) \(json["labels"][j]["name"]) \(similality.labels[i][j])")
//                }
//            }
//        }
    }
    
    private func getFileData(_ filePath: String) -> Data? {
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
    
    private func writeFileData(_ filePathName: String, fileData: String, encoding: String.Encoding = String.Encoding.utf8)  -> Bool {
        do {
            try fileData.write(toFile: filePathName, atomically: true, encoding: encoding)
        } catch {
            return false
        }
        return true
    }
    
}
