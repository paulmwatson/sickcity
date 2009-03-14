class MentionsController < ApplicationController
  layout 'base'
  def index
    @city = City.find :first, :conditions => {:name => params[:city]}
    @phrase = Phrase.find :first, :conditions => {:title => params[:phrase]}
    @location = get_location(@city.name, @city.country)
    
    # 30 day range centered on the current date
    range = 30
    @range_center = params[:date] ? Date.parse(params[:date]) : Date.today
    @range_start = @range_center - (range / 2)
    @range_end = @range_center + (range / 2)

    # Data is updated hourly for today
    last_update = History.find :first, :conditions => {:city_id => @city.id, :phrase_id => @phrase.id}, :order => :last_get
    update(@phrase, @city, @range_center) if params[:update] || !last_update || last_update.last_get < (Time.now - (60 * 60))

    @mentions = Mention.find :all, :select => "DATE(mentioned_at) as mentioned_at_date, mentioned_at, mentioner, link, exact_location", :group => 'mentioner, mentioned_at_date', :conditions => {:phrase_id => @phrase.id, :city_id => @city.id, :mentioned_at => ("#{@range_start.year}-#{@range_start.month.to_s.rjust(2, '0')}-#{@range_start.day.to_s.rjust(2, '0')} 00:00".."#{@range_end.year}-#{@range_end.month.to_s.rjust(2, '0')}-#{@range_end.day.to_s.rjust(2, '0')} 23:59")}, :order => :mentioned_at
    @twenty_four_hour_count = Mention.count :conditions => {:phrase_id => @phrase.id, :city_id => @city.id, :mentioned_at => ("#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 00:00".."#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 23:59")}
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
      history = History.find(:first, :conditions => {:city_id => @city.id, :phrase_id => @phrase.id}) || History.new
      history.city_id = city.id
      history.phrase_id = phrase.id
      history.last_get = Time.now
      history.save
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
  
  # Temporary import of Dan's 60 days of data
  def import_60_days
    require 'hpricot'
    
    cities = City.find :all
    cities.each do |city|
      phrases = Phrase.find :all
      phrases.each do |phrase|
        puts "Importing #{city.name} - #{phrase.title}"
        doc = open("./public/temp/60days/#{city.name.gsub(' ', '')}-#{phrase.title.gsub(' ','+')}") { |f| Hpricot(f) }
        tweets = doc.search('//entry')
        tweets.each do |tweet|
          link = tweet.search('//link')[0].attributes['href']
          mention = Mention.find(:first, :conditions => {:link => link}) || Mention.new
          mention.link = link
          mention.mentioner = tweet.search('//name').text
          mention.mentioned_at = tweet.search('//published').text
          mention.exact_location = tweet.search('//google:location').text
          mention.city = city
          mention.phrase = phrase
          mention.save
        end
      end
    end
     
    render :text => 'Imported lots'
  end
end