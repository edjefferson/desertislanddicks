require 'active_record'
require 'pg'
require 'nokogiri'
require 'open-uri'
require 'date'

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



year=1942
pageno=1

last_incomplete_year = Guest.maximum(:broadcast_date).strftime("%Y")

puts last_incomplete_year

sleep 15

while year<=last_incomplete_year

  url = "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway?year=#{year}"

  doc = Nokogiri::HTML(open(url))
  
  total_guests = doc.css('p#did-search-found/span').inner_html.split[0].to_i
  
  pages = (total_guests.to_f/20).ceil
  
  Year.where(year: year).first_or_create do |year|
    year.total_guests = total_guests
    year.pages = pages
  end
  puts "#{year} scraped"
  
  year += 1
end