class City < ActiveRecord::Base
  has_many :mentions
  has_many :histories
  has_many :counts
  
  # Last 6 hours today compared to same 6 hours yesterday
  def trending_up
    today_from = Time.now - ((60 * 60) * 6)
    today_to = Time.now

    yesterday_from = (Time.now - (60 * 60 * 24)) - ((60 * 60) * 6)
    yesterday_to = (Time.now - (60 * 60 * 24))
    
    today_mentions = Mention.find(:all, :conditions => {:city_id => self.id, :mentioned_at => (time_string_builder(today_from)..time_string_builder(today_to))})
    yesterday_mentions = Mention.find(:all, :conditions => {:city_id => self.id, :mentioned_at => (time_string_builder(yesterday_from)..time_string_builder(yesterday_to))})
    
    today_mentions.length > yesterday_mentions.length
  end
  
  def time_string_builder(time)
    "#{time.year}-#{time.month.to_s.rjust(2, '0')}-#{time.day.to_s.rjust(2, '0')} #{time.hour.to_s.rjust(2, '0')}:#{time.min.to_s.rjust(2, '0')}"
  end
  
  def stat
    Stat.find_by_city_id(self.id)
  end
end
