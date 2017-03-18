require 'sinatra'
require 'json'

set :protection, except: [:json_csrf]
get '/' do
  content_type :json
  {
    hi: 'there'
  }.to_json
end
