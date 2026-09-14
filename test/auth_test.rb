require_relative "test_helper"
require_relative "../auth"

class AuthTest < Minitest::Test
  def test_valid_credentials_return_a_token
    auth = Auth.new(username: "admin", password: "secret")

    token = auth.authenticate("admin", "secret")

    refute_nil token
    refute_empty token
  end

  def test_generated_token_identifies_the_user
    auth = Auth.new(username: "admin", password: "secret")
    token = auth.authenticate("admin", "secret")

    assert_equal "admin", auth.validate(token)
  end

  def test_invalid_password_does_not_return_a_token
    auth = Auth.new(username: "admin", password: "secret")

    token = auth.authenticate("admin", "wrong")

    assert_nil token
  end

  def test_invalid_username_does_not_return_a_token
    auth = Auth.new(username: "admin", password: "secret")

    token = auth.authenticate("guest", "secret")

    assert_nil token
  end

  def test_unknown_token_is_not_valid
    auth = Auth.new(username: "admin", password: "secret")

    assert_nil auth.validate("unknown-token")
  end

  def test_expired_token_is_not_valid
    auth = Auth.new(username: "admin", password: "secret")
    issued_at = Time.now

    token = Time.stub(:now, issued_at) do
      auth.authenticate("admin", "secret")
    end

    result = Time.stub(:now, issued_at + 3601) do
      auth.validate(token)
    end

    assert_nil result
  end
end
