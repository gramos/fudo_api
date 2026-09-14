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
    @tokens[token] = username
    token
  end

  def validate(token)
    @tokens[token]
  end
end
