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

class Occupation < ActiveRecord::Base
end

class GuestOccupation < ActiveRecord::Base
end




so_far = GuestOccupation.maximum(:guest_id) || 0

puts so_far

Guest.where("id > #{so_far}").each do |guest|
  

    url = "#{guest.url}"

    puts url
    puts guest.broadcast_date
    
    doc = Nokogiri::HTML(open(url))
    
    occupations = doc.css('div.did-castaway-occupations').css('a').each do |occupation_link|
      puts occupation_link.inner_text.strip
      occupation = Occupation.where(name: occupation_link.inner_text.strip).first_or_create
      GuestOccupation.where(guest_id: guest.id, occupation_id:occupation.id).first_or_create
    end
  
    

    
end
