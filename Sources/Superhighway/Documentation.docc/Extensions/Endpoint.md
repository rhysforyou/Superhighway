# ``Superhighway/Endpoint``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Topics

### Decoding a JSON Response

- ``init(decoding:method:url:accept:headers:expectedStatusCode:query:decoder:)``
- ``init(decoding:method:url:accept:body:headers:expectedStatusCode:query:decoder:encoder:)``
- ``init(decoding:method:url:accept:body:headers:expectedStatusCode:query:encoder:)``

### Constructing an Endpoint

- ``init(_:url:accept:contentType:body:headers:expectedStatusCode:timeOutInterval:query:parse:)``
- ``init(_:url:accept:headers:expectedStatusCode:query:)``

### Wrapping an Existing Request

- ``init(request:expectedStatusCode:parse:)``

### Deprecated

- ``init(json:url:accept:headers:expectedStatusCode:query:decoder:)``
- ``init(json:url:accept:body:headers:expectedStatusCode:query:decoder:encoder:)``
- ``init(json:url:accept:body:headers:expectedStatusCode:query:encoder:)``
