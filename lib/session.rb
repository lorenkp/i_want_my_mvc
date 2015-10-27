require 'json'
require 'webrick'

class Session
  def initialize(req)
    found_cookie = req.cookies.find { |c| c.name == '_my_mvc_' }
    @cookie = found_cookie ? JSON.parse(cookie.value) : {}
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_my_mvc_', @cookie.to_json)
  end
end
