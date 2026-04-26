//
//  VideoPlayerView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 06/04/2026.
//

import SwiftUI
import WebKit

struct VideoPlayerView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedURL = youtubeEmbedURL(from: url)
        webView.load(URLRequest(url: embedURL))
    }

    
    private func youtubeEmbedURL(from url: URL) -> URL {
        let str = url.absoluteString
        var videoID = ""

        if str.contains("youtu.be/") {
            videoID = str.components(separatedBy: "youtu.be/").last?
                .components(separatedBy: "?").first ?? ""
        } else if str.contains("watch?v=") {
            videoID = str.components(separatedBy: "watch?v=").last?
                .components(separatedBy: "&").first ?? ""
        } else if str.contains("youtube.com/embed/") {
            return url
        }

        return URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1")!
    }
}
