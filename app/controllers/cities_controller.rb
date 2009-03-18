class CitiesController < ApplicationController
  layout 'base'
  
  caches_page :index

  def index
    @cities = City.find :all, :order => 'country, name', :conditions => {:hidden => false}
    @topten_cities = Mention.find :all, :group => 'city_id', :select => 'count(id) as city_mentions, city_id', :order => 'city_mentions DESC', :limit => 20
    
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
    @city.country = params[:city][:country]
    @location = get_location(@city.name, @city.country)
  end
  
  def create
    @city = City.find(:first, :conditions => {:name => params[:city][:name]}) || City.new(params[:city])
    
    expire_page :controller => '/', :action => :index

    if @city.save
      flash[:notice] = 'City was successfully created.'
      redirect_to "/#{@city.country.gsub(' ', '%20')}/#{@city.name.gsub(' ', '%20')}"
    else
      render :action => "new"
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
