class PhrasesController < ApplicationController
  layout 'base'
  def index
    @city = City.find :first, :conditions => {:name => params[:city]}
    @phrases = Phrase.find :all, :order => 'title'
    @location = get_location(@city.name, @city.country)
    
    # 30 day range centered on the current date
    @range = 30
    @range_center = !params[:date].blank? ? Date.parse(params[:date]) : Date.today
    @range_start = @range_center - (@range / 2)
    @range_end = @range_center + (@range / 2)
    
    @twenty_four_hour_count = Mention.find :all, :select => "DATE(mentioned_at) as mentioned_at_date, mentioned_at, substring_index(mentioner, ' (', 1) as mentioner_stripped, mentioner, link, exact_location", :group => 'mentioner_stripped, mentioned_at_date', :conditions => {:city_id => @city.id, :mentioned_at => ("#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 00:00".."#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 23:59")}
    
    @mentions = Mention.find :all, :select => "id, message, DATE(mentioned_at) as mentioned_at_date, mentioned_at, substring_index(mentioner, ' (', 1) as mentioner_stripped, mentioner, link, exact_location, phrase_id", :group => 'mentioned_at_date, mentioner_stripped', :conditions => {:city_id => @city.id, :mentioned_at => ("#{@range_start.year}-#{@range_start.month.to_s.rjust(2, '0')}-#{@range_start.day.to_s.rjust(2, '0')} 00:00".."#{@range_end.year}-#{@range_end.month.to_s.rjust(2, '0')}-#{@range_end.day.to_s.rjust(2, '0')} 23:59")}, :order => :mentioned_at
    @graph_max = Mention.find(:first, :conditions => {:city_id => @city.id}, :group => 'mentioned_at_date, mentioner_stripped', :select => "substring_index(mentioner, ' (', 1) as mentioner_stripped, DATE(mentioned_at) as mentioned_at_date, count(id) as graph_max", :order => 'graph_max DESC').graph_max
        
    @trend = Hash.new()
    @phrases.each do |phrase|
      @trend[phrase.id] = Array.new((@range +1),0)
    end
    
    @thirty_day_trend = Array.new((@range + 1),0)
    @hour_trend = Array.new(24,0)
    
    @mentions.each do |mention|
      #@trend[mention.phrase_id][mention.mentioned_at.hour] = @trend[mention.phrase_id][mention.mentioned_at.hour] + 1
      
      published_date = mention.mentioned_at
      # Work out day difference of mention and update array
      index = ((published_date.to_date - @range_end) + @range).to_i
      @thirty_day_trend[index] = @thirty_day_trend[index] + 1
      
      if (mention.phrase_id != -1)
        @trend[mention.phrase_id][index] = @trend[mention.phrase_id][index] + 1
      end
      
      if (published_date.to_date == @range_center)
        @hour_trend[published_date.hour] = @hour_trend[published_date.hour] + 1
      end
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
