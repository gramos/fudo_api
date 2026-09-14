require "rack"
require_relative "auth"
require_relative "auth_middleware"
require_relative "app"

auth = Auth.new(
  username: ENV.fetch("AUTH_USERNAME"),
  password: ENV.fetch("AUTH_PASSWORD")
)

use Rack::Deflater
use AuthMiddleware, auth: auth

run App.new(auth: auth)
