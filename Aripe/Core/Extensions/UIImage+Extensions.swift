import UIKit

extension UIImage {
    func cropped(to size: CGSize) -> UIImage {
        let scale = self.scale
        let imageSize = self.size
        
        let originX = (imageSize.width - size.width) / 2
        let originY = (imageSize.height - size.height) / 2
        let cropRect = CGRect(x: originX * scale, y: originY * scale, width: size.width * scale, height: size.height * scale)
        
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else {
            return self
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: self.imageOrientation)
    }
    
    func resized(to targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
} 