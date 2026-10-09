//
//  UIImage+Extensions.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import UIKit

extension UIImage {

    /// Scales the image down so its longest dimension is at most `maxSize`.
    func resizedToMaxDimension(_ maxSize: CGFloat) -> UIImage {
        let largestDimension = max(size.width, size.height)
        guard largestDimension > maxSize else { return self }

        let scaleFactor = maxSize / largestDimension
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        // Scale 1.0 renders one pixel per point so the output matches `maxSize` in pixels
        // instead of the device's screen scale (which would upload a much larger image).
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    /// Encodes the image as a base64 data URI suitable for the backend image upload endpoint.
    func toBase64(compressionQuality: CGFloat = 0.3) -> String? {
        guard let data = jpegData(compressionQuality: compressionQuality) else { return nil }
        return "data:image/jpeg;base64,\(data.base64EncodedString())"
    }

    /// Safe placeholder for an empty profile image: bundled asset → SF Symbol → blank image.
    static let profilePlaceholder: UIImage = {
        UIImage(named: "emptyProfile")
            ?? UIImage(systemName: "person.crop.circle")
            ?? UIImage()
    }()
}
