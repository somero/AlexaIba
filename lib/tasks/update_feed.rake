require 'rubygems'
require 'nokogiri'
require 'open-uri'

task :update_feed do
  puts "Updating feed..."
  get_news
  puts "done."
end

def get_news
    base = "www.iba.org.il"
    url = URI.parse("http://#{base}/index.aspx?cat=1")
    page = Nokogiri::HTML(open(url))
    lastnews = page.css('.mahadorut li:first-child a').attribute('href').value

    url = URI.parse("http://#{base}/#{lastnews}")
    page = Nokogiri::HTML(open(url))
    vimmid = page.css('#playerUrl').text
    meta = metadata_url(vimmid)

    metadata = Nokogiri::XML(open(meta))
    playlist_url = metadata.at_css('SmilURL').text

    pl =open(playlist_url) { |io| data = io.read }
    chunk_list = pl.split("\n").select {|x| x.include? ('chunklist')}.first
    chunks_url = "#{playlist_url.gsub(/\/playlist.*/,'')}/#{chunk_list}"

    medias_file = open(chunks_url) { |io| data = io.read }
    medias = medias_file.split("\n").select {|x| x.include? ('media')}
    open("/tmp/join.txt", 'w') do |join|
        medias.each_with_index { |m, i| 
            media_url = "#{playlist_url.gsub(/\/playlist.*/,'')}/#{m}"    
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
end


def metadata_url(vimmiID)
    deliveryType = 'hls'
    siteName = 'iba'
    accountName = 'iba'
    searchString = '?smil_profile=default'
    metaUrl = "http://" + accountName + "-metadata-rr-d.vidnt.com/"
    metaUrl += "vod/vod/"
    metaUrl += (vimmiID + "/" + deliveryType + "/metadata.xml")
    metaUrl + searchString
end

