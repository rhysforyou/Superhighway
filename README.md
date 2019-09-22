# Porygon

Porygon is a networking library heavily inspired by [tiny-networking](https://github.com/objcio/tiny-networking), but designed primarily for use with Combine. It defines an `Endpoint` type which encapsulates the relationship between a `URLRequest` and the `Decodable` entity it represents.

## A Simple Example

```swift
struct Repository: Decodable {
    let id: Int64
    let name: String
}

func repository(author: String, name: String) -> Endpoint<Repository> {
    return Endpoint(json: .get, url: URL(string: "https://api.github.com/repos/\(author)/\(name)")!)
}

subscriber = repository(author: "rhysforyou", name: "Porygon")
    .publisher()
    .sink(receiveCompletion: { completion in
        switch completion {
        case .failure(let error):
            print("Encountered an error: \(error.localizedDescription)")
        case .finished:
            print("Finished")
        }
    }, receiveValue: { repository in
        print("Received response: \(repository)")
    })
```
