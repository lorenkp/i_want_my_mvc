class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    (http_method == req.request_method.downcase.to_sym) && !!(pattern =~ req.path)
  end

  def run(req, res)
    match_data = @pattern.match(req.path)
    route_params = Hash[match_data.names.zip(match_data.captures)]
    @controller_class
      .new(req, res, route_params)
      .invoke_action(action_name)
  end
end
