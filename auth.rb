require "securerandom"

class Auth
  def initialize(username:, password:)
    @username = username
    @password = password
    @tokens = {}
  end

  def authenticate(username, password)
    return unless username == @username && password == @password

    token = SecureRandom.hex(32)
    @tokens[token] = {
      username: username,
      expires_at: Time.now + 3600
    }
    token
  end

  def validate(token)
    session = @tokens[token]
    return unless session
    return unless session[:expires_at] > Time.now

    session[:username]
  end
end
