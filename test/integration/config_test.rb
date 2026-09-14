require "json"
require "rack"
require_relative "../test_helper"

class ConfigTest < Minitest::Test
  def test_authentication_response_is_compressed_when_requested
    ENV["AUTH_USERNAME"] = "admin"
    ENV["AUTH_PASSWORD"] = "secret"
    app, = Rack::Builder.parse_file("config.ru")
    env = Rack::MockRequest.env_for(
      "/auth",
      method: "POST",
      input: JSON.generate(username: "admin", password: "secret"),
      "CONTENT_TYPE" => "application/json",
      "HTTP_ACCEPT_ENCODING" => "gzip"
    )

    _status, headers, _body = app.call(env)

    assert_equal "gzip", headers["content-encoding"]
    assert_equal "Accept-Encoding", headers["vary"]
  end

  def test_created_product_is_available_after_five_seconds
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
    create_env = Rack::MockRequest.env_for(
      "/products",
      method: "POST",
      input: JSON.generate(name: "Pizza"),
      "CONTENT_TYPE" => "application/json",
      "HTTP_AUTHORIZATION" => "Bearer #{token}"
    )

    _status, _headers, create_body = app.call(create_env)
    product_id = JSON.parse(create_body.join)["id"]

    sleep 5.1

    list_env = Rack::MockRequest.env_for(
      "/products",
      method: "GET",
      "HTTP_AUTHORIZATION" => "Bearer #{token}"
    )
    _status, _headers, list_body = app.call(list_env)

    assert_includes JSON.parse(list_body.join), {
      "id" => product_id,
      "name" => "Pizza"
    }
  end

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
