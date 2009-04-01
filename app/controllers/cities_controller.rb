class CitiesController < ApplicationController
  layout 'base'
  
  #caches_page :index

  def index
    @cities = City.find :all, :order => 'country, name', :conditions => {:hidden => false, :country => params[:country]}
    @topten_cities = Mention.find :all, :group => 'city_id', :select => 'count(id) as city_mentions, city_id', :order => 'city_mentions DESC', :limit => 20
    @location = get_location(params[:country])
    
    @mentions = Mention.find :all, :conditions => {:mentioned_at => ("#{Date.today.year}-#{Date.today.month.to_s.rjust(2, '0')}-#{Date.today.day.to_s.rjust(2, '0')} 00:00".."#{Date.today.year}-#{Date.today.month.to_s.rjust(2, '0')}-#{Date.today.day.to_s.rjust(2, '0')} 23:59")}, :order => :mentioned_at
    
    @trend = Hash.new()
    @cities.each do |city|
      @trend[city.id] = Array.new(24,0)
    end
    
    @mentions.each do |mention|
      begin
        @trend[mention.city_id][mention.mentioned_at.hour] = @trend[mention.city_id][mention.mentioned_at.hour] + 1
      rescue
      end
    end
  end
  
  def new
    @city = City.new
  end
  
  def check
    @city = City.new
    @city.name = params[:city][:name]
    @location = get_location(@city.name)
  end
  
  def create
    @city = City.find(:first, :conditions => {:name => params[:city][:name]})
    if !@city
      @city = City.new(params[:city])
      @city.save
      expire_page :controller => '/', :action => :index
      flash[:notice] = "We have added #{@city.name} to SickCity. It can take a few hours for the first results to show up though, please be patient."
    end
    redirect_to "/#{@city.country.gsub(' ', '%20')}/#{@city.name.gsub(' ', '%20')}"
  end
  
  
  def get_location(place)
    require 'hpricot'
    require 'open-uri'

    #location = Location.find :first, :conditions => {:name => place}
    location = nil
    if !location
      geocode_url = "http://maps.google.com/maps/geo?q=#{place.gsub(' ', '%20')}&output=xml&oe=utf8&sensor=false&key=#{GOOGLE_API_KEY}"
      puts geocode_url
      geocode_doc = open(geocode_url) { |f| Hpricot(f) }

      coords_ele = geocode_doc.search('//coordinates')[0]
      if coords_ele
        coords = coords_ele.inner_html
      else
        coords = '0,0'
      end

      location = Location.new
      location.name = place
      location['country'] = geocode_doc.search('//countryname')[0].inner_html
      location.latitude = coords.split(',')[1]
      location.longitude = coords.split(',')[0]
      location.save
    end
    location
  end
end
