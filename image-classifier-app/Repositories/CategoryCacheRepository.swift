import Foundation

class CategoryCacheRepository {
    
    private var categoriesCacheDictionary: [Int: [CategoryAttribute]] = [:]
    
    func save(clusterNum: Int, categoryAttrs: [CategoryAttribute]) {
        categoriesCacheDictionary[clusterNum] = categoryAttrs
        print("cache:\(clusterNum)")
    }
    
    func get(clusterNum: Int) -> [CategoryAttribute] {
        return categoriesCacheDictionary[clusterNum] ?? []
    }
    
}
