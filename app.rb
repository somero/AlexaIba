require 'sinatra'
require 'json'
require 'securerandom'
require 'open-uri'

set :protection, except: [:json_csrf]
get '/' do
  content_type :json
  {
    uid: SecureRandom.uuid,
    updateDate: Time.now.utc.iso8601,
    titleText: 'Iba News',
    mainText: '',
    streamUrl: 'https://iba-news.herokuapp.com/last_news'
  }.to_json
end

get '/last_news' do
  content_type 'audio/mpeg'
  open('http://www.orangefreesounds.com/wp-content/uploads/2017/01/Angry-dog-growling.mp3').read
end
