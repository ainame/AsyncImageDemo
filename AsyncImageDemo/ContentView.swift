//
//  ContentView.swift
//  AsyncImageDemo
//
//  Created by Satoshi Namai on 13/10/2023.
//

import SwiftUI

struct ItemView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .aspectRatio(contentMode: .fill)
                    .containerRelativeFrame([.vertical, .horizontal])
                    .clipped()
            case .failure(let error):
                let _ = print(error)
                Color.red
                    .containerRelativeFrame([.vertical, .horizontal])
                    .clipped()
            @unknown default:
                ProgressView()
            }
        }
    }

}

struct ContentView: View {
    let urls: [URL?] = [
        URL(string: "https://picsum.photos/900/1600?0"),
        URL(string: "https://picsum.photos/900/1600?1"),
        URL(string: "https://picsum.photos/900/1600?2"),
        URL(string: "https://picsum.photos/900/1600?3"),
        URL(string: "https://picsum.photos/900/1600?4"),
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(urls, id: \.self) { url in
                    ItemView(url: url)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .ignoresSafeArea()
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    ContentView()
}
