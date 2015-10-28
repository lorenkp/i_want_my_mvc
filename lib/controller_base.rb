require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './params'

class ControllerBase
  attr_reader :req, :res
  attr_accessor :already_built_response, :session

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
    @session = Session.new(req)
  end

  def redirect_to(url)
    raise 'already rendered' if already_built_response
    res.status = 302
    res['Location'] = url
    already_built_response = true
    session.store_session(res)
  end

  def render_template(content, content_type)
    raise 'already rendered' if already_built_response
    res.content_type = content_type
    res.body = content
    already_built_response = true
    session.store_session(res)
  end

  def render(template_name)
    template_contents =
      File.read("app/views/#{self.class.name.underscore}/#{template_name}.html.erb")
    render_template(ERB.new(template_contents).result(binding), 'text/html')
  end

  def invoke_action
    send(name)
    render(name) unless already_built_response
  end
end
