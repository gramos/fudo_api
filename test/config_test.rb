require "json"
require "rack"
require_relative "test_helper"

class ConfigTest < Minitest::Test
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
