require_relative "test_helper"
require_relative "../auth"

class AuthTest < Minitest::Test
  def test_valid_credentials_return_a_token
    auth = Auth.new(username: "admin", password: "secret")

    token = auth.authenticate("admin", "secret")

    refute_nil token
    refute_empty token
  end
end
