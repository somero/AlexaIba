require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'aws-sdk'

task :update_feed do
  puts "Updating feed..."
  get_news
  puts "done."
end

def get_news
    # get current hour
    initial = "https://www.kan.org.il/radio/hourlynews.aspx"
    current_number = get_page(initial).to_s.scan(/ItemId = [0-9]*/).first.split(' ').last
    curr_hour_url = "https://www.kan.org.il/radio/hourlyNewsPlayer.aspx?ItemId=#{current_number}"

    # get player
    player_url = get_page(curr_hour_url).css('#playerFrame').attribute('src').value

    # get playlist url
    playlist_url = get_page(player_url).to_s.scan(/https.*playlist.m3u8/).first

    # get chunklist url
    chunklist_url = get_page(playlist_url).to_s.scan(/https.*/).first

    # get chunks
    medias = get_page(chunklist_url).to_s.split("\n").select {|x| x.include? ('media')}
    open("/tmp/join.txt", 'w') do |join|
        medias.each_with_index { |m, i|
            media_url = "#{chunklist_url.gsub(/\/chunklist.*/,'')}/#{m}"
            open("/tmp/audio_part#{i}.ts", 'wb') do |file|
                file << open(media_url).read
            end
            join.puts "file '/tmp/audio_part#{i}.ts'"
        }
    end

    # Join files
    `rm /tmp/news.ts`
    `ffmpeg -f concat -safe 0 -i /tmp/join.txt -c copy /tmp/news.ts`
    `rm /tmp/join.txt /tmp/audio*.ts`

    s3 = Aws::S3::Resource.new
    obj = s3.bucket(ENV['BUCKET']).object('last_news')
    obj.upload_file('/tmp/news.ts')
end

def get_page(url)
    Nokogiri::HTML(open(URI.parse(url)))
end
