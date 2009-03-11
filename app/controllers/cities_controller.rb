class CitiesController < ApplicationController
  layout 'base'
  def index
    @cities = City.find :all, :order => 'country, name'
    
    @mentions = Mention.find :all, :conditions => {:mentioned_at => ("#{Date.today.year}-#{Date.today.month.to_s.rjust(2, '0')}-#{Date.today.day.to_s.rjust(2, '0')} 00:00".."#{Date.today.year}-#{Date.today.month.to_s.rjust(2, '0')}-#{Date.today.day.to_s.rjust(2, '0')} 23:59")}, :order => :mentioned_at
    
    @trend = Hash.new()
    @cities.each do |city|
      @trend[city.id] = Array.new(24,0)
    end
    
    @mentions.each do |mention|
      @trend[mention.city_id][mention.mentioned_at.hour] = @trend[mention.city_id][mention.mentioned_at.hour] + 1
    end
  end
end
