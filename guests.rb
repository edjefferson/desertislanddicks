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

class Year < ActiveRecord::Base
end

class Guest < ActiveRecord::Base
end

Year.all.each do |year|
  
  (1..year.pages).to_a.reverse.each do |page|

    url = "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway?year=#{year.year}&page=#{page}"
    puts url
    
    doc = Nokogiri::HTML(open(url))
    
    doc.css('div.did-search-item').reverse.each do |guest_info|
      guest_url = guest_info.css('h4/a').attribute("href").to_s
      
    
      Guest.where(url: guest_url).first_or_create do |guest|
      
        guest.name = guest_info.css('h4/a').inner_text 
        guest.broadcast_date = guest_info.css('p.did-date').inner_text.split("|")[1].strip
        guest.bio = guest_info.css('p.did-castaways-known-for').inner_text
        puts "#{guest.id} #{guest.broadcast_date} #{guest.name} scraped"
      end
      
    end
    
  end
end