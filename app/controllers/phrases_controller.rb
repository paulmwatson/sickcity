class PhrasesController < ApplicationController
  layout 'base'
  def index
    @city = City.find :first, :conditions => {:name => params[:city]}
    @phrases = Phrase.find :all, :order => 'title'
    @location = get_location(@city.name, @city.country)
    
    @working_date = Date.today
    @mentions = Mention.find :all, :conditions => {:city_id => @city.id, :mentioned_at => ("#{@working_date.year}-#{@working_date.month.to_s.rjust(2, '0')}-#{@working_date.day.to_s.rjust(2, '0')} 00:00".."#{@working_date.year}-#{@working_date.month.to_s.rjust(2, '0')}-#{@working_date.day.to_s.rjust(2, '0')} 23:59")}, :order => :mentioned_at
    
    @trend = Hash.new()
    @phrases.each do |phrase|
      @trend[phrase.id] = Array.new(24,0)
    end
    
    @mentions.each do |mention|
      @trend[mention.phrase_id][mention.mentioned_at.hour] = @trend[mention.phrase_id][mention.mentioned_at.hour] + 1
    end
  end
  
  def get_location(city, country)
    require 'hpricot'
    require 'open-uri'

    location = Location.find :first, :conditions => {:name => city}
    if !location
      begin
        geocode_url = "http://maps.google.com/maps/geo?q=#{city.gsub(' ', '%20')},#{country.gsub(' ', '%20')}&output=xml&oe=utf8&sensor=false&key=#{GOOGLE_API_KEY}"
        geocode_doc = open(geocode_url) { |f| Hpricot(f) }

        coords_ele = geocode_doc.search('//coordinates')[0]
      rescue
      end
      
      if coords_ele
        coords = coords_ele.inner_html
      else
        coords = '0,0'
      end

      location = Location.new
      location.name = city
      location.latitude = coords.split(',')[1]
      location.longitude = coords.split(',')[0]
      location.save
    end
    location
  end
  
end
