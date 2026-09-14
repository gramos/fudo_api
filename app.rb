require "json"
require "securerandom"

class App
  ROUTES = {
    ["POST", "/auth"] => :authenticate,
    ["POST", "/products"] => :create_product,
    ["GET", "/products"] => :list_products
  }.freeze

  def initialize(auth:)
    @auth = auth
    @products = {}
  end

  def call(env)
    action = ROUTES.fetch(
      [env["REQUEST_METHOD"], env["PATH_INFO"]],
      :not_found
    )

    send(action, env)
  rescue JSON::ParserError
    json_response(400, error: "Invalid JSON")
  end

  private

  def authenticate(env)
    data = JSON.parse(env["rack.input"].read)
    token = @auth.authenticate(data["username"], data["password"])

    return json_response(401, error: "Invalid credentials") unless token

    json_response(200, token: token, token_type: "Bearer")
  end

  def create_product(env)
    data = JSON.parse(env["rack.input"].read)
    name = data["name"]
    return json_response(400, error: "Name is required") unless valid_name?(name)

    product = {
      id: SecureRandom.uuid,
      name: name
    }

    Thread.new do
      sleep 5
      @products[product[:id]] = product
    end

    json_response(202, **product, status: "pending")
  end

  def list_products(_env)
    json_response(200, @products.values)
  end

  def valid_name?(name)
    name.is_a?(String) && !name.strip.empty?
  end

  def not_found(_env)
    json_response(404, error: "Route not found")
  end

  def json_response(status, data)
    [
      status,
      { "content-type" => "application/json" },
      [JSON.generate(data)]
    ]
  end
end
