import Foundation

struct SceneClassifierApi {
    
    static var baseURL: String {
        get {
            return config
        }
    }
    
    static var config: String {
        get {
            let properties = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "APIConfig", ofType: "plist")!)!
            return properties["SceneClassifierURL"] as! String
        }
    }
}

struct InceptionResnetApi {
    static var baseURL: String {
        get {
            return config
        }
    }
    
    static var config: String {
        get {
            let properties = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "APIConfig", ofType: "plist")!)!
            return properties["InceptionResnetURL"] as! String
        }
    }
}

struct EndPoints {
    
    struct SceneClassifier {
                
        struct Labels {
            static func path() -> String {
                return "\(SceneClassifierApi.baseURL)/model/labels"
            }
        }
        
        struct Predict {
            static func path() -> String {
                return "\(SceneClassifierApi.baseURL)/model/predict"
            }
        }
    }
    
    struct InceptionResnet {
        
        struct Predict {
            static func path() -> String {
                return "\(InceptionResnetApi.baseURL)/model/predict"
            }
        }
    }
}
