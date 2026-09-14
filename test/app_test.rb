require "stringio"
require "json"
require_relative "test_helper"
require_relative "../auth"
require_relative "../app"

class AppTest < Minitest::Test
  def test_creates_a_product_asynchronously
    auth = Auth.new(username: "admin", password: "secret")
    app = App.new(auth: auth)
    env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/products",
      "auth.username" => "admin",
      "rack.input" => StringIO.new(JSON.generate(name: "Pizza"))
    }

    status, _headers, body = app.call(env)
    response = JSON.parse(body.join)

    assert_equal 202, status
    refute_empty response["id"]
    assert_equal "Pizza", response["name"]
    assert_equal "pending", response["status"]
  end

  def test_created_product_is_not_available_immediately
    auth = Auth.new(username: "admin", password: "secret")
    app = App.new(auth: auth)
    create_env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/products",
      "auth.username" => "admin",
      "rack.input" => StringIO.new(JSON.generate(name: "Pizza"))
    }
    list_env = {
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/products",
      "auth.username" => "admin",
      "rack.input" => StringIO.new
    }

    app.call(create_env)
    status, _headers, body = app.call(list_env)

    assert_equal 200, status
    assert_equal [], JSON.parse(body.join)
  end

  def test_created_product_becomes_available_after_five_seconds
    auth = Auth.new(username: "admin", password: "secret")
    app = App.new(auth: auth)
    create_env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/products",
      "auth.username" => "admin",
      "rack.input" => StringIO.new(JSON.generate(name: "Pizza"))
    }
    list_env = {
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/products",
      "auth.username" => "admin",
      "rack.input" => StringIO.new
    }

    _status, _headers, create_body = app.call(create_env)
    product_id = JSON.parse(create_body.join)["id"]

    sleep 5.1

    _status, _headers, list_body = app.call(list_env)
    products = JSON.parse(list_body.join)

    assert_includes products, { "id" => product_id, "name" => "Pizza" }
  end

  def test_authenticates_valid_credentials
    auth = Auth.new(username: "admin", password: "secret")
    app = App.new(auth: auth)
    env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/auth",
      "rack.input" => StringIO.new(
        JSON.generate(username: "admin", password: "secret")
      )
    }

    status, headers, body = app.call(env)
    response = JSON.parse(body.join)

    assert_equal 200, status
    assert_equal "application/json", headers["content-type"]
    refute_empty response["token"]
    assert_equal "Bearer", response["token_type"]
  end

  def test_rejects_invalid_credentials
    auth = Auth.new(username: "admin", password: "secret")
    app = App.new(auth: auth)
    env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/auth",
      "rack.input" => StringIO.new(
        JSON.generate(username: "admin", password: "wrong")
      )
    }

    status, _headers, body = app.call(env)

    assert_equal 401, status
    assert_equal({ "error" => "Invalid credentials" }, JSON.parse(body.join))
  end

  def test_rejects_invalid_json
    auth = Auth.new(username: "admin", password: "secret")
    app = App.new(auth: auth)
    env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/auth",
      "rack.input" => StringIO.new("not-json")
    }

    status, _headers, body = app.call(env)

    assert_equal 400, status
    assert_equal({ "error" => "Invalid JSON" }, JSON.parse(body.join))
  end

  def test_unknown_route_returns_not_found
    app = App.new(auth: Auth.new(username: "admin", password: "secret"))
    env = {
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/unknown",
      "rack.input" => StringIO.new
    }

    status, headers, body = app.call(env)

    assert_equal 404, status
    assert_equal "application/json", headers["content-type"]
    assert_equal({ "error" => "Route not found" }, JSON.parse(body.join))
  end
end
