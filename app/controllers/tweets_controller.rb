class TweetsController < ApplicationController
  layout 'base'
  def index
    require 'hpricot'
    require 'open-uri'
    
    # Yahoo! Map service geocode http://developer.yahoo.com/maps/rest/V1/geocode.html
    # Twitter API http://apiwiki.twitter.com/Search-API-Documentation?SearchFor=location&sp=3
    # Google Maps http://code.google.com/apis/maps/documentation/introduction.html
    
    app_id = 'fxHTUTrV34EJvDAsVTomfVNKsl4iJkEhb.6D9F5Q0ni3SGCJcYBQcVG1QrMO_Ed4nEY5'
    @country = params[:country].gsub(' ', '%20')
    @city = params[:city].gsub(' ', '%20')
    @phrase = params[:phrase].gsub(' ', '%20')
    @location_url = "http://local.yahooapis.com/MapsService/V1/geocode?appid=#{app_id}&country=#{@country}&city=#{@city}"
    
    @geo_doc = open(@location_url) { |f| Hpricot(f) }
    
    @lat = @geo_doc.search('//latitude')[0].inner_html
    @long = @geo_doc.search('//longitude')[0].inner_html
    @map_url = "http://maps.google.com/maps?q=#{@lat},+#{@long}"
    
    @search_radius = 10

    @sample_date = params[:date] ? Date.parse(params[:date]) : Date.today
    day = "%02d" % @sample_date.day
    month = "%02d" % @sample_date.month
    year = @sample_date.year
    @twitter_geo_search_url = "http://search.twitter.com/search.atom?q=#{@phrase}&geocode=#{@lat}%2C#{@long}%2C#{@search_radius}km&rpp=100&since=#{year}-#{month}-#{day}&until=#{year}-#{month}-#{day}"
    #@twitter_geo_search_url = 'http://127.0.0.1:3000/temp/temp.atom'
    @tweet_doc = open(@twitter_geo_search_url) { |f| Hpricot(f) }
    @tweets = @tweet_doc.search('//entry')
  end
end
