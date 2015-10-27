class ControllerBase
  attr_reader :req, :res
  attr_accessor :already_built_response

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  def redirect_to(url)
    raise 'already rendered' if already_built_response?
    res.status = 302
    res['Location'] = url
    @already_built_response = true
  end

  def render

  end

  def render_template

  end

  def session

  end

  def invoke_action

  end
end
