require "json"
require "rack"
require_relative "../test_helper"

class ConfigTest < Minitest::Test
  def test_authenticated_client_can_list_products
    ENV["AUTH_USERNAME"] = "admin"
    ENV["AUTH_PASSWORD"] = "secret"
    app, = Rack::Builder.parse_file("config.ru")
    auth_env = Rack::MockRequest.env_for(
      "/auth",
      method: "POST",
      input: JSON.generate(username: "admin", password: "secret"),
      "CONTENT_TYPE" => "application/json"
    )
    _status, _headers, auth_body = app.call(auth_env)
    token = JSON.parse(auth_body.join)["token"]
    list_env = Rack::MockRequest.env_for(
      "/products",
      method: "GET",
      "HTTP_AUTHORIZATION" => "Bearer #{token}"
    )

    status, _headers, body = app.call(list_env)

    assert_equal 200, status
    assert_equal [], JSON.parse(body.join)
  end

  def test_unauthenticated_client_cannot_list_products
    ENV["AUTH_USERNAME"] = "admin"
    ENV["AUTH_PASSWORD"] = "secret"
    app, = Rack::Builder.parse_file("config.ru")
    env = Rack::MockRequest.env_for("/products", method: "GET")

    status, _headers, body = app.call(env)

    assert_equal 401, status
    assert_equal({ "error" => "Unauthorized" }, JSON.parse(body.join))
  end

  def test_unauthenticated_client_cannot_create_a_product
    ENV["AUTH_USERNAME"] = "admin"
    ENV["AUTH_PASSWORD"] = "secret"
    app, = Rack::Builder.parse_file("config.ru")
    env = Rack::MockRequest.env_for(
      "/products",
      method: "POST",
      input: JSON.generate(name: "Pizza"),
      "CONTENT_TYPE" => "application/json"
    )

    status, _headers, body = app.call(env)

    assert_equal 401, status
    assert_equal({ "error" => "Unauthorized" }, JSON.parse(body.join))
  end

  def test_authenticated_client_can_create_a_product
    ENV["AUTH_USERNAME"] = "admin"
    ENV["AUTH_PASSWORD"] = "secret"
    app, = Rack::Builder.parse_file("config.ru")
    auth_env = Rack::MockRequest.env_for(
      "/auth",
      method: "POST",
      input: JSON.generate(username: "admin", password: "secret"),
      "CONTENT_TYPE" => "application/json"
    )
    _status, _headers, auth_body = app.call(auth_env)
    token = JSON.parse(auth_body.join)["token"]
    product_env = Rack::MockRequest.env_for(
      "/products",
      method: "POST",
      input: JSON.generate(name: "Pizza"),
      "CONTENT_TYPE" => "application/json",
      "HTTP_AUTHORIZATION" => "Bearer #{token}"
    )

    status, _headers, body = app.call(product_env)
    response = JSON.parse(body.join)

    assert_equal 202, status
    assert_equal "Pizza", response["name"]
    assert_equal "pending", response["status"]
    refute_empty response["id"]
  end

  def test_authentication_works_through_the_rack_stack
    ENV["AUTH_USERNAME"] = "admin"
    ENV["AUTH_PASSWORD"] = "secret"
    app, = Rack::Builder.parse_file("config.ru")
    env = Rack::MockRequest.env_for(
      "/auth",
      method: "POST",
      input: JSON.generate(username: "admin", password: "secret"),
      "CONTENT_TYPE" => "application/json"
    )

    status, _headers, body = app.call(env)

    assert_equal 200, status
    refute_empty JSON.parse(body.join)["token"]
  end
end
