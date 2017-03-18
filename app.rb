require 'sinatra'
require 'json'
require 'securerandom'

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
  `echo hi >> /tmp/file.txt`
  File.read('/tmp/file.txt')
end
