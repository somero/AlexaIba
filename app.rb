require 'sinatra'
require 'json'

set :protection, except: [:json_csrf]
get '/' do
  content_type :json
  {
    uid: Time.now,
    updateDate: Time.now.utc.iso8601,
    titleText: 'Iba News',
    mainText: 'Maintextwat'
    # streamUrl: 'https://iba-news.herokuapp.com/last_news'
  }.to_json
end
