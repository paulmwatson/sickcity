class TweetsController < ApplicationController
  layout 'base'
  def index
    require 'hpricot'
    require 'open-uri'
    
    @phrase = params[:phrase].gsub(' ', '%20')
    
    # Twitter API http://apiwiki.twitter.com/Search-API-Documentation?SearchFor=location&sp=3
    # Google Maps http://code.google.com/apis/maps/documentation/introduction.html

    @country = params[:country].gsub(' ', '%20')
    @city = params[:city].gsub(' ', '%20')
    @location_url = "http://maps.google.com/maps/geo?q=#{@city},#{@country}&output=xml&oe=utf8&sensor=false&key=#{GOOGLE_API_KEY}"
    
    @geo_doc = open(@location_url) { |f| Hpricot(f) }
    
    @coords = @geo_doc.search('//coordinates')[0].inner_html
    @lat = @coords.split(',')[1]
    @long = @coords.split(',')[0]
    
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
