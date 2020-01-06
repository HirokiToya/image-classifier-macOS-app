import Foundation

class UserExperimentComponent {
    
    // 200枚の実験で用いる画像です．
    struct firstExperimentImages {
        let first: URL = "file:///Users/toyahiroki/Pictures/correct_images_200/AC189_L.jpg"
        let second: URL = "file:///Users/toyahiroki/Pictures/correct_images_200/DU175_L.jpg"
        let third: URL = "file:///Users/toyahiroki/Pictures/correct_images_200/AQ011_L.jpg"
        
        func getImage(count: Int) -> URL?{
            switch count {
            case 0:
                return first
            case 1:
                return second
            case 2:
                return third
            default:
                return nil
            }
        }
    }
    
    // 1000枚の実験で用いる画像です．
    struct secondExperimentImages {
        let first: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/SE066_L.jpg"
        let second: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/AX181_L.jpg"
        let third: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/CX012_L.jpg"
        
        func getImage(count: Int) -> URL?{
            switch count {
            case 0:
                return first
            case 1:
                return second
            case 2:
                return third
            default:
                return nil
            }
        }
    }
}
