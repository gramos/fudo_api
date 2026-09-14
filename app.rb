require "json"

class App
  def call(_env)
    [
      404,
      { "content-type" => "application/json" },
      [JSON.generate(error: "Route not found")]
    ]
  end
end
