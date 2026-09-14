require "stringio"
require "json"
require_relative "test_helper"
require_relative "../app"

class AppTest < Minitest::Test
  def test_unknown_route_returns_not_found
    app = App.new
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
