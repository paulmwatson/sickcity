class CountriesController < ApplicationController
  layout 'base'
  def index
    @countries = City.find :all, :group => 'country', :order => 'country'
    @cities = City.find :all, :order => 'country, name', :conditions => {:hidden => false}, :limit => 10
    
    sql = 'select city_id from mentions group by city_id having count(id) > 100'
    cities_with_more_than_1000_tweets = ActiveRecord::Base.connection.execute(sql)
    city_ids = ''
    cities_with_more_than_1000_tweets.each do |result|
      city_ids = city_ids + "#{result},"
    end
    city_ids = city_ids[0..city_ids.length-2]
    
    top_ten_stats = Stat.find(:all, :conditions => 'city_id in (' + city_ids + ')', :order => 'quotient desc', :limit => 10)
    
    @top_ten_cities = []
    top_ten_stats.each do |stat|
      @top_ten_cities << City.find(stat.city_id)
    end
    
    @working_date = Date.today
    @mentions = Mention.find :all, :conditions => {:mentioned_at => ("#{@working_date.year}-#{@working_date.month.to_s.rjust(2, '0')}-#{@working_date.day.to_s.rjust(2, '0')} 00:00".."#{@working_date.year}-#{@working_date.month.to_s.rjust(2, '0')}-#{@working_date.day.to_s.rjust(2, '0')} 23:59")}, :order => :mentioned_at
    
    @trend_today = Hash.new()
    @top_ten_cities.each do |city|
      @trend_today[city.id] = Array.new(24,0)
    end
    
    @mentions.each do |mention|
      begin
        @trend_today[mention.city_id][mention.mentioned_at.hour] = @trend_today[mention.city_id][mention.mentioned_at.hour] + 1
      rescue
      end
    end
  end
  
end