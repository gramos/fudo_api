require_relative "test_helper"
require_relative "../auth"
require_relative "../auth_middleware"

class AuthMiddlewareTest < Minitest::Test
  def test_public_route_does_not_require_a_token
    next_app = lambda { |_env| [200, {}, ["public"]] }
    middleware = AuthMiddleware.new(next_app, auth: nil)
    env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/auth"
    }

    status, _headers, body = middleware.call(env)

    assert_equal 200, status
    assert_equal ["public"], body
  end

  def test_missing_token_is_rejected
    auth = Auth.new(username: "admin", password: "secret")
    next_app = lambda { |_env| flunk "The request should not reach the next app" }
    middleware = AuthMiddleware.new(next_app, auth: auth)
    env = { "PATH_INFO" => "/products" }

    status, _headers, body = middleware.call(env)

    assert_equal 401, status
    assert_equal({ "error" => "Unauthorized" }, JSON.parse(body.join))
  end

  def test_invalid_token_is_rejected
    auth = Auth.new(username: "admin", password: "secret")
    next_app = lambda { |_env| flunk "The request should not reach the next app" }
    middleware = AuthMiddleware.new(next_app, auth: auth)
    env = {
      "PATH_INFO" => "/products",
      "HTTP_AUTHORIZATION" => "Bearer invalid-token"
    }

    status, _headers, body = middleware.call(env)

    assert_equal 401, status
    assert_equal({ "error" => "Unauthorized" }, JSON.parse(body.join))
  end

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
