//
//  WebView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI
import WebKit

/// An in-app web view, used to present the EULA.
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
