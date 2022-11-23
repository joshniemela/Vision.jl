#module Vision

using HTTP
using JSON
using Base64
using URIs
function image2string(image)
    # Convert image to base64 string
    # image: image file path
    # return: base64 string
    base64encode(open(image, "r"))
end

"""
    makeRequestBody(image, features)

Create the request body for the Google Vision API.

# Arguments
- `image` base64 encoded image of type `String` or URI of type `URI`
- `features::Array{Dict{String, Any}}` list of features to request from the API

# Returns
- `Dict{String, Any}` request body
"""
function makeRequestBody end

function makeRequestBody(imageString::String, features::Vector{Dict{String, Any}})  
    Dict("requests" =>
        [
            Dict(
                "image" => Dict("content" => imageString),
                "features" => features
            )
        ]
    ) |> JSON.json
end

function makeRequestBody(imageURI::URI, features)  
    Dict("requests" =>
        [
            Dict(
                "image" => Dict("source" => Dict("imageUri" => URIs.uristring(imageURI))),
                "features" => features
            )
        ]
    ) |> JSON.json
end

"""
    makeRequest(featureType::String, maxResults::Int=10)

    Make a dictionary containing the feature type and max results.

# Arguments
- `featureType::String` type of feature to request from the API
- `maxResults::Int=10` maximum number of results to return
"""
function visionFeature(featureType::String, maxResults::Int=10)
    if featureType ∉ [
        "TEXT_DETECTION",
        "DOCUMENT_TEXT_DETECTION",
        "LABEL_DETECTION",
        "FACE_DETECTION",
        "LANDMARK_DETECTION",
        "LOGO_DETECTION",
        "SAFE_SEARCH_DETECTION",
        "IMAGE_PROPERTIES",
        "CROP_HINTS",
        "WEB_DETECTION",
        "OBJECT_LOCALIZATION"
    ]
        throw(ArgumentError("Invalid feature type, see https://cloud.google.com/vision/docs/features-list for valid feature types"))
    else
        Dict("type" => featureType, "maxResults" => maxResults)
    end
end

"""
    getResponse(requestBody, URL, headers)

    Make a request to the Google Vision API and return as a dictionary.

# Arguments
- `requestBody` JSON request body
- `URL` URL of the API, defaults to `https://vision.googleapis.com/v1/images:annotate`
- `headers` headers for the request, defaults to []

# Returns
- `Dict{String, Any}` response from the API
"""
function getResponse(requestBody::String,
    URL::String="https://vision.googleapis.com/v1/images:annotate?key=$(ENV["GOOGLE_VISION_API_KEY"])",
    headers = [])
    # Send request to Google Vision API
    # requestBody: request body
    # return: response body
    response = HTTP.post(URL, headers, requestBody)

    return JSON.parse(String(response.body))
end

function parseFeatures(responseBody)
    responses = responseBody["responses"][1]
    parsedResponse = Dict()
    for (key, value) in responses
        if key == "textAnnotations"
            for annotation in value
                println(annotation["description"])
            end
        elseif key == "labelAnnotations"
    end
end


newBody = makeRequestBody(
    URI("https://media.npr.org/assets/img/2018/06/01/gettyimages-963767120_wide-7200de8f331eed3cfae99b91fcc95003662a75f6-s1100-c50.jpg"), visionFeature("DOCUMENT_TEXT_DETECTION", 10)
)

response = getResponse(newBody)
dictResponse = JSON.parse(String(response.body))