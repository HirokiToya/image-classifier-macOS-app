import Foundation

class UserExperimentComponent {
    
    static var experimentTrialCountMax = 12
    
    // 200枚の実験で用いる画像です．
    struct firstExperimentImages {
        let first: URL = "file:///Users/toyahiroki/Pictures/correct_images_200/AC164_L.jpg"
        let second: URL = "file:///Users/toyahiroki/Pictures/correct_images_200/DU060_L.jpg"
        let third: URL = "file:///Users/toyahiroki/Pictures/correct_images_200/DX031_L.jpg"
        
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
        //        let first: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/SE066_L.jpg"
        //        let second: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/AX181_L.jpg"
        //        let third: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/EB154_L.jpg"
        
        let image1: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/EC131_L.jpg"
        let image2: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/SR015_L.jpg"
        let image3: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/EA081_L.jpg"
        let image4: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/AS026_L.jpg"
        let image5: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/DD037_L.jpg"
        let image6: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/AA088_L.jpg"
        let image7: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/CP095_L.jpg"
        let image8: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/DK072_L.jpg"
        let image9: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/AK090_L.jpg"
        let image10: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/CT112_L.jpg"
        let image11: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/EB060_L.jpg"
        let image12: URL = "file:///Users/toyahiroki/Pictures/correct_images_1000/SW094_L.jpg"
        
        func getImage(count: Int) -> URL?{
            switch count {
            case 0:
                return image1
            case 1:
                return image2
            case 2:
                return image3
            case 3:
                return image4
            case 4:
                return image5
            case 5:
                return image6
            case 6:
                return image7
            case 7:
                return image8
            case 8:
                return image9
            case 9:
                return image10
            case 10:
                return image11
            case 11:
                return image12
            default:
                return nil
            }
        }
    }
}
