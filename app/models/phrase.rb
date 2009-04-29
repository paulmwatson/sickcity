class Phrase < ActiveRecord::Base
  has_many :mentions
  has_many :histories

  def trending_up_by_city(city_id)
    today_from = Time.now - ((60 * 60) * 6)
    today_to = Time.now

    yesterday_from = (Time.now - (60 * 60 * 24)) - ((60 * 60) * 6)
    yesterday_to = (Time.now - (60 * 60 * 24))
    
    today_mentions = Mention.find(:all, :conditions => {:phrase_id => self.id, :city_id => city_id, :mentioned_at => (time_string_builder(today_from)..time_string_builder(today_to))})
    yesterday_mentions = Mention.find(:all, :conditions => {:phrase_id => self.id, :city_id => city_id, :mentioned_at => (time_string_builder(yesterday_from)..time_string_builder(yesterday_to))})
    
    today_mentions.length > yesterday_mentions.length
  end

  def time_string_builder(time)
    "#{time.year}-#{time.month.to_s.rjust(2, '0')}-#{time.day.to_s.rjust(2, '0')} #{time.hour.to_s.rjust(2, '0')}:#{time.min.to_s.rjust(2, '0')}"
  end

end
