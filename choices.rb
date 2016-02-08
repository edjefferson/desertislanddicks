require 'active_record'
require 'pg'
require 'nokogiri'
require 'open-uri'

ActiveRecord::Base.establish_connection(
  :adapter  => "postgresql",
  :host     => "localhost",
  :username => ENV["DID_USER"],
  :password => ENV["DID_PASSWORD"],
  :database => "desertislanddicks"
)


class Guest < ActiveRecord::Base
end

class Track < ActiveRecord::Base
end

class Choice < ActiveRecord::Base
end

class Luxurie < ActiveRecord::Base
end

class Book < ActiveRecord::Base
end


Guest.all.each do |guest|
  
  if Choice.where(guest_id: guest.id).size == 0
    


    url = "#{guest.url}/segments"

    puts url
    puts guest.broadcast_date
    
    doc = Nokogiri::HTML(open(url))
    
      
  
    begin
      
      
    fav_artist=doc.css('li.segments-list__item--group').css('div[data-type="track_segment"]').attribute("data-title").to_s.split("||")[0].strip
    fav_title=doc.css('li.segments-list__item--group').css('div[data-type="track_segment"]').attribute("data-title").to_s.split("||")[1].strip
    
  rescue
    fav_artist=""
    fav_title=""
    
  end
    doc.css('div.segment--music').each do |track|
      begin
      artist = track.css('div[data-type="track_segment"]').attribute("data-title").to_s.split("||")[0].strip
      title = track.css('div[data-type="track_segment"]').attribute("data-title").to_s.split("||")[1].strip
      if title[0..6] == "Unknown"
        title = title.split(" - ")[1]
      end
      favourite = (1 if artist == fav_artist && title == fav_title) || 0 
    rescue
      artist = "N/A"
      title = track.css('span[property="name"]').inner_text
      favourite = (1 if artist == fav_artist && title == fav_title) || 0 

    end
    
      puts artist, title, favourite
      
     
      track = Track.where(artist: artist, title: title).first_or_create
      Choice.where(guest_id: guest.id, track_id: track.id).first_or_create do |choice|
        choice.favourite = favourite
        choice.selections =+ 1
      end
    end
    
  puts doc.css('div.text--prose').count
    
    
  if doc.css('div.text--prose').count==2
    begin
      
      old_format = doc.css('div.text--prose')[1].css('span').inner_text
      new_format = doc.css('div.text--prose')[1].css('p').inner_text 
      

      new_format == "" ? luxury_desc = old_format : luxury_desc = new_format
      
      luxury = Luxurie.where(luxury: luxury_desc).first_or_create
      
      Choice.where(guest_id: guest.id, luxury_id: luxury.id).first_or_create
      puts luxury_desc
    rescue
      luxury_desc = "a"
    end
  
  
    
    begin
    
      old_format = doc.css('div.text--prose')[0].css('span').inner_text
      new_format = doc.css('div.text--prose')[0].css('p').inner_text 
      


      new_format == "" ? book_desc = old_format : book_desc = new_format
      book = Book.where(book: book_desc).first_or_create
      Choice.where(guest_id: guest.id, book_id: book.id).first_or_create
      puts book_desc
    rescue
    
      book_desc = nil
    end
  
    
  else  
  
    begin
      old_format = doc.css('div.text--prose')[0].css('span').inner_text
      new_format = doc.css('div.text--prose')[0].css('p').inner_text 


      new_format == "" ? luxury_desc = old_format : luxury_desc = new_format

      luxury = Luxurie.where(luxury: luxury_desc).first_or_create
    
      Choice.where(guest_id: guest.id, luxury_id: luxury.id).first_or_create
      puts luxury_desc
    rescue
      luxury_desc = nil
    end
    
  end

else
  puts "already done"
end


    
end
