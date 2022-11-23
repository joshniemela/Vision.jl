module Vision
using HTTP
using JSON
using URIs

export makeRequestBody
export visionFeature
export getResponse
export parseFeatures


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

function makeRequestBody(imageString::String, features)  
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

    Create a dictionary containing the feature type and max results.

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
- `URL` URL of the API, defaults to `https://vision.googleapis.com/v1/images:annotate`, this can be changed to use a different API or if it isn't possible to load environment variables.  
- `headers` headers for the request, defaults to []

# Returns
- `Dict{String, Any}` response from the API
"""
function getResponse(requestBody::String,
    URL::String="https://vision.googleapis.com/v1/images:annotate?key=$(ENV["JULIA_VISION_API_KEY"])",
    headers = [])
    # Send request to Google Vision API
    # requestBody: request body
    # return: response body
    response = HTTP.post(URL, headers, requestBody)

    return JSON.parse(String(response.body))
end

"""
    parseFeatures(responseBody)

    Parse the response body from the Google Vision API, returns the dictionary if the method hasn't been implemented. Otherwise return formatted output.

# Arguments
- `responseBody` response body from the API

# Returns
- Dictionary containing raw features or formatted output
"""
function parseFeatures(responseBody)
    function getBBox(boundingPoly)
        vertices = boundingPoly["vertices"]
        map(x -> Tuple(values(x)), vertices)
    end
    responses = responseBody["responses"][1]
    parsedResponse = Dict()
    for (key, value) in responses
        if key == "textAnnotations"
            annotationsDict = Dict("combined" => Dict(), "annotations" => [])
            # Get combined text since this is different from the other annotations
            annotationsDict["combined"]["locale"] = value[1]["locale"]
            annotationsDict["combined"]["text"] = value[1]["description"]
            annotationsDict["combined"]["boundingPoly"] = getBBox(value[1]["boundingPoly"])
            for annotation in value[2:end]
                push!(annotationsDict["annotations"], Dict(
                    "text" => annotation["description"],
                    "boundingPoly" => getBBox(annotation["boundingPoly"])
                ))
            end
            parsedResponse[key] = annotationsDict
        else
            @warn "Method not implemented for $key, returning raw response"
            parsedResponse[key] = value
        end
    end
    parsedResponse
end

end