import Foundation

class FileAccessor {
    
    class func loadFileData(absoluteUrlPath: URL) -> Data? {
        let fileData: Data?
        do {
            fileData = try Data(contentsOf: absoluteUrlPath)
        } catch {
            fileData = nil
        }
        return fileData
    }
    
    class func loadFileData(absoluteStrPath: String) -> Data? {
        let fileData: Data?
        do {
            let fileUrl = URL(fileURLWithPath: absoluteStrPath)
            fileData = try Data(contentsOf: fileUrl)
        } catch {
            fileData = nil
        }
        return fileData
    }
    
    class func writeFileData(absoluteStrPath: String, fileData: String, encoding: String.Encoding = String.Encoding.utf8)  -> Bool {
        do {
            try fileData.write(toFile: absoluteStrPath, atomically: true, encoding: encoding)
        } catch {
            return false
        }
        return true
    }
}

extension FileAccessor {
    
    // 類似度ファイルのJsonデータを読み取ります.
    class func loadSimilalityJson() -> JsonPayload.Similalities? {
        
        if let filePath = FilePathes.getSimilalityFilePath() {
            print(filePath)
            guard let data = loadFileData(absoluteUrlPath: filePath) else {
                print("No Such a File")
                return nil
            }
            
            do {
                let similality = try JSONDecoder().decode(JsonPayload.Similalities.self, from: data)
                print(similality.labels.count)
                return similality
            } catch {
                print(error)
                return nil
            }
        }
        return nil
    }
    
    // 翻訳ファイルのJsonデータを読み取ります．
    class func loadTranslationData() -> [String : String]? {
        if let filePath = FilePathes.getTranslationFilePath() {
            guard let data = loadFileData(absoluteUrlPath: filePath) else {
                print("No Such a File")
                return [:]
            }
            
            do {
                let dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String]
                return dic
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return [:]
    }
        
    // path直下の全ての画像ファイル名を取得します。
    class func loadAllImagePathes() -> [URL] {
        
        if let imageFolerPath = FilePathes.getImageFolderPath() {
            do {
                let contentUrls = try FileManager.default.contentsOfDirectory(at: imageFolerPath, includingPropertiesForKeys: nil)
                let imagePaths = imageFilter(files: contentUrls)
                return imagePaths
            } catch {
                print(error)
            }
        }
        
        return []
    }
    
    // .jpgファイルのみにフィルターします。
    class func imageFilter(files: [URL]) -> [URL] {
        var imageFile: [URL] = []
        
        for file in files {
            if(file.pathExtension == "jpg") {
                imageFile.append(file)
            }
        }
        
        return imageFile
    }
}
