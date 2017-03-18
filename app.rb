require 'sinatra'
require 'json'
require 'securerandom'
require 'open-uri'
require 'nokogiri'
require 'aws-sdk'

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
  begin
    content_type 'audio/mpeg'
    s3 = Aws::S3.new
    s3.buckets[ENV['BUCKET']].objects['last_news'].read
  rescue => e
    content_type :json
    {
      error: e.message
    }.to_json
  end
end
