require 'rubygems'
require 'open-uri'
require 'model'
require 'Hpricot'

BASE_URL = "http://www.pitchforkmedia.com/node/"

def download(cid)
  url = "#{BASE_URL}#{cid}"
  puts "downloading #{url}" if cid % 100 == 0
  doc = Hpricot(open(url))
  content = get_content(cid, doc)
  if content
    save_content(content) 
  end
  return true
end

def acquire_lock(cid)
  return @lock if @lock
  @lock = cid
  return @lock
end

def get_content(cid, doc)
  begin
    full_title = (doc/"h2.fn").first.inner_html.strip
    artist = full_title.split(":").first
    title  = full_title.split(":").last.gsub(/<BR ?\/?>/i,'')
    rating = (doc/".rating").first.inner_html.strip.to_f
    review = (doc/".content.description").first.inner_html
    image_url = (doc/".url.photo img").first[:src]
    original_doc = doc.to_s
    return {
      :content_id     => cid,
      :full_title     => full_title,
      :artist         => artist,
      :title          => title,
      :rating         => rating,
      :review         => review,
      :image_url      => image_url,
      :review_summary => review.gsub(/<\/?[^>]*>/, "")[0..500],
      :original_doc   => doc.to_s
    }
  rescue Exception => e
    puts e
    return false
  end
end

def save_content(content)
    begin 
      puts "saving #{content[:content_id]} : #{content[:artist]} : #{content[:title]} : #{content[:rating]}"
      Review.create(content)
    rescue SQLite3::BusyException => e
      save_content(content)
    rescue Exception => e
      puts e.class + " " + e.message
    # ensure
    #   @lock = false
    end
end

def download_content
  content_id = 51800
  threads = []
  while true
    
    if Thread.list.size <= 100
      threads << Thread.new(content_id) do |cid|
        until download(cid) do
          begin
            read_file
          rescue Exception => e
            if e.is_a? Errno::EMFILE
              puts "too many open files...re-establishing connection"
              ActiveRecord::Base.connection.disconnect!
              ActiveRecord::Base.establish_connection({:adapter=>"sqlite3", 
                :dbfile => "/Users/will/db/pitchfork-reviews.db"})
            else
              puts "#{cid} : #{e.class}"
            end
          end
        end
      end
      content_id+=1
    end

  end
end

download_content