require 'uri'

class Params
  def initialize(req, route_params = {})
    @params = route_params
    @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
    @params.merge!(parse_www_encoded_form(req.body)) if req.body
  end

  def [](key)
    @params[key.to_s] || @params[key.to_sym]
  end

  private

  def parse_www_encoded_form(www_encoded_form)
    params = {}
    key_val_pairs = URI::decode_www_form(www_encoded_form)
    key_val_pairs.each do |keys, val|
      sub_hash = params
      nested_keys = parse_key(keys)
      nested_keys.each_with_index do |key, idx|
        if (idx + 1) == nested_keys.length
          sub_hash[key] = val
        else
          sub_hash[key] ||= {}
          sub_hash = sub_hash[key]
        end
      end
    end
    params
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
