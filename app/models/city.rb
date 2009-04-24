class City < ActiveRecord::Base
  has_many :mentions
  has_many :histories
  has_many :counts
  
  # Count of total mentions for the city for a day
  def mention_count(date)
    Count.find(:first, :conditions => {:city_id => self.id, :date => date}).count
  end
  
  # Latest count of total mentions for the city for a day
  def last_mention_count
    Count.find(:first, :conditions => {:city_id => self.id}, :order => 'date DESC').count
  end

  # Latest count of SICK mentions for the city for the day
  def last_sick_mention_count
    @range_center = Date.today
    twenty_four_hour_count = Mention.find(:all, :select => "DATE(mentioned_at) as mentioned_at_date, mentioned_at, substring_index(mentioner, ' (', 1) as mentioner_stripped, mentioner, link, exact_location", :group => 'mentioner_stripped, mentioned_at_date', :conditions => {:city_id => self.id, :mentioned_at => ("#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 00:00".."#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 23:59")})
    twenty_four_hour_count.length
  end

  # Count of SICK mentions for the city for today
  def sick_mention_count(date)
    @range_center = date
    twenty_four_hour_count = Mention.find(:all, :select => "DATE(mentioned_at) as mentioned_at_date, mentioned_at, substring_index(mentioner, ' (', 1) as mentioner_stripped, mentioner, link, exact_location", :group => 'mentioner_stripped, mentioned_at_date', :conditions => {:city_id => self.id, :mentioned_at => ("#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 00:00".."#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 23:59")})
    twenty_four_hour_count.length
  end
  
  def sick_mention_count_by_phrase(date, phrase)
    @range_center = date
    twenty_four_hour_count = Mention.find(:all, :select => "DATE(mentioned_at) as mentioned_at_date, mentioned_at, substring_index(mentioner, ' (', 1) as mentioner_stripped, mentioner, link, exact_location", :group => 'mentioner_stripped, mentioned_at_date', :conditions => {:phrase_id => phrase.id, :city_id => self.id, :mentioned_at => ("#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 00:00".."#{@range_center.year}-#{@range_center.month.to_s.rjust(2, '0')}-#{@range_center.day.to_s.rjust(2, '0')} 23:59")})
    twenty_four_hour_count.length
  end
  

  def last_sickness_quotient
    self.sickness_quotient(Date.today)
  end
  
  def sickness_quotient(date)
    ((Float(self.sick_mention_count(date)) / Float(self.mention_count(date))) * 100)
  end
  
  def sickness_quotient_by_phrase(date, phrase)
    ((Float(self.sick_mention_count_by_phrase(date, phrase)) / Float(self.mention_count(date))) * 100)
  end
  
  # Must not compute on today as data won't all be there
  # So only use dates that are yesterday or older
  def trending_up(date)
    self.sickness_quotient(date).round(2) > self.sickness_quotient(date-1).round(2)
  end
  
  def trending_up_by_phrase(date, phrase)
    self.sickness_quotient_by_phrase(date, phrase).round(2) > self.sickness_quotient_by_phrase(date-1, phrase).round(2)
  end
end
