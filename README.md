# Vision.jl
A Julia package for easily interacting with the [Google Vision API](https://cloud.google.com/vision/).  

The package currently implements the following features:
1. `makeRequestBody` - creates a request body for the Google Vision API from either a base 64 encoded image or a URI to an image containing one or more features.

2. `visionFeature` - creates a `VisionFeature` object for use in the request body.

3. `getResponse` - sends a request to the Google Vision API and returns the response.

4. `parseFeatures` - parses the response from the Google Vision API, currently only supports `textAnnotations`

## How to use  
Export your google API key to `JULIA_VISION_API_KEY` or manually override the URL used by `getResponse`


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