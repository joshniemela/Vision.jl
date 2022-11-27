using Documenter
using Vision

makedocs(
    sitename = "Vision.jl",
    format = Documenter.HTML(),
    modules = [Vision]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/joshniemela/Vision.jl"
)
