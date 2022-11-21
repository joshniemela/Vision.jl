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


#function uploadImage(image::String)
#    doStuff(image)
#
#function uploadImage(image::bytes)
#    uploadImage(bytestream2string(image))
#
#function uploadImage(image::Array{UInt8, 3})
#    uploadImage(image2string(image))

"""
    makeRequestBody(image, features)

Create the request body for the Google Vision API.

# Arguments
- `image::String` base64 encoded image or URI
- `features::Array{Dict{String, Any}}` list of features to request from the API

# Returns
- `Dict{String, Any}` request body
"""
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
function makeRequestBody(imageURI::URI, features::Vector{Dict{String, Any}})  
    Dict("requests" =>
        [
            Dict(
                "image" => Dict("source" => Dict("imageUri" => URIs.uristring(imageURI))),
                "features" => features
            )
        ]
    ) |> JSON.json
end

function getResponse

API_KEY =  try 
    ENV["JULIA_VISION_API_KEY"]
catch
    error("Please set the environment variable JULIA_VISION_API_KEY to your API key")
end

url = "https://vision.googleapis.com/v1/images:annotate?key=$API_KEY"

params = Dict("requests" =>
    [
        Dict(
            "image" => Dict("source" => Dict("imageUri" => "https://upload.wikimedia.org/wikipedia/commons/9/9b/Gustav_chocolate.jpg")),

            "features" => [
                Dict("type" => "WEB_DETECTION", "maxResults" => 10),
            ]
        )
    ]
)

HTRparams = Dict("requests" =>
    [
        Dict(
            "image" => Dict("content" => image2string("example.png")),

            "features" => [
                Dict("type" => "DOCUMENT_TEXT_DETECTION", "maxResults" => 10),
            ]
        )
    ]
)
body = JSON.json(HTRparams)


headers = []
#response = HTTP.post(url, headers, body)

newBody = makeRequestBody(
    image2string("example.png"), 
    [
        Dict("type" => "DOCUMENT_TEXT_DETECTION", "maxResults" => 10)
    ]
)

newBody = makeRequestBody(
    URI("https://upload.wikimedia.org/wikipedia/commons/9/9b/Gustav_chocolate.jpg"), 
    [
        Dict("type" => "WEB_DETECTION", "maxResults" => 10)
    ]
)

response = HTTP.post(url, headers, newBody)
dictResponse = JSON.parse(String(response.body))