# AsyncImageDemo

This repo shares strange behaviour of AsyncImage in ScrollView that 2nd item's image loading is immediately cancelled.
This was reported at FB13268157.

# What's wrong with this?

This app showcases `AsyncImage`'s loading is strangely cancelled. With the below simple `View` code (hidden under `Details`) just loading image or showing error as Red screen,
you can see that the 2nd item's loading had an error. On Xcode, I observed this was cancelled.

<details>

```swift
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
```

</details>

![Simulator Screen Recording - iPhone 15 Pro Max - 2023-10-13 at 15 39 22](https://github.com/ainame/AsyncImageDemo/assets/748949/4f151805-bf89-4d35-a158-17706cb2d334)

Error message here.

```
Error Domain=NSURLErrorDomain Code=-999 "cancelled" UserInfo={NSErrorFailingURLStringKey=https://picsum.photos/900/1600?1, NSErrorFailingURLKey=https://picsum.photos/900/1600?1, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalDownloadTask <83C25DAD-869D-4FAA-A778-D69C0EA0E85E>.<2>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalDownloadTask <83C25DAD-869D-4FAA-A778-D69C0EA0E85E>.<2>, NSLocalizedDescription=cancelled}
```

# Environment to replicate

Xcode 15.0 (15A240d) + iOS 17 simulator (iPhone 15 Pro Max) running on macOS 14.0 Sonoma (23A344)

# Possible workaround

The workaround I came up was to manage the result of loading in each view having `AsyncImage` and
reset and assign back the remote image URL to `imageUrl` state property on every appear and disappear hook until succeeds.

```swift
struct ItemView: View {
    let url: URL?

    @State private var hasImageLoaded: Bool = false
    @State private var imageUrl: URL? = nil

    var body: some View {
        AsyncImage(url: imageUrl) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .aspectRatio(contentMode: .fill)
                    .containerRelativeFrame([.vertical, .horizontal])
                    .clipped()
                    .onAppear {
                        hasImageLoaded = true
                    }
            case .failure(let error):
                let _ = print(error)
                Color.red
                    .containerRelativeFrame([.vertical, .horizontal])
                    .clipped()
            @unknown default:
                ProgressView()
            }
        }
        .onAppear {
            if !hasImageLoaded {
                imageUrl = url
            }
        }
        .onDisappear {
            if !hasImageLoaded {
                imageUrl = nil
            }
        }
    }
}
```

# Related links

* https://developer.apple.com/forums/thread/682498
