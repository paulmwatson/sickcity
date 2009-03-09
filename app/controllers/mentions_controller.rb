class MentionsController < ApplicationController
  layout 'base'
  def index
    @sample_date = params[:date] ? Date.parse(params[:date]) : Date.today
    @city = City.find :first, :conditions => {:name => params[:city]}
    @phrase = Phrase.find :first, :conditions => {:title => params[:phrase]}
    
    update(@phrase, @city, @sample_date) if params[:update]
      
    @location = get_location(@city.name, @city.country)

    day = "%02d" % @sample_date.day
    month = "%02d" % @sample_date.month
    year = @sample_date.year
    date_range_start = "#{year}-#{month}-#{day} 00:00"
    date_range_end = "#{year}-#{month}-#{day} 23:59"
    @mentions = Mention.find :all, :conditions => {:phrase_id => @phrase.id, :city_id => @city.id, :mentioned_at => (date_range_start..date_range_end)}, :order => :mentioned_at
  end

  def update(phrase, city, sample_date)
    require 'hpricot'
    require 'open-uri'
    
    location = get_location(city.name, city.country)
    
    search_radius = 10

    day = "%02d" % sample_date.day
    month = "%02d" % sample_date.month
    year = sample_date.year
    twitter_geo_search_url = "http://search.twitter.com/search.atom?q=#{phrase.search.gsub(' ', '%20')}&geocode=#{location.latitude}%2C#{location.longitude}%2C#{search_radius}km&rpp=100&since=#{year}-#{month}-#{day}&until=#{year}-#{month}-#{day}"
    begin
      tweet_doc = open(twitter_geo_search_url) { |f| Hpricot(f) }
    rescue
    end
    
    if tweet_doc
      tweets = tweet_doc.search('//entry')
    
      tweets.each do |tweet|
        link = tweet.search('//link')[0].attributes['href']
        mention = Mention.find(:first, :conditions => {:link => link}) || Mention.new
        mention.link = link
        mention.mentioner = tweet.search('//name').text
        mention.mentioned_at = tweet.search('//published').text
        mention.exact_location = tweet.search('//google:location').text
        get_location(mention.exact_location, city.country)
        mention.city = city
        mention.phrase = phrase
        mention.save
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