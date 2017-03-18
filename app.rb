require 'sinatra'
require 'json'

get '/' do
  content_type :json
  {
    hi: 'there'
  }
end
