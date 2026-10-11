//
//  CachedImageView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Kingfisher
import SwiftUI

/// A disk/memory-cached remote image (Kingfisher), with a shimmer placeholder. Reports the
/// loaded image's aspect ratio so a staggered gallery can size its cell.
struct CachedImageView: View {

    // MARK: - Properties

    let url: URL?
    @Binding var aspectRatio: CGFloat?

    private let targetSize: CGSize = {
        let side = UIScreen.width
        return CGSize(width: side, height: side)
    }()

    init(url: URL?, aspectRatio: Binding<CGFloat?> = .constant(nil)) {
        self.url = url
        self._aspectRatio = aspectRatio
    }

    // MARK: - UI

    var body: some View {
        KFImage(url)
            .placeholder { ShimmerView() }
            .setProcessor(DownsamplingImageProcessor(size: targetSize))
            .cacheOriginalImage()
            .fade(duration: 0.2)
            .onSuccess { result in
                let size = result.image.size
                if size.width > 0 {
                    aspectRatio = size.height / size.width
                }
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}
