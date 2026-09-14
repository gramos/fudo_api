require "json"

class AuthMiddleware
  def initialize(app, auth:)
    @app = app
    @auth = auth
  end

  def call(env)
    return @app.call(env) unless protected_path?(env["PATH_INFO"])

    username = @auth.validate(extract_token(env))
    return unauthorized unless username

    env["auth.username"] = username
    @app.call(env)
  end

  private

  def protected_path?(path)
    path == "/products" || path.start_with?("/products/")
  end

  def extract_token(env)
    header = env["HTTP_AUTHORIZATION"].to_s
    match = header.match(/\ABearer +(\S+)\z/i)
    match && match[1]
  end

  def unauthorized
    [
      401,
      { "content-type" => "application/json" },
      [JSON.generate(error: "Unauthorized")]
    ]
  end
end
