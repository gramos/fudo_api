require "stringio"
require "json"
require_relative "test_helper"
require_relative "../auth"
require_relative "../app"

class AppTest < Minitest::Test
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
