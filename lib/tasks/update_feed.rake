require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'aws-sdk'
require 'streamio-ffmpeg'

task :update_feed do
  puts "Updating feed..."
  get_news
  puts "done."
end

def get_news
    unless File.exist?('/tmp/last_news.mp4')
        base = "http://reshet.tv/news/channel2-news/daily-edition"
        url = base
        page = Nokogiri::HTML(open(url))
        lastnews = page.to_s.scan(/http[^\"]*newsitem-[0-9]*/).uniq.sort.last

        url = URI.parse(lastnews.gsub('\\', ''))
        page = Nokogiri::HTML(open(url))
        lastvid = page.to_s.scan(/http[^\"]*mahadura[^\"]*mp4/).uniq.first.gsub('\\', '')

        open("/tmp/last_news.mp4", 'wb') do |file|
            file << open(lastvid).read
        end
    end

    unless File.exist?('/tmp/news_audio.aac')
        movie = FFMPEG::Movie.new("/tmp/last_news.mp4")
        movie.transcode('/tmp/news_audio.aac', %w(-vn -acodec -strict -2 copy))
    end

    s3 = Aws::S3::Resource.new
    obj = s3.bucket(ENV['BUCKET']).object('last_news')
    obj.upload_file('/tmp/news_audio.aac')

    File.delete('/tmp/last_news.mp4')
    File.delete('/tmp/news_audio.aac')
end

