# ``Superhighway/Endpoint``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Topics

### Constructing an Endpoint

- ``init(_:url:accept:headers:expectedStatusCode:query:)``

### Decoding a JSON Response

- ``init(json:url:accept:headers:expectedStatusCode:query:decoder:)``
- ``init(json:url:accept:body:headers:expectedStatusCode:query:decoder:encoder:)``

### Wrapping an Existing Request

- ``init(request:expectedStatusCode:parse:)``
