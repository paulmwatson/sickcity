class CountriesController < ApplicationController
  layout 'base'
  def index
    @countries = City.find :all, :group => 'country', :order => 'country'
    @cities = City.find :all, :order => 'country, name', :conditions => {:hidden => false}
    @topten_cities = Mention.find :all, :group => 'city_id', :select => 'count(id) as city_mentions, city_id', :order => 'city_mentions DESC', :limit => 20
    
    @working_date = Date.today
    puts @working_date
    @mentions = Mention.find :all, :conditions => {:mentioned_at => ("#{@working_date.year}-#{@working_date.month.to_s.rjust(2, '0')}-#{@working_date.day.to_s.rjust(2, '0')} 00:00".."#{@working_date.year}-#{@working_date.month.to_s.rjust(2, '0')}-#{@working_date.day.to_s.rjust(2, '0')} 23:59")}, :order => :mentioned_at
    
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
end
