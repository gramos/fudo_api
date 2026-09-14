require "rack"
require_relative "auth"
require_relative "auth_middleware"
require_relative "app"

auth = Auth.new(
  username: ENV.fetch("AUTH_USERNAME"),
  password: ENV.fetch("AUTH_PASSWORD")
)

use Rack::Deflater

use Rack::Static,
    urls: {
      "/AUTHORS" => "/AUTHORS",
      "/openapi.yaml" => "/openapi.yaml"
    },
    root: File.expand_path("public", __dir__),
    header_rules: [
      [%r{\A/AUTHORS\z},
       { "cache-control" => "public, max-age=86400" }],
      [%r{\A/openapi\.yaml\z},
       { "cache-control" => "no-store" }]
    ]

use AuthMiddleware, auth: auth

run App.new(auth: auth)
