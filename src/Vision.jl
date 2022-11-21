#module Vision

using HTTP
using JSON
using Base64
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
response = HTTP.post(url, headers, body)

dictResponse = JSON.parse(String(response.body))