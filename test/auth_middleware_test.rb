require_relative "test_helper"
require_relative "../auth"
require_relative "../auth_middleware"

class AuthMiddlewareTest < Minitest::Test
  def test_valid_token_reaches_the_next_app
    auth = Auth.new(username: "admin", password: "secret")
    token = auth.authenticate("admin", "secret")
    next_app = lambda do |env|
      [200, {}, [env["auth.username"]]]
    end
    middleware = AuthMiddleware.new(next_app, auth: auth)
    env = {
      "PATH_INFO" => "/products",
      "HTTP_AUTHORIZATION" => "Bearer #{token}"
    }

    status, _headers, body = middleware.call(env)

    assert_equal 200, status
    assert_equal ["admin"], body
  end
end
