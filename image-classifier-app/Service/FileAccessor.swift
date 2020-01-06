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
    
    class func writeFileData(fileName: String, string: String, encoding: String.Encoding = String.Encoding.utf8) {
        if let documentDirectoryFileURL = FilePathes.getDefaultBasePath() {
            let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(fileName)
            print("書き込むファイルのパス: \(targetTextFilePath)")
            
            do {
                let fileHandle = try FileHandle(forWritingTo: targetTextFilePath)
                let stringToWrite = "\n" + string
                fileHandle.seekToEndOfFile()
                fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
            } catch {
                do {
                    try string.write(to: targetTextFilePath, atomically: true, encoding: String.Encoding.utf8)
                } catch let error as NSError {
                    print("failed to write: \(error)")
                }
            }
        }
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
