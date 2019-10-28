import Foundation

class FileAccessor {
    
    func loadFileData(_ filePath: String) -> Data? {
        let fileData: Data?
        do {
            let fileUrl = URL(fileURLWithPath: filePath)
//            print("URL:\(fileUrl)")
            fileData = try Data(contentsOf: fileUrl)
        } catch {
            fileData = nil
        }
        return fileData
    }
    
    func writeFileData(_ filePathName: String, fileData: String, encoding: String.Encoding = String.Encoding.utf8)  -> Bool {
        do {
            try fileData.write(toFile: filePathName, atomically: true, encoding: encoding)
        } catch {
            return false
        }
        return true
    }
    
}

extension FileAccessor {
    
    // 類似度リストのJsonファイルを読み取ります。
    func loadSimilalityJson() -> JsonPayload.Similalities? {
        
        let filePath = "Documents/input/similality_list/data.json"
        guard let data = loadFileData(filePath) else { return nil}
        guard let similality = try? JSONDecoder().decode(JsonPayload.Similalities.self, from: data) else { return  nil}
        
        print(similality.labels.count)
        
        return similality
    }
    
    // path直下の全てのファイル名を取得します。
    func loadAllImagesPaths(path: String = "input/images/") -> [String] {
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
        if let imagesPath = URL(string: documentDirectoryURL + path){
            
            do {
                let contentUrls = try FileManager.default.contentsOfDirectory(at: imagesPath, includingPropertiesForKeys: nil)
                let imageNames = imageFilter(files: contentUrls)
                let files = imageNames.map{$0.lastPathComponent}
                
                return files
            } catch {
                print(error)
            }
        }
        
        return []
    }
    
    // .jpgファイルのみにフィルターします。
    func imageFilter(files: [URL]) -> [URL] {
        var imageFile: [URL] = []
        
        for file in files {
            if(file.pathExtension == "jpg") {
                imageFile.append(file)
            }
        }
    
        return imageFile
    }
}
