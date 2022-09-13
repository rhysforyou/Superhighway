# ``Superhighway``

Superhighway is a networking library heavily inspired by `tiny-networking`, but designed primarily for use with Combine. It defines an `Endpoint` type which encapsulates the relationship between a `URLRequest` and the `Decodable` entity it represents.

## A Simple Example

```swift
struct Repository: Decodable {
    let id: Int64
    let name: String
}

func getRepository(author: String, name: String) -> Endpoint<Repository> {
    return Endpoint(json: .get, url: URL(string: "https://api.github.com/repos/\(author)/\(name)")!)
}

let endpoint = getRepository(author: "rhysforyou", name: "Superhighway")
```

This simply gives us the description of an endpoint, to actually load it, we can pass it to a URLSession:

```swift
do {
    let (repository, _) = try await URLSession.default.data(for: endpoint)
    print("Repository: \(repository)")
} catch {
    print("Error: \(error)")
}
```

If the task is cancelled before it finishes, any networking operations will be halted.

## Topics

### Essentials

- ``Endpoint``

### Constructing Endpoints

- ``ContentType``
- ``HTTPMethod``

### Handling Errors

- ``NoDataError``
- ``UnknownError``
- ``WrongStatusCodeError``

### Status Codes

- ``expected200to300(_:)``
