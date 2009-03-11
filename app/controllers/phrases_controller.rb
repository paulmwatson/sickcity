class PhrasesController < ApplicationController
  layout 'base'
  def index
    @city = City.find :first, :conditions => {:name => params[:city]}
    @phrases = Phrase.find :all, :order => 'title'
    
    @mentions = Mention.find :all, :conditions => {:city_id => @city.id, :mentioned_at => ("#{Date.today.year}-#{Date.today.month.to_s.rjust(2, '0')}-#{Date.today.day.to_s.rjust(2, '0')} 00:00".."#{Date.today.year}-#{Date.today.month.to_s.rjust(2, '0')}-#{Date.today.day.to_s.rjust(2, '0')} 23:59")}, :order => :mentioned_at
    
    @trend = Hash.new()
    @phrases.each do |phrase|
      @trend[phrase.id] = Array.new(24,0)
    end
    
    @mentions.each do |mention|
      @trend[mention.phrase_id][mention.mentioned_at.hour] = @trend[mention.phrase_id][mention.mentioned_at.hour] + 1
    end
  end  
end
