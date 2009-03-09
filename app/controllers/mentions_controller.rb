class MentionsController < ApplicationController
  layout 'base'
  def index
    @sample_date = params[:date] ? Date.parse(params[:date]) : Date.today
    @city = City.find :first, :conditions => {:name => params[:city]}
    @phrase = Phrase.find :first, :conditions => {:title => params[:phrase]}
    
    update(@phrase, @city, @sample_date) if params[:update]
      
    @location = get_location(@city.name, @city.country.name)

    day = "%02d" % @sample_date.day
    month = "%02d" % @sample_date.month
    year = @sample_date.year
    date_range_start = "#{year}-#{month}-#{day} 00:00"
    date_range_end = "#{year}-#{month}-#{day} 23:59"
    @mentions = Mention.find :all, :conditions => {:phrase_id => @phrase.id, :city_id => @city.id, :mentioned_at => (date_range_start..date_range_end)}, :order => :mentioned_at
  end
  
  def update_urls
    cities = City.find :all, :conditions => {:name => 'New York'}
    phrases = Phrase.find :all

    search_radius = 10

    cities.each do |city|
      phrases.each do |phrase|
        sample_date = Date.today
        location = get_location(city.name, city.country.name)
        
        30.times do |date|
          sample_date = sample_date - 1
          day = "%02d" % sample_date.day
          month = "%02d" % sample_date.month
          year = sample_date.year
          url = "http://search.twitter.com/search.atom?q=#{phrase.search.gsub(' ', '%20')}&geocode=#{location.latitude}%2C#{location.longitude}%2C#{search_radius}km&rpp=100&since=#{year}-#{month}-#{day}&until=#{year}-#{month}-#{day}"
          
          url_to_download = UrlDownloads.find(:first, :conditions => {:url => url}) || UrlDownloads.new
          url_to_download.filename = "#{city.name.gsub(' ', '')}_#{phrase.title.gsub(' ', '')}_#{year}#{month}#{day}.xml"
          url_to_download.url = url
          url_to_download.city_id = city.id
          url_to_download.phrase_id = phrase.id
          url_to_download.sample_date = sample_date
          url_to_download.save
        end
      end
    end
    
    @urls = UrlDownloads.find :all, :order => :updated_at
  end
  
  def import_downloaded
    require 'hpricot'
    @files_to_import = UrlDownloads.find :all, :conditions => {:imported => false, :downloaded => true}
    @files_to_import.each do |file_to_import|
      doc = open("public/temp/#{file_to_import.filename}") { |f| Hpricot(f) }
      
      mentions = doc.search('//entry')
    
      mentions.each do |mention|
        link = mention.search('//link')[0].attributes['href']
        new_mention = Mention.find(:first, :conditions => {:link => link}) || Mention.new
        new_mention.link = link
        new_mention.mentioner = mention.search('//name').text
        new_mention.mentioned_at = mention.search('//published').text
        new_mention.exact_location = mention.search('//google:location').text
        city = City.find file_to_import.city_id
        new_mention.city = city
        phrase = Phrase.find file_to_import.phrase_id
        new_mention.phrase = phrase
        new_mention.save
      end
      
      file_to_import.imported = true
      file_to_import.updated_at = Time.now
      file_to_import.save
      
    end
  end
  
  def download_urls
    @urls_to_download = UrlDownloads.find :all, :conditions => {:downloaded => false}, :order => 'updated_at ASC', :limit => 2
    @urls_to_download.each do |url_to_download|
      sleep 5
      puts url_to_download.url
      begin
        file_to_use = "public/temp/#{url_to_download.filename}"
        if (!File.exists? file_to_use)
          open(file_to_use, 'w').write(open(url_to_download.url).read)
        end
        url_to_download.downloaded = true
        url_to_download.save
      rescue
        # Push to bottom of queue by updating record
        url_to_download.updated_at = Time.now
        url_to_download.downloaded = false
        url_to_download.save
      end
    end
    @count = UrlDownloads.count :conditions => {:downloaded => false}
  end
  
  def update(phrase, city, sample_date)
    require 'hpricot'
    require 'open-uri'
    
    location = get_location(city.name, city.country.name)
    
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
        get_location(mention.exact_location, city.country.name)
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
      geocode_url = "http://maps.google.com/maps/geo?q=#{city.gsub(' ', '%20')},#{country.gsub(' ', '%20')}&output=xml&oe=utf8&sensor=false&key=#{GOOGLE_API_KEY}"
      geocode_doc = open(geocode_url) { |f| Hpricot(f) }

      coords_ele = geocode_doc.search('//coordinates')[0]
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