//
//  EndPoints.swift
import Foundation

struct Api {
    
    static var baseURL: String {
        get {
            return config
        }
    }
    
    static var config: String {
        get {
            let properties = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "APIConfig", ofType: "plist")!)!
            return properties["URL"] as! String
        }
    }
}

struct EndPoints {
    
    struct SceneClassifier {
        struct Labels {
            static func path() -> String {
                return "\(Api.baseURL)/model/labels"
            }
        }
        
        struct Predict {
            static func path() -> String {
                return "\(Api.baseURL)/model/predict"
            }
        }
    }
}
