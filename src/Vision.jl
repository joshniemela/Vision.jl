module Vision

using HTTP
using JSON
url = "https://vision.googleapis.com/v1/images:annotate"
params = Dict

request = HTTP.request("POST", url, JSON.json(params))