# Vision.jl
A Julia package for interacting with the [Google Vision API](https://cloud.google.com/vision/).


## Example code snippets
### Using base64 encoded images
```julia
using Vision
using Base64

image = base64encode(open("example.jpg", "r"))

requestBody = makeRequestBody(image, visionFeature("DOCUMENT_TEXT_DETECTION"))

response = getResponse(requestBody)

println(parseFeatures(response))
```

### Using URI's
```julia
using Vision
using URIs

requestBody = makeRequestBody(
    URI("https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Julia_Programming_Language_Logo.svg/1920px-Julia_Programming_Language_Logo.svg.png"),
    [
        visionFeature("LABEL_DETECTION", 50),
        visionFeature("TEXT_DETECTION", 50),
        visionFeature("LOGO_DETECTION", 1),
    ]
)
response = getResponse(requestBody)

println(parseFeatures(response))

```