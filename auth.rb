require "securerandom"

class Auth
  def initialize(username:, password:)
    @username = username
    @password = password
  end

  def authenticate(username, password)
    return unless username == @username && password == @password

    SecureRandom.hex(32)
  end
end
