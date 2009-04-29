class MentionsController < ApplicationController
  layout 'base'
  
  def removed_list
    @mentions = RemovedMention.find(:all, :order => 'created_at desc', :limit => 50)
  end
  
  def unremove
    mention_to_move = RemovedMention.find(params[:mention_id])
    moved_mention = Mention.new(mention_to_move.attributes)
    moved_mention.created_at = Time.now
    if moved_mention.save
      mention_to_move.destroy
    end
    redirect_to request.referrer
  end
  
  # Called from mentions/index button
  def remove
    mention_to_move = Mention.find(params[:mention_id])
    moved_mention = RemovedMention.new(mention_to_move.attributes)
    moved_mention.created_at = Time.now
    if moved_mention.save
      mention_to_move.destroy
    end
    redirect_to request.referrer
  end
  
  def index
    @city = City.find :first, :conditions => {:name => params[:city]}
    @phrase = Phrase.find :first, :conditions => {:title => params[:phrase]}
    @location = get_location(@city.name, @city.country)
    
    # 30 day range centered on the current date
    @range = 30
    @range_center = params[:date] ? Date.parse(params[:date]) : Date.today
    @range_start = @range_center - (@range / 2)
    @range_end = @range_center + (@range / 2)

    @mentions = Mention.find :all, :select => "id, message, DATE(mentioned_at) as mentioned_at_date, mentioned_at, substring_index(mentioner, ' (', 1) as mentioner_stripped, mentioner, link, exact_location", :group => 'mentioned_at_date, mentioner_stripped', :conditions => {:phrase_id => @phrase.id, :city_id => @city.id, :mentioned_at => ("#{@range_start.year}-#{@range_start.month.to_s.rjust(2, '0')}-#{@range_start.day.to_s.rjust(2, '0')} 00:00".."#{@range_end.year}-#{@range_end.month.to_s.rjust(2, '0')}-#{@range_end.day.to_s.rjust(2, '0')} 23:59")}, :order => :mentioned_at
    @twenty_four_hour_count = Mention.find :all, :select => "DATE(mentioned_at) as mentioned_at_date, mentioned_at, substring_index(mentioner, ' (', 1) as mentioner_stripped, mentioner, link, exact_location", :group => 'mentioner_stripped, mentioned_at_date', :conditions => {:phrase_id => @phrase.id, :city_id => @city.id, :mentioned_at => ("#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 00:00".."#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 23:59")}
    begin
      @graph_max = Mention.find(:first, :conditions => {:phrase_id => @phrase.id, :city_id => @city.id}, :group => 'mentioned_at_date, mentioner_stripped', :select => "substring_index(mentioner, ' (', 1) as mentioner_stripped, DATE(mentioned_at) as mentioned_at_date, count(id) as graph_max", :order => 'graph_max DESC').graph_max
    rescue
      @graph_max = 0
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